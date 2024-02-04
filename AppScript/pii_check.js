/**
 *Copyright 2020 Data Runs Deep Pty Ltd. All rights reserved.
 *@author: - Nehal Sateesh Kumar (nehal.kumar@jellyfish.com)
 */

const filterConfig = {
  email: {
    regex: '[a-zA-Z0-9+._-]+(%40|@)[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+|emailaddress=|email=|mailto=',
    sheet: "_EmailCheck_GA4"
  },
  phone: {
    regex: "\W(tel=|telephone=|phone=|cell=|mobile=|mob=|Tel:)",
    sheet: "_PhoneNumber_Check_GA4"
  },
  creditcard: {
    regex: "\W(creditcard=|debitcard=|credit=|debit=)[^&\/\?]+",
    sheet: "_CreditCard_Check_GA4"
  },
  name: {
    regex: "\W(username=|firstname=|first=|lastname=|last=|surname=|familyname=)[^&\/\?]+",
    sheet: "_Name_Check_GA4",
  },
  password: {
    regex: "\W(password=|pass=|passwd=|pw=)[^&\/\?]+",
    sheet: "_Password_Check_GA4"
  },
  zipcode: {
    regex: "\W(postcode=|zipcode=|zip=)[^&\/\?]+",
    sheet: "_ZipCode_Check_GA4"
  },
  tfn: {
    // Returns too broad matching so need extra validator
    regex: "(\\d{3}[ -]?\\d{3}[ -]?\\d{3})|(TFN=|tax-number=|taxfilenumber=|tax-file-number=)",
    sheet: "_TFN_Check_GA4",
    validator: validateTaxFileNumber
  },
  medicare: {
    // Returns too broad matching so need extra validator
    regex: "(\\d{4}[ ]?\\d{5}[ ]?\\d{1}[- ]?\\d?)|(medicard=|medi-card=|medicare=)",
    sheet: "_AustralianMedicard_Check_GA4",
    validator: validateMedicare
  },
  address: {
    regex: "address=[^&\/\?]+",
    sheet: "_Address" // missing _check_ga4?
  }
}

const reportConfig = {
  page: { getRequest: getPageRequest, sheetPrefix: "_PA" },
  traffic: { getRequest: getTrafficRequest, sheetPrefix: "_TF" },
  search: { getRequest: getSearchRequest, sheetPrefix: "_SR" }
}



// Fetch overviewsheet to push in last updated date(AEST)
const overviewSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Overview').getRange("A1:B1");

// Fetch the configurations from the overview sheet
const configValues = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Overview').getRange("A4:B9").getValues();
const propertyId = configValues[1][1];
const startDate = configValues[4][1];
const endDate = configValues[5][1];



// Configure custom menu to run PII reports
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('PII Checker')
    .addItem('Run GA4 Reports', 'executeGA4Reports')
    .addToUi();
};


