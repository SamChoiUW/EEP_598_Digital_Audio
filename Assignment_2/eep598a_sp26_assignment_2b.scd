/*
Project Title: Assignment 2b
Date: Wed Apr 15 13:18:14 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: ECE, University of Washington (https://www.ece.uw.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

// -------------------------------------------------------------------------------------------
/*
Assignment 2b explores modelling instrumental tones found in published Musical Instrument Libraries
via Table Based synthesis techniques.

Three possible problems are listed; complete ONE.

*/

/*
Start by downloading the resource found on the Canvas link for Assignment 2b:

• myLastName_assignment_2b

*/

/*
Unzip myLastName_assignment_2b and rename the folder, replacing _myLastName_ with your own.

Next update the Project Title field in _each page_ header to list your own last name.

Specify which problem you are addressing in the README

You may choose to demonstrate your solution via the realtime server in scratchPad.scd OR the non-realtime server in main.scd.

*/





/*
---------------------------------
Musical Instrument Libraries


HelpBrowser.openLink("link::Tutorials/Data/SHARCData::")
HelpBrowser.openLink("link::Tutorials/Data/MIS::")

NOTE:
- to access the University of Iowa Musical Instrument Samples (MIS) library, use the Internet Archive Wayback Machine
-- https://web.archive.org



For each of the Musical Instrument Library modelling problems:

• Choose a suitable instrument tone recording from either the Iowa Musical Instrument Samples (MIS) or London Philharmonia Libraries.
· Be sure to include this source in your project _sounds_ folder

• Include an appropriate form of pitch portamento, random pitch deviation, vibrato and/or tremolo in synthDef design for increased realism and liveliness.
· See D&J figure 5.12
· See D&J figure 5.13
· See Vibrato UGen.

• Use appropiate amplitude, modulation index envelope and / or table selection envelopes(s) to approximate instrumental dynamics.



EXAMPLES to review:

- Project: SHARC Wavetables & Wave Packets
-- HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")

- TBD: see also Canvas



Choose ONE problem to complete:

__
1b) Model a _long_ spectrally modulating instrument tone via multi-segment Wavetable Synthesis

- Choose an instrument tone from the London Philharmonia Library which includes _cresc-decresc_ as part of it's file name. E.g.:
-- bassoon_As2_very-long_cresc-decresc_normal.mp3
-- contrabassoon_E2_very-long_cresc-decresc_normal.mp3
-- cor-anglais_As3_phrase_cresc-decresc_normal.mp3
-- saxophone_A4_very-long_cresc-decresc_normall.mp3

- Determine a nominal number of points in time at which to sample the instrument spectra. A larger number likely returns a more convincing result.

- Sample the spectra at each point, and create relevant wavetables.

- Design a synthDef which interpolates through these wavetables.
-- See: SelectX or LinSelectX

- The synthDef should include separate multi-segment envelopes for amplitude, AND for wavetable selection.


HelpBrowser.openLink("link::Tutorials/Getting Going/WTOscs::#Osc")


__
2b) Model plucked string instrument tone modulating spectra via Amplitude (or Power) Normalized Quadrature Waveshaping Synthesis AND sound sample playback.

- Choose a plucked instrument tone from a Musical Instrument Library

- Quadrature Waveshaping synthesizes the amplitude AND phase of the specified spectrum, but requires TWO waveshaping tables to do so.

- Normalized Waveshaping requires additional normalization table(s).

- Amplitude Normalized Quadrature Waveshaping Synthesis allows the separation of BOTH the amplitude envelope AND the waveshaping modulation index envelope. The synthDef should include separate multi-segment envelopes for these, as well as appropriate envelope shapes, e.g., consider Env:*perc.

- Determine a nominal _single_ point in time at which to sample the instrument spectra.

- Sample the spectra, and create relevant distortion and distortion normalization tables.


- Design a synthDef which plays the initial onset / attack of chosen tone, followed by a waveshaping tone, with _string like_ decaying partials and amplitude envelope.
-- Both the amplitude and distortion index envelopes will likely be -perc or otherwise exponential.


HelpBrowser.openLink("link::Tutorials/Getting Going/WSSynths#Sums of Cosines & Sines::")
HelpBrowser.openLink("link::Classes/Signal::#-normalizeShaperTU")


__
3b) Model instrumental stocastic / periodic modulating spectra via multi-segment Wave Packet Table Synthesis

- Wave Packet Table Synthesis can synthesize BOTH periodic tones AND shaped noise.

- Choose an instrumental tone that is expected to include modulating elements of periodic tone and noise. Likely candidates include flute tones AND string tones.

- Determine a nominal number of points in time at which to sample the instrument spectra. A larger number likely returns a more convincing result.

- Sample the spectra at each point, and create relevant wave packet tables.

- Design a synthDef which interpolates through these wave packet tables.
-- See: SelectX or LinSelectX

- The synthDef should include separate multi-segment envelopes for amplitude, wave packet selection AND Synchronous (pitched) vs Asynchronous (noisy) Granular Synthesis.


HelpBrowser.openLink("link::Tutorials/Getting Going/WPSynths::#Table Read Wave Packets")

*/
