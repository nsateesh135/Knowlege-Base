/* App Scipt :is a rapid application development platform, it makes it easier to create business applications 
              that integrates with Google Workspace. It is based of ECMAScript but not with all features. 
              App Script can be thought of as Java Script.
*/

// To access appscript : Extensions -> App Script 

/* 
Table of Contents 
1. Basics 
 1.1  How to print in App Script?
 1.2  How to access spreadsheet cells? 
 1.3  Variable Assignment & for loop
 1.4  How to clear logs in AppScript?
 1.5  How to clear logs in AppScript?
 1.6  Clearing contents from the Sheet 
 1.7  Creating your own functions and using it in sheets
 1.8  Conditional Statements
 1.9  Read Range to a JS Array and Write to a range 
 1.10 Fill Down Formula(Set a formula & copy down autofill)
 1.11 Interacting with Calender API 
 1.12 Interacting with Gmail API 
 1.13 How to add Add App Script to a drawing on Sheets 
 1.14 Java Script Objects - Iterate through Object keys and values

*/


// 1.1 How to print in App Script?
console.log("Welcome to App Script World!")

/*
1.2 How to access spreadsheet cells? 
    SpreadsheetApp(object class)-> getActiveSpreadsheet(accessing the workbook)->getActiveSheet(accessing sheets in a workbook)->getRange(accessing cells)
    SpreadsheetApp: get's access to spreadsheet class 
    getActiveSpreadsheet(): gets the spreadsheet which we want to interact 
    getActiveSheet(): gets access to the active sheet like sheet1, sheet2
    getRange()
            row_index,col_index,num_rows,num_cols
            row_index,col_index
            a1 notation like "A1:C1"
    getValue() : Extract value from the cell/range of cells ,to get values use getValues()
    setValue() : Pushes value into the selected cells,to set values use setValues()
 */


function firstAppScript() {
    var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var dtc = ss.getRange("A1:C1").getValue();
    ss.getRange("A2:C2").setValue(dtc);
  
    console.log("The data was entered into the cell!")
  }
  

  /*
  1.3 Variable Assignment & for loop
      Variables should be named in Pascal case(someCell) as a good coding practice.
      Variables can't start with a number, special characters
  */

  function forloopFunc() {
    var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
   
    for(var i =0;i<5;i++){ // 5 because we know we are iterating 5 rows 
   
     someCell = ss.getRange(i+8,1).getValue(); // i+8 because we are operating on row 8 
     someCell += 5;
     ss.getRange(i+8,2).setValue(someCell); // (i+8,2) beacuse we are operating on row 8 but placing values in column 2
    }}
   
   // 1.4 How to clear logs in AppScript?
   Logger.clear();

// 1.5 Selecting sheet by name 

function SheetByName(){
  var targetSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Sheet2')
}

/* 1.6 Clearing contents from the Sheet 
       clear() : Clears all contents 
       clearContent() : Clears just the data 
       clearFormat() : Clears only the formatting 
       clearDataValidations(): Clears cells with data validation 

*/
function clearSheetValues() {
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet().getRange("A1:C12");
  ss.clear();
  }
 
 
/* 1.7 Creating your own functions and using it in sheets

*/

/**
 * Multiples 2 nunbers 
 * 
 * @params arg1 one of the numbers for multiplication
 * @params arg2 second number for multiplication
 * @customfunction
 */

function MULTIPLYBY2NUMBERS(arg1,arg2){
   var result  = arg1 * arg2 

   return result
}

/* 1.8 Conditional Statements 
       if(){} else if(){} else{}
*/

function HighLow(){
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

  for(var i = 0;i<6;i++){
   var fetch_value = ss.getRange(i+3,1).getValue();
   if(fetch_value > 60){
     ss.getRange(i+3,2).setValue("High")
   }else if(fetch_value >45 && fetch_value <60){
     ss.getRange(i+3,2).setValue("Relatively High")
   }else {
     ss.getRange(i+3,2).setValue("Low")
   }
  }
}

/*
 1.9 Read Range to a JS Array and Write to a range 
     getValues() : reads values as array from cells
     setValues() : sets array values in cells

    arr = [[52,"Relatively High"],[60,"High"]]

*/

function readAsArray(){

  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet().getRange("A7:B13").getValues();
  ss.getRange("A7:B13").setValues(ss);

}

/*
1.10 Fill Down Formula(Set a formula & copy down autofill)
     setFormula() : method used to set formula in a cell
     getLastRow() : method pulls up the last row which has value in the cell
     copyTo() : method copies formula from selected cell to a range of cells

*/

function dropDown(){
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  ss.getRange("D1").setFormula("=(A2+B2)*C2")

  var last_row = ss.getLastRow();
  var fillDownRange = ss.getRange(2,4,lr-1);
  ss.getRange("D2").copyTo(fillDownRange);
}

