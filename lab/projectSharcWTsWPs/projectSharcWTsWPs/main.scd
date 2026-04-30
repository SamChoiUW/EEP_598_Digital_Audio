/*
Project Title: projectSharcWTsWPs
Date: Tue Apr 21 13:31:32 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
do stuff here
*/

/*
_main_ is where we'll organize the "main" tasks of our project.

Here we'll generate wavetables and wave packets from data.

We'll then generate the same sequence of notes, once with a collect of wavetables and then with wave packets.

Two soundfiles will be synthesized, one for each sequence.

*/


///////////////// load functions, data & synthDefs ///////////////

/*
If we haven't already, we'll want to load functions, data and synthDefs.

*/

(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "data.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

/*
Open to inspect:

Document.open(Document.current.dir +/+ "functions.scd")
Document.open(Document.current.dir +/+ "data.scd")
Document.open(Document.current.dir +/+ "synthDefs.scd")
*/


///////////////// set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
    "% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
}, {
    s.sampleRate.asInteger
});
~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;  // stereo --> 2 channels
~headerFormat = "WAV";                    // soundfile header format
~sampleFormat = "int24";                  // soundfile sample format

// two output files....
~wavetableOutputFilePath = PathName.new(
    "%/%/_%WT.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);
~wavePacketOutputFilePath = PathName.new(
    "%/%/_%WP.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);


///////////////// set scoring parameter values //////////////////

/*
Here we'll:

0) initial prep
1) collect wavetable buffers
2) collect wavepacket buffers
3) create score for \dxarts46x_dodgeJerse_fig_4_5_wavetable; wavetable scale
4) create score for \dxarts46x_dodgeJerse_fig_4_5_wavepacket; wave packet scale
5) render wavetable & wave packet scores
6) when finished, free buffers...
*/

// 0) preparatory
~wavetableSize = 8192;
~pitchNames = [ 'd2', 'e2', 'f#2', 'g2', 'a2', 'b2', 'c#3', 'd3' ];
~instrNames = [ \bassoon, \bassClar ];


// 1) collect arrays of wavetable buffers (as CtkBuffer)
/*
We'll collect all wavetables in a Dictionary of Arrays.
Arrays of buffers are in ~pitchNames order.
*/

// collect \bassClar & \bassoon wavetables
~wavetableDict = ~myBufferFuncs[\fillWavetables].value(~wavetableSize, ~instrNames, ~pitchNames, ~mySharcData);



// 2) collect arrays of wave packet buffers (as CtkBuffer)
/*
We'll collect all wave packets in a Dictionary of Arrays.
Arrays of buffers are in ~pitchNames order.

NOTE: we'll only collect ONE wave packet for each instrument... we could collect more, but one is fine
*/

// collect \bassClar & \bassoon wave packets
// ~wavePacketDict = ~myBufferFuncs[\fillWavePackets].value(~wavetableSize, ~instrNames, [ 'd2' ], ~mySharcData);  // first - d2
// ~wavePacketDict = ~myBufferFuncs[\fillWavePackets].value(~wavetableSize, ~instrNames, [ 'd3' ], ~mySharcData);  // last - d3
~wavePacketDict = ~myBufferFuncs[\fillWavePackets].value(~wavetableSize, ~instrNames, [ 'a2' ], ~mySharcData);  // middle - a2



// 3) create CtkScore for wavetable scale

// create wavetable score
~wavetableScore = CtkScore.new;

// add \bassoon wavetable bufers to the score
~wavetableDict[\bassoon].do({ |item|
    ~wavetableScore.add(item)
});

// add \bassClar wavetable bufers to the score
~wavetableDict[\bassClar].do({ |item|
    ~wavetableScore.add(item)
});

/*
NOTE: we could have iterated through ~wavetableDict to add the wavetable bufers
*/

// generate and add \bassoon notes
~wavetableScore.add(
    ~myWTScoringFuncs[\simpleScale].value(
        start: 0.0,
        noteGain: -6.0,
        freqs: ~mySharcData[\bassoon].atAll(~pitchNames).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        // freqs: [ 73.195, 82.353, 92.356, 97.783, 109.701, 123.357, 138.462, 146.755 ],  // ... or directly specify
        bufnums: ~wavetableDict[\bassoon].collect({ |item| item.bufnum }),  // array of buffer numbers
        ctkProtoNotes: ~myWTWPPNotes
    )
);


// generate and add \bassClar notes
~wavetableScore.add(
    ~myWTScoringFuncs[\simpleScale].value(
        start: 9.0,
        noteGain: -6.0,
        freqs: ~mySharcData[\bassClar].atAll(~pitchNames).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        // freqs: [ 73.195, 82.662, 91.971, 98.218, 109.975, 123.013, 138.028, 146.269 ],  // ... or directly specify
        bufnums: ~wavetableDict[\bassClar].collect({ |item| item.bufnum }),  // array of buffer numbers
        ctkProtoNotes: ~myWTWPPNotes
    )
);

// let's see the notes
~wavetableScore.ctkscores;  // we actually have two scores, one for each scale

~wavetableScore.ctkscores.do({ |item|
    ~myScoreFuncs[\postNotes].value(item)
});



// 4) create CtkScore for wave packet scale

// create wavetable score
~wavePacketScore = CtkScore.new;

// add \bassoon wavetable bufers to the score
~wavePacketDict[\bassoon].do({ |item|
    ~wavePacketScore.add(item)
});

// add \bassClar wavetable bufers to the score
~wavePacketDict[\bassClar].do({ |item|
    ~wavePacketScore.add(item)
});


// generate and add \bassoon notes
~wavePacketScore.add(
    ~myWPScoringFuncs[\simpleScale].value(
        start: 0.0,
        noteGain: -6.0,
        freqs: ~mySharcData[\bassoon].atAll(~pitchNames).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        refFreqs: ~mySharcData[\bassoon].atAll([ \a2 ]).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        bufnums: ~wavePacketDict[\bassoon].collect({ |item| item.bufnum }),
        ctkProtoNotes: ~myWTWPPNotes
    )
);


// generate and add \bassClar notes
~wavePacketScore.add(
    ~myWPScoringFuncs[\simpleScale].value(
        start: 9.0,
        noteGain: -6.0,
        freqs: ~mySharcData[\bassClar].atAll(~pitchNames).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        refFreqs: ~mySharcData[\bassClar].atAll([ \a2 ]).collect({ |item| item[\refFreq] }),  // collect freqs from ~mySharcData...
        bufnums: ~wavePacketDict[\bassClar].collect({ |item| item.bufnum }),
        ctkProtoNotes: ~myWTWPPNotes
    )
);


// let's see the notes
~wavePacketScore.ctkscores;  // we actually have two scores, one for each scale

~wavePacketScore.ctkscores.do({ |item|
    ~myScoreFuncs[\postNotes].value(item)
});



// 5) render wavetable and wave packet scores

// write score to sound file with the -write message, and then open with helper score function, \scoreWriteOpenSFPlayer
(
~wavetableScore.write(
    path: ~wavetableOutputFilePath.fullPath,
    sampleRate: ~sampleRate,
    headerFormat: ~headerFormat,
    sampleFormat: ~sampleFormat,
    options: ~serverOptions,
    action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~wavetableOutputFilePath)
)
);
(
~wavePacketScore.write(
    path: ~wavePacketOutputFilePath.fullPath,
    sampleRate: ~sampleRate,
    headerFormat: ~headerFormat,
    sampleFormat: ~sampleFormat,
    options: ~serverOptions,
    action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~wavePacketOutputFilePath)
)
);

/*
NOTE:

we could synthesize and then open "by hand"...
*/
/*
(
~mainScore.write(
    path: ~wavetableOutputFilePath.fullPath,
    sampleRate: ~sampleRate,
    headerFormat: ~headerFormat,
    sampleFormat: ~sampleFormat,
    options: ~serverOptions,
)
);

// wait until final nextOSCPacket is posted...
"Wait until nextOSCPacket % is posted before opening SFPlayer.".format(Score.new(~wavetableScore.score).endTime).postln;

// ... open in SFPlayer...
SFPlayer.new(~wavetableOutputFilePath.fullPath).gui;
*/



// 6) when finished, free buffers...
/*
it is always good practice to free up buffers when finished!!
- if we want to continue modifying the scores, it is fine to leave the buffers loaded
*/

/*
NOTE:

If we've only used the non-realtime server, this step is not necessary.

For instance, if we've only used -write rather than -play, we don't need to free buffers.

*/

// // to free... when finished...
// ~instrNames.do({ |instrName|
//     ~wavetableDict[instrName].do({ |buffer|
//         buffer.free
//     });
//     ~wavePacketDict[instrName].do({ |buffer|
//         buffer.free
//     })
// });
  