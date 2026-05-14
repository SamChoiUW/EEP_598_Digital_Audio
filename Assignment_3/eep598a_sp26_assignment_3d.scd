/*
Project Title: Assignment 3d
Date: Mon May  4 13:52:09 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 3d explores implementing Time Domain Transposition Techniques.

Similar to Assignment 3b, but this time implement transposition via PitchShiftPA,
a Phase-Aligned Pitch and Formant Shifter.

Author a synthDef which will synthesize a descending
Ptolemaic sequence, aka Ptolemy's intense diatonic scale, given a single instrumental
source tone. (Use the same source tone as 3b.)

ALSO, implement a second formant shift, rather than pitch shift scale, using the same
descending Ptolemaic sequence ratios.


Descending ratios:
1:1, 15:16, 5:6, 3:4, 2:3, 5:8, 9:16, 1:2  // do, ti, la, sol, fo, mi, re, do


https://en.wikipedia.org/wiki/Ptolemy%27s_intense_diatonic_scale
*/

/*
Start by downloading the resource found on the Canvas link for Assignment 3d:

• myLastName_assignment_3d

*/

/*
Unzip myLastName_assignment_3d and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

*/

/*
The London Philharmonia (https://philharmonia.co.uk/resources/sound-samples/) library,
which contains single channel _mono_ recordings.

Choose a single instrumental tone to process. (Use the same source tone as 3b.)
*/

/*
Implement implement a single synthDef similar to those found in Assignment 3b, but where
the transposition is synthesized through the use of PitchShiftPA.

As well as _refFreq_ and _minRefFreq_, expose _pitchRatio_ and _formantRatio_ as synthDef
arguments.

*/

/*

Synthesize _two_ descending "scales".

• for the first, pass the descending ratios to _pitchRatio_
• for the second, pass the descending ratios to _formantRatio_

NOTE: the second "scale" will return a sequence of formant shifts rather than pitch shifts
*/
