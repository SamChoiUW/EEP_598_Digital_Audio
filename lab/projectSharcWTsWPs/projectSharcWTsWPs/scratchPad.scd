/*
Project Title: projectSharcWTsWPs
Date: Tue Apr 21 13:31:32 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
scratch here
*/

/*
_scratchPad_ is the place to write test / scratch code, testing out ideas and
working on code that we'll later formally include in the project.

Here, we'll do some simple tests with sclang and scsynth:

- sclang:
-- load functions and data, and inspect

- scsynth:
-- load synthDefs and inspect arguments
-- generate wavetable(s) and wave packet(s) from data and load buffers on the realtime server
-- synthesize tones (via -note), on the realtime server
-- remove buffers from the realtime server


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
~mySharcData;  // a dictionary of dictionaries

~mySharcData.keys;  // two keys

~mySharcData[\bassoon];  // SHARC bassoon data
~mySharcData[\bassClar];  // SHARC bass clarinet data
/*
HelpBrowser.openLink("link::Tutorials/Data/SHARCData::")
*/

~mySharcData[\bassoon].keys;  // keys to the bassoon data

~mySharcData[\bassoon][\e2];  // ... another dictionary, for a single pitch, \e2

~mySharcData[\bassoon][\e2].keys;  // keys to individual pitch data dict

// inspect by iteration...
(
~mySharcData[\bassoon][\e2].associationsDo({ |assoc|
    "% = %".format(assoc.key, assoc.value).postln
});
"".postln;
);

/*
The spectral data found in harmsAmpsPhases will be used to build both wavetables and wave packets!

The following two functions will do the job:
*/
~myBufferFuncs[\fillWavetables].postcs;
~myBufferFuncs[\fillWavePackets].postcs;


// while we won't them here, we have two more functions in this project for generating scores
/*
this page, scratchPad, is a good place to try playing around with these functions, if you like
*/
~myWTScoringFuncs[\simpleScale].postcs;
~myWPScoringFuncs[\simpleScale].postcs;



/////////////// explore interaction with scsynth & interpreter ///////////////

/*
Here we'll play around with synthesizing sound on the realtime server.

We'll start by reviewing the project synthDefs and their arguments.

Next, we'll generate wavetables(s) and wave packet(s) from data, and load on the realtime server.

We'll then synthesize single note events via wavetable and wave packet synthesis.

To finish, we'll remove buffers from the realtime server.
*/


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
(
"This project has % synthDef(s), named:\n".format(~myWTWPPNotes.synthdefs.size).postln;
~myWTWPPNotes.synthdefs.do({ |synthDef|
    ("\t" ++ synthDef.name.asString).postln
});
"".postln
);
/*
We have two!
*/


// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;


// let's inspect the arguments of each synthDef
(
~myWTWPPNotes.dict.do({ |item|
    item.args;
    "".postln
})
);

/*
\dxarts46x_dodgeJerse_fig_4_5_wavetable is the wavetable synthDef

\dxarts46x_dodgeJerse_fig_4_5_wavepacket is the wave packet synthDef

*/


// -------------------------
// prepare wavetable(s) and wave packet(s) for synthesis
/*
Both our synthdefs require buffers (see arg: bufnum) filled with either a
wavetable or wave packet.

Before synthesis, we need to prep these.

For now, we'll just use data for a single analyzed pitch from the bassoon data.
*/

~wavetableSize = 8192;
~pitchNames = [ 'a2' ];
~instrNames = [ \bassoon ];

// collect \bassoon wavetable
/*
we set the last two args to true loads the wavetable(s) into buffers(s) for realtime synthesis
*/
~wavetableDict = ~myBufferFuncs[\fillWavetables].value(~wavetableSize, ~instrNames, ~pitchNames, ~mySharcData, true, true);

~wavetableDict;
// we now have a dictionary... filled with a single wavetable buffer
/*
NOTE: For a single wavetable, this is a bit overkill, but is a good idea if we have a large collection of wavetables.
*/

// we can plot - the squizzles are because the table is in wavetable format
~wavetableDict[\bassoon][0].plot;


