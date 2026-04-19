/* EE P 598a - Sp26: Lab Task 1 */



// ---------------------------------------------------------------------------
/*
Problem 1

Environment Variables (aka PseudoVariables) & Expressions

*/

// Some Help can be found here
HelpBrowser.openLink("Classes/Environment#PseudoVariables (global variables)");
Interpreter;  // select and cmd-D to open Help page


/*
1a

create an environment variable named myVarA and set it to 10
*/
~myVarA = 10;

/*
1b

create another environment variable named myVarB and set it to 20
*/
~myVarB = 20;
/*
1c

create another environment variable named myVarC and set it to 30
*/
~myVarC = 30;

/*
1d

create another environment variable named myVarD and set it to 40
*/
~myVarD = 40;

/*
1e

create another environment variable named myVarABCD and set it to
the result of

- adding myVarA and myVarB
- then multiplying by myVarC
- then subtracting myVarD
*/
~mathStepOne = ~myVarA + ~myVarB;
~mathStepTwo = ~mathStepOne * ~myVarC;
~mathStepThree = ~mathStepTwo - ~myVarD;
~myVarABCD = ~mathStepThree;



// ---------------------------------------------------------------------------
/*
Problem 2

Expressions & Functions

*/

// Some Help can be found here
Function;  // select and cmd-D to open Help page


/*
2a

create an environment variable named myAddMulSubFunc and assign it to a function that
will return the expression described in 1e

the function should have four arguments (i.e., inputs) named argA, argB, argC, argD
*/
~myAddMulSubFunc = {|argA, argB, argC, argD|
	var mathStepOne;
	var mathStepTwo;
	var mathStepThree;
	var myVarABCD;

	mathStepOne = argA + argB;
	mathStepTwo = mathStepOne * argC;
	mathStepThree = mathStepTwo - argD;
	myVarABCD = mathStepThree

};
~myAddMulSubFunc.value(10,20,30,40);

/*
2b

evaluate the function assigned to myAddMulSubFunc with the following arguments: 2, 3, 4, 5

NOTE: the expected return value is 15
*/
~myAddMulSubFunc.value(2,3,4,5);

/*
2c

evaluate the function assigned to myAddMulSubFunc by passing myVarA... myVarD, as found in Problem 1

NOTE: the expected return value is 860
*/

~myAddMulSubFunc.value(~myVarA,~myVarB,~myVarC,~myVarD);
/*
2d

re-assign myVarA... myVarD to new values of your choice and re-evaluate myAddMulSubFunc with these new values

*/
~myVarA = 1;
~myVarB = 2;
~myVarC = 9;
~myVarD = 16;

~myAddMulSubFunc.value(~myVarA,~myVarB,~myVarC,~myVarD);
//Should be 11

// ---------------------------------------------------------------------------
/*
Problem 3

Arrays - creation, indexing, expressions

*/

// Some Help can be found here
Array;  // select and cmd-D to open Help page
SequenceableCollection;
Collection;


/*
3a

create an environment variable named myArrayA and set it to an array filled with 5 numbers of your choice

*/
~myArrayA = [1,1,2,3,5];
/*
3b

create an environment variable named myArrayB and set it to an array filled with 5 random numbers
in the range minVal to maxVal

*/
~myArrayB = Array.rand(5, 1, 100);

/*
3c

write an expression to return the 3rd item from myArrayA

HINT: SC indexes from zero!
*/
~myArrayA[2];

/*
3d

write an expression to return the product of the 3rd item from myArrayA and the 1st item from myArrayB

*/
~myArrayA[2] * ~myArrayB[0];
/*
3e

write an expression to return the item by item product of myArrayA and myArrayB

*/

~myArrayA * ~myArrayB;
/*
3f

write an expression to iterate over myArrayA, posting each item (to the post window) along with its index number

*/
~myArrayA.do({ |item, i|
	postln(item);
});
/*
3g

write an expression to return a new Array containing only the elements of myArrayA at odd indices

HINT: see Help for Collection
*/
~newArray = ~myArrayA.collect({ |item, i|
	if(i.mod(2) == 1){
		item
	}
}).removeEvery([nil]);

// ---------------------------------------------------------------------------
/*
Problem 4

Arrays - functions

*/

// Some Help can be found here
Array;  // select and cmd-D to open Help page
SequenceableCollection;  // select and cmd-D to open Help page
Collection;  // select and cmd-D to open Help page


/*
4a

create an environment variable named myArrayMulFunc and set it to a function that
will return the result of the expression described in 3e

the function should have two arguments (i.e., inputs) named argArrayA, argArrayB

*/
~myArrayMulFunc = {|argArrayA, argArrayB|
	argArrayA * argArrayB;
}

~myArrayMulFunc.value(~myArrayA,~myArrayB)
/*
4b

create an environment variable named myArrayLaceFunc and set it to a function that
will return a new Array whose elements are interlaced sequences of the elements

ASSUME the two Arrays are of the same length

e.g., if the two arrays are [ item0, item1, .... ] and [ jtem0, jtem1, ... ]
the returned array will be [ [ item0, jtem0 ], [ item1, jtem1 ], ... ]

the function should have two arguments (i.e., inputs) named argArrayA, argArrayB

*/
~myArrayLaceFunc = {|argArrayA, argArrayB|
	var result;

	result = argArrayA.collect({ |item,i|
		[item,argArrayB[i]]
	});
}

~myArrayLaceFunc.value(~myArrayA,~myArrayB);
/*
4c

create an environment variable named myArrayLaceReverseFunc and set it to a function that
will return a new Array whose elements are interlaced sequences of the elements, but
where the sequence is reversed!

ASSUME the two Arrays are of the same length

the function should have two arguments (i.e., inputs) named argArrayA, argArrayB

HINT: this new function could call the function created in 4b

*/
~myArrayLaceReverseFunc = {|argArrayA, argArrayB|
	var temp;
	var result;

	temp = ~myArrayLaceFunc.value(argArrayA,argArrayB);
	result = temp.reverse();

}
~myArrayLaceReverseFunc.value(~myArrayA,~myArrayB);