function executeGA4Reports() {

  try {
    const reports = Object.keys(reportConfig)
    const filters = Object.keys(filterConfig)

    for (let i = 0; i < reports.length; i++) {
      const reportKey = reports[i]
      const report = reportConfig[reportKey]

      for (let j = 0; j < filters.length; j++) {
        const filterKey = filters[j]
        const filter = filterConfig[filterKey]

        const sheetName = report.sheetPrefix + filter.sheet
        runReport(report.getRequest(filter.regex), reportKey, filterKey, sheetName, propertyId);

      }
    }

    // Update 'last update' time in the sheet
    const today = Utilities.formatDate(new Date(), 'Australia/Melbourne', 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    overviewSheet.clearContent();
    overviewSheet.setValues([['Last Updated Date(AEST): GA4 Reports', today]])

  } catch (e) {
    console.error(e)

    // check for specific messages we want to surface to the user using ui.alert()
    if(e.details?.code === 403){
      SpreadsheetApp.getUi().alert("Missing permissions for target GA4 Property " + propertyId)
    }
  }

};




// Function to find valid medicare number in a string
// Resource:https://stackoverflow.com/questions/3589345/how-do-i-validate-an-australian-medicare-number
function validateMedicare(str) {
  if (!str) return false

  // Extract urlPart that contains the potential medicare num
  const regex = filterConfig.medicare.regex
  let urlPart = str.match(regex)

  if (!urlPart || !urlPart[0]) return false

  // Get all the digits throughout
  let numPart = urlPart[0].match(/\d/g)

  if (!numPart) return false

  // Join all the digits into the final medicare num
  const medicare = numPart.join("")


  // Special checks
  if (medicare && medicare.length === 10 || medicare.length === 11) {
    const matches = medicare.match(/^(\d{8})(\d)/);

    if (!matches) return false;

    const base = matches[1];
    const checkDigit = matches[2];
    const weights = [1, 3, 7, 9, 1, 3, 7, 9];

    let sum = 0;
    for (let i = 0; i < weights.length; i++) {
      sum += parseInt(base[i], 10) * weights[i];
    }

    if (sum % 10 === parseInt(checkDigit, 10)) return true

  }

  return false;
};

// Function to find a valid TFN(Tax File Number) number in a string
// Resource: http://www.mathgen.ch/codes/tfn.html
function validateTaxFileNumber(str) {

  // Extract urlPart that contains the potential TFN
  const regex = filterConfig.tfn.regex
  let urlPart = str.match(regex)

  if (!urlPart || !urlPart[0]) return false

  // Get all the digits throughout
  let digits = urlPart[0].match(/\d/g)

  if (!digits) return false

  // do the calcs
  let sum = (digits[0] * 1)
    + (digits[1] * 4)
    + (digits[2] * 3)
    + (digits[3] * 7)
    + (digits[4] * 5)
    + (digits[5] * 8)
    + (digits[6] * 6)
    + (digits[7] * 9)
    + (digits[8] * 10);

  let remainder = sum % 11;

  if (remainder !== 0) return false

  return true
};



function getPageRequest(filterValue) {

  // Define required metrics
  const views = AnalyticsData.newMetric();
  views.name = 'screenPageViews';

  const viewsPerSession = AnalyticsData.newMetric();
  viewsPerSession.name = 'screenPageViewsPerSession';

  const eventCount = AnalyticsData.newMetric();
  eventCount.name = 'eventCount';

  const conversions = AnalyticsData.newMetric();
  conversions.name = 'conversions';

  const totalRevenue = AnalyticsData.newMetric();
  totalRevenue.name = 'totalRevenue';

  // Define required Dimensions
  const fullPageUrl = AnalyticsData.newDimension();
  fullPageUrl.name = 'fullPageUrl';

  const pagePath = AnalyticsData.newDimension();
  pagePath.name = 'pagePath';

  const pageTitle = AnalyticsData.newDimension();
  pageTitle.name = 'pageTitle';

  const dateRange = AnalyticsData.newDateRange();
  dateRange.startDate = startDate;
  dateRange.endDate = endDate;

  // Define Dimension filter
  const filters = AnalyticsData.newFilter();
  filters.fieldName = 'fullPageUrl';


  const stringFilters = AnalyticsData.newFilter();
  stringFilters.matchType = 'PARTIAL_REGEXP';
  stringFilters.value = filterValue;
  stringFilters.caseSensitive = false;


  const dimensionFilters = AnalyticsData.newFilterExpression();
  dimensionFilters.filter = filters;
  dimensionFilters.filter.stringFilter = stringFilters;


  // Construct the GA4 API request
  const request = AnalyticsData.newRunReportRequest();
  request.dimensions = [fullPageUrl, pagePath, pageTitle];
  request.metrics = [views, viewsPerSession, eventCount, conversions, totalRevenue];
  request.dateRanges = dateRange;
  request.dimensionFilter = dimensionFilters;

  return request



};

function getTrafficRequest(filterValue) {

  // Define required metrics
  const users = AnalyticsData.newMetric();
  users.name = 'totalUsers';

  const sessions = AnalyticsData.newMetric();
  sessions.name = 'sessions';

  const engagedSessions = AnalyticsData.newMetric();
  engagedSessions.name = 'engagedSessions';

  const eventCount = AnalyticsData.newMetric();
  eventCount.name = 'eventCount';

  const conversions = AnalyticsData.newMetric();
  conversions.name = 'conversions';

  const totalRevenue = AnalyticsData.newMetric();
  totalRevenue.name = 'totalRevenue';

  // Define required Dimensions
  const sourceMedium = AnalyticsData.newDimension();
  sourceMedium.name = 'sessionSourceMedium';

  const campaign = AnalyticsData.newDimension();
  campaign.name = 'sessionCampaignName';

  const dateRange = AnalyticsData.newDateRange();
  dateRange.startDate = startDate;
  dateRange.endDate = endDate;

  // Define Dimension filter
  const filters = AnalyticsData.newFilter();
  filters.fieldName = 'sessionCampaignName';


  const stringFilters = AnalyticsData.newFilter();
  stringFilters.matchType = 'PARTIAL_REGEXP';
  stringFilters.value = filterValue;
  stringFilters.caseSensitive = false;


  const dimensionFilters = AnalyticsData.newFilterExpression();
  dimensionFilters.filter = filters;
  dimensionFilters.filter.stringFilter = stringFilters;


  // Construct the GA4 API request
  const request = AnalyticsData.newRunReportRequest();
  request.dimensions = [sourceMedium, campaign];
  request.metrics = [users, sessions, engagedSessions, eventCount, conversions, totalRevenue];
  request.dateRanges = dateRange;
  request.dimensionFilter = dimensionFilters;

  return request

};

function getSearchRequest(filterValue) {
  // Define required metrics
  const eventCount = AnalyticsData.newMetric();
  eventCount.name = 'eventCount';

  // Define required Dimensions
  const searchTerm = AnalyticsData.newDimension();
  searchTerm.name = 'searchTerm';

  const dateRange = AnalyticsData.newDateRange();
  dateRange.startDate = startDate;
  dateRange.endDate = endDate;

  // Define Dimension filter
  const filters = AnalyticsData.newFilter();
  filters.fieldName = 'searchTerm';


  const stringFilters = AnalyticsData.newFilter();
  stringFilters.matchType = 'PARTIAL_REGEXP';
  stringFilters.value = filterValue;
  stringFilters.caseSensitive = false;


  const dimensionFilters = AnalyticsData.newFilterExpression();
  dimensionFilters.filter = filters;
  dimensionFilters.filter.stringFilter = stringFilters;


  // Construct the GA4 API request
  const request = AnalyticsData.newRunReportRequest();
  request.dimensions = [searchTerm];
  request.metrics = [eventCount];
  request.dateRanges = dateRange;
  request.dimensionFilter = dimensionFilters;

  return request;



};


function runReport(request, reportType, filterName, sheetName, propertyId) {
  const report = AnalyticsData.Properties.runReport(request, 'properties/' + propertyId);

  // Declare sheet name to store data
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = spreadsheet.getSheetByName(sheetName);

  if(!sheet){
    console.error(`Cannot find sheet named ${sheetName}`)
    return
  }

  // Clear previous data
  sheet.getRange("A:Z").clearContent();


  // If no results returned from the API log no rows returned
  if (!report.rows) {
    console.log(`No data returned from the API; report type: ${reportType}, filter: ${filterName}`);
    return;
  }

  //console.log(`API returned ${report.rows.length}; report type: ${reportType}, filter: ${filterName}`)

  // Append the headers
  const dimensionHeaders = report.dimensionHeaders.map(dimensionHeader => dimensionHeader.name);
  const metricHeaders = report.metricHeaders.map(metricHeader => metricHeader.name);
  const headers = [...dimensionHeaders, ...metricHeaders];
  sheet.appendRow(headers);


  // Transform the data
  const rows = report.rows.map((row) => {
    const dimensionValues = row.dimensionValues.map(dimensionValue => dimensionValue.value);
    const metricValues = row.metricValues.map(metricValues => metricValues.value);
    return [...dimensionValues, ...metricValues];
  });

  // Check for additional validators and remove any
  // rows that fail validation
  const validator = filterConfig[filterName].validator
  if (validator) {
    for (let j = 0; j < rows.length; j++) {

      if (!validator(rows[j][0])) {
        rows.splice(j, 1)
        j--
      }

    }
  }

  // Dump the data into the sheet
  sheet.getRange(2, 1, rows.length, headers.length).setValues(rows);
  console.log(`Potential PII found and added to sheet; report type: ${reportType}, filter: ${filterName}`);
};