// now let's collect \bassoon wave packet
~wavePacketDict = ~myBufferFuncs[\fillWavePackets].value(~wavetableSize, ~instrNames, ~pitchNames, ~mySharcData, true, true);
~wavePacketDict;

// we can plot - we have an enveloped wave packet!
~wavePacketDict[\bassoon][0].plot;




// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;



// instantiate some notes
~noteWavetable = ~myWTWPPNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note;
~noteWavePacket = ~myWTWPPNotes[\dxarts46x_dodgeJerse_fig_4_5_wavepacket].note;

/*
NOTE:

since we're using rt server, no need to set duration, otherwise:

~noteWavetable = ~myWTWPPNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(duration: 1.0);

or, more verbosely set to default duration

~noteWavetable = ~myWTWPPNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].note(
duration: ~myWTWPPNotes[\dxarts46x_dodgeJerse_fig_4_5_wavetable].args(post: false)[\dur]
);
*/

// let's try playing...
~noteWavetable.play;
~noteWavePacket.play;

// these DON'T sound like a bassoon! - why?!?

// let's check which buffer they're using...
~noteWavetable.bufnum;
~noteWavePacket.bufnum;

// ... this is the \a2 wavetable in ~wavetableDict !
~wavetableDict[\bassoon][0].bufnum;

// AND they're both NOT playing at the wavetable's reference frequency
~mySharcData[\bassoon][\a2][\refFreq];

~noteWavetable.freq;  // should be -> 109.701
~noteWavePacket.freq;
~noteWavePacket.refFreq;  // should be -> 109.701

// let's fix that this, by
// - assigning correct buffers
// - assigning correct freqs

~noteWavetable.bufnum = ~wavetableDict[\bassoon][0].bufnum;
~noteWavePacket.bufnum = ~wavePacketDict[\bassoon][0].bufnum;

~noteWavetable.freq = ~mySharcData[\bassoon][\a2][\refFreq];
~noteWavePacket.freq = ~mySharcData[\bassoon][\a2][\refFreq];
~noteWavePacket.refFreq = ~mySharcData[\bassoon][\a2][\refFreq];

// now try playing...
~noteWavetable.play;
~noteWavePacket.play;

// hurrah! both sound the same... let's make them play longer...
~noteWavetable.dur = 5.0;
~noteWavePacket.dur = 5.0;

// ... play each separately
~noteWavetable.play;
~noteWavePacket.play;

// they both sound the same (whoopie?)


// the big difference comes when we choose another frequency to render at
~noteWavetable.freq = 2 * ~noteWavetable.freq;
~noteWavePacket.freq = 2 * ~noteWavePacket.freq;


// ... play each separately
~noteWavetable.play;
~noteWavePacket.play;

// notice what's happened?
/*
with the wavetable synthesis, we're just playing the wavetable faster, so the spectral envelope
is shifted

wave packet synthesis keeps the spectrum in the same place, and just shifts the pitch
*/

// if we like, we can shift the wave packet's spectrum to match the wavetable
~noteWavePacket.wavRatio = 2.0;

// ... play each separately
~noteWavetable.play;
~noteWavePacket.play;

/*
the power of wave packet synthesis is separation of the spectral envelope from periodic pitch!!
*/

// let's try an octave lower than the waveform reference frequency, for fun
// (and reset the wave packet wave ratio)
~noteWavetable.freq = 0.5 * ~mySharcData[\bassoon][\a2][\refFreq];
~noteWavePacket.freq = 0.5 * ~mySharcData[\bassoon][\a2][\refFreq];

~noteWavePacket.wavRatio = 1.0;


// ... play each separately
~noteWavetable.play;
~noteWavePacket.play;

/*
again, the wave packet synthesis sounds more natural

an advantage being, that for many tones we can get away with using fewer buffers if they're
filled with wave packets rather than wave tables
*/



// when we're all finished, we should "clean up" and free up the space buffers use on the server

// free... when finished...
~instrNames.do({ |instrName|
    ~wavetableDict[instrName].do({ |buffer|
        buffer.free
    });
    ~wavePacketDict[instrName].do({ |buffer|
        buffer.free
    })
});
  