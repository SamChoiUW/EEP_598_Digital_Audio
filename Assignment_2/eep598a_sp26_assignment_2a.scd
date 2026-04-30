/*
Project Title: Assignment 2a
Date: Wed Apr 15 13:18:14 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 2a explores leverages spectral data from the _Sandell Harmonic Archive_, aka SHARC,
to model instrumental tones via Additive and Table Based synthesis techniques.

Three possible problems are listed; complete ONE.

*/

/*
Start by downloading the resource found on the Canvas link for Assignment 2a:

• myLastName_assignment_2a

*/

/*
Unzip myLastName_assignment_2a and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

Specify which problem you are addressing in the README

You may choose to demonstrate your solution via the realtime server in scratchPad.scd OR the non-realtime server in main.scd.

*/





/*
---------------------------------
_Sandell Harmonic Archive_, aka SHARC

HelpBrowser.openLink("link::Tutorials/Data/SHARCData::")



For each of the SHARC modelling problems:

• Choose a suitable SHARC instrument spectral model, e.g., cello_vibrato for problem 1a) OR English_horn for probelem 2a).

• Audition a related instrument tone from one of the Musical Instrument Libraries (listed at end of this page) to establish a possible ground truth synthesis target.

• Include an appropriate form of pitch portamento, random pitch deviation, vibrato and/or tremolo in synthDef design for increased realism and liveliness.
· See D&J figure 5.12
· See D&J figure 5.13
· See Vibrato UGen.

• Use appropiate amplitude and / or modulation index envelope(s) to approximate instrumental dynamics.

• Synthesize a one octave ascending major scale, key of your choice.
· For each instrumental note, eight for a major scale, a separate SHARC .spect spectrum will be required.



EXAMPLES to review:

- Project: SHARC Wavetables & Wave Packets
-- HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")

- projectSimpleAS.zip
-- https://canvas.uw.edu/courses/1883740/modules/items/26406283

- additiveBasisFuncs.scd
-- https://canvas.uw.edu/courses/1883740/modules/items/26384167

- TBD: see also Canvas



Choose ONE problem to complete:

__
1a) Model a string ensemble sound via Single Sinusoid Additive Synthesis

- Single Sinusoid Additive Synthesis synthesizes each partial via a separate oscillator. Reference projectSimpleAS as a model to begin with.

- Choose one (or more) of the alternative sinusoidal basis functions found in additiveBasisFuncs.

- Promote relevant parameters as arguments (synthDef and/or additiveFunc) for synthesis.

- For the end of the tone, make the length of partials _frequency dependent_, with higher partials ending sooner.
-- The scoring function should handle this aspect.

- You may like to render more than one ascending scale to demonstrate a range of outcomes.


__
2a) Model brass instrument tone modulating spectra via Amplitude (or Power) Normalized Quadrature Waveshaping Synthesis.

- Quadrature Waveshaping synthesizes the amplitude AND phase of the specified spectrum, but requires TWO waveshaping tables to do so.

- Normalized Waveshaping requires additional normalization table(s).

- Amplitude Normalized Quadrature Waveshaping Synthesis allows the separation of BOTH the amplitude envelope AND the waveshaping modulation index envelope. The synthDef should include separate multi-segment envelopes for these, as well as appropriate envelope shapes.

- You may like to render more than one ascending scale to demonstrate a range of outcomes.


HelpBrowser.openLink("link::Tutorials/Getting Going/WSSynths#Sums of Cosines & Sines::")
HelpBrowser.openLink("link::Classes/Signal::#-normalizeShaperTU")


__
3a) Model instrumental stocastic / periodic modulating spectra via Wave Packet Table Synthesis

- Wave Packet Table Synthesis can synthesize BOTH periodic tones AND shaped noise.

- Choose an instrumental tone that is expected to include modulating elements of periodic tone and noise. Likely candidates include flute tones AND string tones.

- Implement a synthDef which generates Wave Packet Table Synchronous (pitched) and Asynchronous (noisy) Granular Synthesis, and includes an envelope to control the balance between the two.

- You may like to render more than one ascending scale to demonstrate a range of outcomes.


HelpBrowser.openLink("link::Tutorials/Getting Going/WPSynths::#Table Read Wave Packets")

*/


/*
---------------------------------
Musical Instrument Libraries


HelpBrowser.openLink("link::Tutorials/Data/SHARCData::")
HelpBrowser.openLink("link::Tutorials/Data/MIS::")

NOTE:
- to access the University of Iowa Musical Instrument Samples (MIS) library, use the Internet Archive Wayback Machine
-- https://web.archive.org
*/