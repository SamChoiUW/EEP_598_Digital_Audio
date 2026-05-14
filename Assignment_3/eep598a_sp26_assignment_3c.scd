/*
Project Title: Assignment 3c
Date: Mon May  4 13:52:09 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 3c explores implementing Time Domain Transposition Techniques.

Similar to Assignment 3a, but this time implement transposition via PitchShiftPA,
a Phase-Aligned Pitch and Formant Shifter.

Author a synthDef which will synthesize an ascending
Ptolemaic sequence, aka Ptolemy's intense diatonic scale, given a single instrumental
source tone. (Use the same source tone as 3a.)

ALSO, implement a second formant shift, rather than pitch shift scale, using the same
ascending Ptolemaic sequence ratios.


Ascending ratios:
1:1, 9:8, 5:4, 4:3, 3:2, 5:3, 15:8, 2:1  // do, re, mi, fa, sol, la, ti, do


https://en.wikipedia.org/wiki/Ptolemy%27s_intense_diatonic_scale
*/

/*
Start by downloading the resource found on the Canvas link for Assignment 3c:

• myLastName_assignment_3c

*/

/*
Unzip myLastName_assignment_3c and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

*/

/*
The London Philharmonia (https://philharmonia.co.uk/resources/sound-samples/) library,
which contains single channel _mono_ recordings.

Choose a single instrumental tone to process. (Use the same source tone as 3a.)
*/

/*
Implement implement a single synthDef similar to those found in Assignment 3a, but where
the transposition is synthesized through the use of PitchShiftPA.

As well as _refFreq_ and _minRefFreq_, expose _pitchRatio_ and _formantRatio_ as synthDef
arguments.

*/

/*

Synthesize _two_ ascending "scales".

• for the first, pass the ascending ratios to _pitchRatio_
• for the second, pass the ascending ratios to _formantRatio_

NOTE: the second "scale" will return a sequence of formant shifts rather than pitch shifts
*/
