/*
Project Title: Assignment 3b
Date: Mon May  4 13:52:09 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 3b explores implementing Time Domain Transposition Techniques.

Author a collection of synthDefs which will synthesize a descending
Ptolemaic sequence, aka Ptolemy's intense diatonic scale, given a single instrumental
source tone.

Descending ratios:
1:1, 15:16, 5:6, 3:4, 2:3, 5:8, 9:16, 1:2  // do, ti, la, sol, fo, mi, re, do


https://en.wikipedia.org/wiki/Ptolemy%27s_intense_diatonic_scale
*/

/*
Start by downloading the resource found on the Canvas link for Assignment 3b:

• myLastName_assignment_3b

*/

/*
Unzip myLastName_assignment_3b and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

*/

/*
The London Philharmonia (https://philharmonia.co.uk/resources/sound-samples/) library,
which contains single channel _mono_ recordings.

Choose a single instrumental tone to process.
*/

/*
Implement TWO versions of the required transposition synthDefs:

_downUp, where the "downward" integer frequency transposition occurs first, followed by the "upward" transposition.
_upDown, where the "upward" integer transposition takes place first, followed by the "downward".



A separate synthDef will be required to synthesize each ratio. E.g., synthDef names:

• ratio 1:1 --> \eep598_monoPlayBuf_downUp_1_1
• ratio 15:16 --> \eep598_monoPlayBuf_downUp_15_16
• ratio 5:6 --> \eep598_monoPlayBuf_downUp_5_6
...
• ratio 1:2 --> \eep598_monoPlayBuf_downUp_1_2

... and...

• ratio 1:1 --> \eep598_monoPlayBuf_upDown_1_1
• ratio 15:16 --> \eep598_monoPlayBuf_upDown_15_16
• ratio 5:6 --> \eep598_monoPlayBuf_upDown_5_6
...
• ratio 1:2 --> \eep598_monoPlayBuf_upDown_1_2

*/
/*

Synthesize the descending scale via _downUp transpostition, followed by the same scale
synthesized via _upDown transposition.

NOTE: Muller Puckett recommendes the former. Why??
*/

/*
In the end your project should synthesize two descending major scales, one following the other,
and should contain a total of 16 synthDefs.

*/



/*
NOTE:

_fundamental frequency division_

With a periodic tone, _division_ of the fundamental frequency (downward transposition)
can be returned by ring modulation (multiplication) with an appropriately designed waveform.

SEE: hannDivisions.scd


_fundamental frequency multiplication_

With a periodic tone, _division_ of the fundamental frequency (upward transposition)
can be returned by moving average comb filtering (spectral subtraction) with an
appropriately designed comb filter.

SEE: combMultiplications.scd
*/
