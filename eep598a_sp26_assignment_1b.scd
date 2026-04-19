/*
Project Title: Assignment 1
Date: Sun Mar 29 16:35:26 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
This second part of Assignment 1 is about updating the single (or dual) oscillator per note event
additive synthesis example found in projectSimpleRissetBell to include two more bell spectra measured
by Slaymaker & Meeker.

*/

/*
Start by downloading the two resources found on the Canvas link for Assignment 1:

• Slaymaker, F. H., & Meeker, W. F. (1954). Measurements of the Tonal Characteristics of Carillon Bells. The Journal of the Acoustical Society of America, 26(4), 515–522. https://doi.org/10.1121/1.1907368

• myLastName_assignment_1b

*/

/*
Unzip myLastName_assignment_1b and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

*/

/*
Evaluate main.scd and then audition the two synthesized bells. (Both using spectra, SV1 0 1700.)

The first of these is synthesized with a single oscillator per partial, the second uses
\dxarts46x_percSinOscQ, which has a quadrature pair of oscillators, instead.
*/

/*
Review Table II and Table VI found in the Slaymaker & Meeker text.

Our goal is to synthesize the spectra of the two bells found here. To do so, we'll need to
translate the data found in these two examples to:

	\ratios,
	\beatFreqs,
	\gains,
	\durScales,

Examining data.scd, we'll see some placeholder notes, as well as commented out assignment statements:

~myBellData['germantown_a#4'] =

~myBellData['valley_forge_a#4'] =

Build the new Dictionaries for germantown_a#4 and valley_forge_a#4 data here.
*/

/*
On examining fig. 2, p. 516, we'll see that the measured bell partial envelops actually fluctuate.
This is due to slightly detuned beating frequencies, which Slaymaker & Meeker don't notate. (For their
analysis, Slaymaker & Meeker loop and reverse their recorded bell samples. That's why we see repeated
rising rather than falling envelopes.)

If we want our bell to sound lively, we'll need to add some extra beating partials. We can use Risset's
model, where the lowest ("hum") and the next highest ("prime" or "strike") partials beat. If we like, we
can add more beating partials for more liveliness.

In fig. 2 we can see that the "strike" tone beats with a period of 7-8 seconds. The beat freq offset
would then be the reciprocal of that.
*/

/*
Once the new bell spectra dictionaries have been built, synthesize three new bell tones as noted in main.scd
*/