/*
  1.11 Interacting with Calender API 
       CalenderAPP : Class object used to interact with Google Calender API 
       getCalenderById : method used to fetch all calenders associated to your id(nehalsateeshkumar@gmail.com)
       getEvents(): Fetches all avaiable events in the chosen time period
       getTitle() : method used to extract all calender titles


*/

function getEvents(){
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var cal = CalendarApp.getCalendarById("nehalsateeshkumar@gmail.com");
  var events = cal.getEvents(new Date("5/1/2023 12:00 AM"), new Date("5/1/2023 11:59 PM"));

  var lr = ss.getLastRow();
  ss.getRange(2,1,lr-1,5).clearContent();
  
  for(var i =0;i<events.length;i++){
    var title = events[i].getTitle();
    var sd =  events[i].getStartTime();
    var ed =  events[i].getEndTime();
    var loc = events[i].getLocation();
    var des = events[i].getDescription();

    console.log(title,sd,ed,loc,des);
    
    ss.getRange(i+2,1).setValue(title);
    ss.getRange(i+2,2).setValue(sd);
    ss.getRange(i+2,2).setNumberFormat("yyyy-mm-dd hh:mm:ss AM/PM")
    ss.getRange(i+2,3).setValue(ed);
    ss.getRange(i+2,3).setNumberFormat("yyyy-mm-dd hh:mm:ss AM/PM")
    ss.getRange(i+2,4).setValue(loc);
    ss.getRange(i+2,5).setValue(des);
  }}

function addEvents(){
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var cal = CalendarApp.getCalendarById("nehalsateeshkumar@gmail.com");
  var lr = ss.getLastRow();

  var data = ss.getRange("A2:E"+lr).getValues();

  for(var i=0;i<data.length;i++){
    cal.createEvent(data[i][0],data[i][1],data[i][2],{location:data[i][3], description:data[i][4]})
  }

}

/*
  1.12 Interacting with Gmail API 
       getRemainingDailyQuota() : method to identify daily quota limit (The limit is 100 emails/day)
       Browser.msgBox() : displays a message on the front end of sheets
       MailAPP: Its a class variable used to interact with Gmail
       sendEmails(): method used to send emails

*/

function sendEmails(){
  SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Emails").activate();
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var ls = ss.getLastRow();

  var templateText = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Template").getRange(1,1).getValue();

  var quotaLeft = MailApp.getRemainingDailyQuota();

  if ((lr-1)> quotaLeft){
    Browser.msgBox("You have "+ quotaLeft + "email quota left!")
  } else {

    for(var i =2;i<=lr;i++){

      var currentEmail = ss.getRange(i,1).getValue();
      var currentClassTitle = ss.getRange(i,3).getValue();
      var currentName = ss.getRange(i,2).getValue();
      var messageBody = templateText.replace("{name}",currentName).replace("{title}",currentClassTitle);

      var subjectLine = "Reminder: " +currentClassTitle +" Upcoming Class";
      MailAPP.sendEmails(currentEmail,subjectLine,messageBody);

    }  }
}  

/* 1.13 How to add Add App Script to a drawing on Sheets 

Step 1: Create a drawing for instance send email 
Step 2: Hover over hamburger menu on the drawing and click on assign App Script 
Step 3: Enter the name of the App Script (without the brackets)

*/

/*
  1.14 Java Script Objects - Iterate through Object keys and values
       JS objects are like dictionaries in Python 


       
        var info = {
                          name: "nehal", 
                          gender: "male",
                          eyecolor: "black",
                          age: 29,
                          favourite_colors : ["green","red","blue"],
                          address :{street:"Melbourne", city: "Melbourne", zipcode :"3000"}
            };

            for ([keys,val] in info){
              console.log(key);
              console.log(val)
            }

            console.log(info['address']['zipcode'])
*/

function sendEmails(){
  SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Emails").activate();
  var ss = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var ls = ss.getLastRow();

  var templateText = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Template").getRange(1,1).getValue();

  var quotaLeft = MailApp.getRemainingDailyQuota();

  if ((lr-1)> quotaLeft){
    Browser.msgBox("You have "+ quotaLeft + "email quota left!")
  } else {

    for(var i =2;i<=lr;i++){

      var currentEmail = ss.getRange(i,1).getValue();
      var currentClassTitle = ss.getRange(i,3).getValue();
      var currentName = ss.getRange(i,2).getValue();

      var info = {
        name :currentName,
        title: currentClassTitle
      }
      var messageBody = templateText;

      for([keys,val] in info){
        messageBody = messageBody.replace("{" + key + "}",val);
      }


      var subjectLine = "Reminder: " +currentClassTitle +" Upcoming Class";
      MailAPP.sendEmails(currentEmail,subjectLine,messageBody,{name:"Company Name"});

    }  }
}  

/*
  1.15 Interacting with Google Maps
*/

