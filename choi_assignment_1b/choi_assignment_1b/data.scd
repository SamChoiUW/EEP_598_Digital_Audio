/*
Project Title: myLasName Assignment 1b
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
data here
*/

// -------------------------
// instantiate dictionaries
~myBellData = Dictionary.new;


// -------------------------
// add associations

// -------------
// ~myBellData

/*
HelpBrowser.openLink("link::Tutorials/Data/JCRBellData::")
*/

/*
from Risset's _Inharmonique_

D&J p. 105, figure 4.28
D&J p. 111, SV1 0 1210

freq = 400.0
11 partials
*/
~myBellData[\rissetBell_1210] = Dictionary.newFrom([
	\ratios,
	[ 0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2.0, 2.74, 3.0, 3.76, 4.07 ],

	\beatFreqs,
	[ 0.0, 1.0, 0.0, 1.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],

	\gains,
	[ 0.0, -3.5, 0.0, 5.1, 8.5, 4.5, 3.3, 2.5, 2.5, 0.0, 2.5 ],

	\durScales,
	[ 1.0, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075 ],

	\names,
	[ "hum", "hum (beating)", "prime", "prime (beating)", "tierce", nil, "nominal", "(undeciem)", "duodeciem", nil, "double octave" ]
]);


/*
from Risset's _Inharmonique_

D&J p. 111, SV1 0 1700

freq = 89.29 (nominally)
freq = 178.57 (subjectively)
13 partials
*/
~myBellData[\rissetBell_1700] = Dictionary.newFrom([
	\ratios,
	[ 0.2, 0.46, 0.46, 0.93, 1.12, 1.92, 2.39, 2.81, 5.02, 7.31, 8.42, 9.54, 12.35 ],  // subjectively

	\beatFreqs,
	[ 0.0, -0.1422, 0.2578, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],  // subjectively

	\gains,
	[ -10.5, 0.0, -2.5, 0.0, 3.5, 0.0, -2.5, 0.0, -12.0, -14.0, -12.0, -10.5, -14.0 ],

	\durScales,
	[ 0.75, 1.0, 0.85, 1.0, 0.75, 0.3, 0.25, 0.35, 0.2, 0.1, 0.05, 0.2, 0.075 ],

	\names,
	[ "(sub hum)", "hum (beating)", "hum (beating)", "prime", "tierce", "nominal", "deciem", "duodeciem", "double deciem", nil, nil, nil, nil ]
]);


/*
Slaymaker, F. H., & Meeker, W. F. (1954). Measurements of the Tonal Characteristics of Carillon Bells.
The Journal of the Acoustical Society of America, 26(4), 515–522.

Table II., p. 517

freq = 459.8
13 partials specified, add at least 2 more beating partials for liveliness --> 15+ partials total!!
*/
// ~myBellData['germantown_a#4'] =
~myBellData['germantown_a#4'] = Dictionary.newFrom([
    \ratios,
    [ 0.499, 0.499, 0.995, 0.995, 1.179, 1.507, 1.989, 2.496, 2.962, 3.564, 4.103, 4.686, 5.351, 5.795, 6.679 ],  // subjectively

    \beatFreqs,
    [ 0.0, -0.1422, 0.0 ,0.2578, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],  // subjectively

    \gains,
    [ -10.0, -10.0, 0.0, 0.0, 3.0, -25.0, 16.0, -12.0, 0.0, -15.0, 2.0, -2.0, 1.0, -2.0, 4.0 ],

    \durScales,
    [ 1.0, 1.0, 0.34, 0.34, 0.29, 0.10, 0.07, 0.09, 0.11, 0.06, 0.09, 0.03, 0.15, 0.04, 0.08 ],

    \names,
    ["hum","hum (beating)", "prime", "prime (beating)", "tierce", "nominal", "deciem", "duodeciem", "double deciem", nil, nil, nil, nil,nil,nil]
]);
/*
Slaymaker, F. H., & Meeker, W. F. (1954). Measurements of the Tonal Characteristics of Carillon Bells.
The Journal of the Acoustical Society of America, 26(4), 515–522.

Table VI., p. 518

freq = 462.7
12 partials specified, add at least 2 more beating partials --> 14+ partials total!!
*/
// ~myBellData['valley_forge_a#4'] =

~myBellData['valley_forge_a#4'] = Dictionary.newFrom([
    \ratios,
	[ 0.502, 0.502, 1.000, 1.000, 1.196, 1.503, 2.006, 2.438, 3.019, 3.289, 4.176, 5.443, 6.798, 8.220 ],
    \beatFreqs,
    [ 0.0, -0.1422, 0.0 ,0.2578, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],  // subjectively

    \gains,
	[ 3.0, 3.0, 0.0, 0.0, 2.0, -16.0, 11.0, 13.0, 16.0, 1.0, 6.0, 8.0, 6.0, 2.0 ],

    \durScales,
	[ 1.00, 1.00, 0.275, 0.275, 0.368, 0.128, 0.0746, 0.0147, 0.117, 0.0699, 0.0932, 0.0874, 0.0823, 0.0667 ],

    \names,
	[ "hum", "hum (beating)", "prime", "prime (beating)", "tierce", "nominal", "deciem", "duodeciem", "double deciem", nil, nil, nil, nil, nil ]
]);