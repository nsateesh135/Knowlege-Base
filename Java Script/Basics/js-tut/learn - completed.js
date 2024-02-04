// console.log(): Use to print output
// console.log("hello world");

/********************************/

//let: To define temporary JS variables
// let a = 10;
// let b = 9;
// b = 18;

// let c = a + b;
// //console.log(c);

// let str = "Wonderful World";
// //console.log(str);

// var: This is how a temporary variable is defined in old version of JS 
// Check to see the version of JS the tool is using
// var g = 5;

//const: This is how we define constants in JS
// const h = 12;
//h = 24;

// str.includes() :A special method for strings to check if a word/character exists
// let value = str.includes("World");

// //console.log(str.includes("World"));

// let d = 2;
// let e  = 4;
// let f = d + e;
// //console.log(f);

/***********************************/
// Functions
/*function addIt(value1, value2) {
	console.log(value1 + value2);
}

addIt(a, b);
addIt(4, 5);
addIt(100 + 200);

function addReturn(value1, value2 = 5) {
	return value1 + value2;
}

let sum1 = addReturn(10, 20);
console.log(sum1);

let sum2 = addReturn(4);
console.log(sum2);*/


/************************************************/
//Arrays:
//let arr1 = [1,2,3,4];

// console.log(arr1[0]);
// console.log(arr1[3]);
//let arr2 = [2,1,3,5];

// if(arr1[0] <= arr2[0]) {
// 	console.log("arr1 first element is less than or equal to arr2 first element");
// }

// if(arr1[1] >= arr2[1]) {
// 	console.log("arr1 second element is greater than or equal to arr2 second element");
// }

// if(arr1[2] === arr2[2]) {
// 	console.log("arr1 third element is equal to arr2 third element");
// }

// if(arr1[3] !== arr2[3]) {
// 	console.log("arr1 fourth element is not equal to arr2 fourth element");
// }

// let num1 = 5;
// let num2 = 8;

//&& : Logical AND operator
// if(num1 > 4 && num2 < 10) {
// 	console.log("We learned the and operation");
// }

// || : Logical OR operator
// if(num1 < 4 || num2 < 10) {
// 	console.log("We learned the or operation");
// }

// !: Logical not or inverse 
// if(!(num1 === 4)) {
// 	console.log("We learned the not operation");
// }

// if((num1 + num2) > 15) {
// 	console.log("When the if condition succeeds, don't go for else");
// } else {
// 	console.log("When the if condition fails, do else");
// }


// Looping
/*if(arr1[0] === arr2[0]) {
	console.log("Position 0: They are equal");
}
if(arr1[1] === arr2[1]) {
	console.log("Position 1: They are equal");
}
if(arr1[2] === arr2[2]) {
	console.log("Position 2: They are equal");
}
if(arr1[3] === arr2[3]) {
	console.log("Position 3: They are equal");
}*/

/*for(let i = 0; i < arr1.length; i++) {
	//do something
	if(arr1[i] === arr2[i]) {
		console.log("Position " + i + ": They are equal");
	}
}

// push : A special array method to push elements in an array
arr1.push(8);
console.log(arr1);
*/
/*****************************************************/
//  Objects or  Dictionary or key- value pairs
// let obj = {"name": "Neel", "age": "37", "job": "consultant", "hobby": "teaching"};
// let obj1 = {"name": "Mark", "age": "35", "job": "technician", "hobby": "yoga"};

// console.log(obj.name);
// console.log(obj1.name);

//obj["country"] = "India";
// obj.country = "India";
// console.log(obj);
/***************************************/
// Reading and Manipulating  HTML with JS

window.onload = function(e) {
	let el1 = document.querySelector("#text");
	console.log(el1.innerHTML);
	let el2 = document.querySelector(".empty");
	el2.innerHTML = "Setting text via JS";
	let value = el2.getAttribute("value");
	console.log(value);
	let number = el2.dataset.getNumber;
	console.log(number);
}

window.onclick = function(e) {
	console.log("clicked on screen!")

}


