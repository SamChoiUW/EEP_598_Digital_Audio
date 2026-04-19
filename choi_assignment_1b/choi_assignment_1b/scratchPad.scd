/*
Project Title: myLasName Assignment 1b
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
scratch here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
_scratchPad_ is the place to write test / scratch code, testing out ideas and
working on code that we'll later formally include in the project.

*/

/////////////// explore interaction with sclang & interpreter ///////////////

// -------------------------
// load functions

/*
First off, we'll load the functions found in the file named _functions_.
*/

(Document.current.dir +/+ "functions.scd").load;

currentEnvironment.keys;


// -------------------------
// load data

/*
We'll usually place various data in the file named _data_.
*/

(Document.current.dir +/+ "data.scd").load;

currentEnvironment.keys;


// inspect data
// ...


/////////////// explore interaction with scsynth & interpreter ///////////////


// -------------------------
// load synthDefs (& ctkProtoNotes)

/*
Let's load the synthDefs found in the file named _synthDefs_
*/

(Document.current.dir +/+ "synthDefs.scd").load;


// check... what's been loaded
currentEnvironment.keys;


// -------------------------
// list project synthDefs


// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;


// -------------------------
// prepare wavetable(s) and wave packet(s) for synthesis



// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;



// instantiate some notes


// let's try playing...


// when we're all finished, we should "clean up" and free up the space buffers use on the server

// free... when finished...