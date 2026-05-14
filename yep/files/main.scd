/*
Project Title: myLastName_Assignment_2b
Date: Wed Apr 15 17:21:21 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
_main_ is where we'll organize the "main" tasks of our project.

*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


///////////////// load functions, data & synthDefs ///////////////

/*
If we haven't already, we'll want to load functions, data and synthDefs.

Prerequisite: data.scd must have been fully evaluated first so that
~saxData and ~wtBufs are populated.
*/

s.boot;

(Document.current.dir +/+ "synthDefs.scd").load;
(Document.current.dir +/+ "functions.scd").load;
// data.scd is evaluated separately — ~saxData / ~wtBufs must already exist


///////////////// set RT/NRT environment variables ///////////////


~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
    "% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
	"setting SR to 48000".postln;
	48000
}, {
    s.sampleRate.asInteger
});
~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;  // stereo --> 2 channels
~headerFormat = "WAV";                    // soundfile header format
~sampleFormat = "int24";                  // soundfile sample format

~outputFilePath = PathName.new(
    "%/%/_%.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);



///////////////// set scoring parameter values //////////////////

/*
create score(s)...

Two scores are rendered back-to-back:

  Score A — single A4 tone, full cresc-decresc arc (~9.5 s)
            demonstrates the complete pp → ff → pp spectral evolution

  Score B — ascending D major scale (D4–D5), shorter notes (6 s each)
            shows the model transposed across a pitch range
*/

~fundamentalFreq = ~saxData[\fundamentalFreq];   // 440.0 Hz
~wtBufs          = ~saxData[\wtBufs];            // [ buf_pp, buf_ff, buf_pp ]

// shared parameters
~noteGain    = -12.0;
~riseTime    = 0.10;
~decayTime   = 0.30;
~vibRate     = 5.5;
~vibDepth    = 0.40;   // semitones
~vibDelay    = 0.80;
~vibOnset    = 0.60;
~pitchNoise  = 0.08;
~wtSelLead   = 0.30;

// ── Score A — single A4 tone ──────────────────────────────────────────────
~scoreDur    = 9.5;
~crescTime   = 4.2;
~decrescTime = 4.6;
// riseTime + crescTime + decrescTime + decayTime ≈ dur

~scoreA = ~myWTScoringFuncs[\singleTone].value(
    start:           0.0,
    dur:             ~scoreDur,
    gain:            ~noteGain,
    freq:            ~fundamentalFreq,
    fundamentalFreq: ~fundamentalFreq,
    riseTime:        ~riseTime,
    decayTime:       ~decayTime,
    crescTime:       ~crescTime,
    decrescTime:     ~decrescTime,
    vibratoRate:     ~vibRate,
    vibratoDepth:    ~vibDepth,
    vibratoDelay:    ~vibDelay,
    vibratoOnset:    ~vibOnset,
    pitchNoise:      ~pitchNoise,
    wtSelLead:       ~wtSelLead,
    wtBufs:          ~wtBufs,
    panAngle:        0.0,
    outBus:          0,
    ctkProtoNotes:   ~myProtoNotes
);

"Score A: % note(s)".format(~scoreA.notes.size).postln;

// ── Score B — ascending D major scale ─────────────────────────────────────
~scaleFreqs = [
    293.66,   // D4
    329.63,   // E4
    369.99,   // F#4
    392.00,   // G4
    440.00,   // A4  ← matches the recording exactly
    493.88,   // B4
    554.37,   // C#5
    587.33    // D5
];

~noteDur     = 6.0;
~noteGap     = 0.30;
~scoreBStart = ~scoreDur + 1.5;   // after Score A + 1.5 s gap

~scoreB = ~myWTScoringFuncs[\ascendingScale].value(
    start:           ~scoreBStart,
    noteDur:         ~noteDur,
    noteGap:         ~noteGap,
    gain:            ~noteGain,
    fundamentalFreq: ~fundamentalFreq,
    freqs:           ~scaleFreqs,
    riseTime:        ~riseTime,
    decayTime:       ~decayTime,
    crescTime:       nil,   // defaults to 40% of noteDur = 2.4 s
    decrescTime:     nil,   // defaults to 45% of noteDur = 2.7 s
    vibratoRate:     ~vibRate,
    vibratoDepth:    ~vibDepth,
    vibratoDelay:    ~vibDelay,
    vibratoOnset:    ~vibOnset,
    pitchNoise:      ~pitchNoise,
    wtSelLead:       ~wtSelLead,
    wtBufs:          ~wtBufs,
    panAngles:       nil,   // all centred
    outBus:          0,
    ctkProtoNotes:   ~myProtoNotes
);

"Score B: % note(s)".format(~scoreB.notes.size).postln;

// ── Merge into ~mainScore ─────────────────────────────────────────────────
~mainScore = CtkScore.new;
~scoreA.notes.do({ |n| ~mainScore.add(n) });
~scoreB.notes.do({ |n| ~mainScore.add(n) });

// add wavetable buffers so the NRT server has them
~wtBufs.do({ |buf| ~mainScore.add(buf) });

"Master score: % total note(s)".format(~mainScore.notes.size).postln;


///////////////// render the main score //////////////////


// write score to sound file with the -write message, and then open with helper score function, \scoreWriteOpenSFPlayer
(
    ~mainScore.write(
        path: ~outputFilePath.fullPath,
        sampleRate: ~sampleRate,
        headerFormat: ~headerFormat,
        sampleFormat: ~sampleFormat,
        options: ~serverOptions,
        action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~outputFilePath)
    )
);

/*
NOTE:

we could synthesize and then open "by hand"...
*/
/*
(
~mainScore.write(
path: ~outputFilePath.fullPath,
sampleRate: ~sampleRate,
headerFormat: ~headerFormat,
sampleFormat: ~sampleFormat,
options: ~serverOptions,
)
);

// wait until final nextOSCPacket is posted...
"Wait until nextOSCPacket % is posted before opening SFPlayer.".format(Score.new(~mainScore.score).endTime).postln;

// ... open in SFPlayer...
SFPlayer.new(~outputFilePath.fullPath).gui;
*/


// ... when finished, free buffers...
/*
it is always good practice to free up buffers when finished!!
- if we want to continue modifying the scores, it is fine to leave the buffers loaded
*/

/*
NOTE:

If we've only used the non-realtime server, this step is not necessary.

For instance, if we've only used -write rather than -play, we don't need to free buffers.

*/

/*
What to listen for
------------------
Score A (0:00 – ~0:10):
  Timbre begins sparse and thin (pp wavetable), swells to a bright rich
  spectrum at the ff peak, then thins back. The wtSelLead offset means
  the spectrum brightens just before the loudness peak — matching real
  saxophone behaviour. Vibrato enters after ~0.8 s.

Score B (~0:11 onwards):
  Each scale note has its own mini cresc-decresc arc. The A4 note is
  most accurate (exact match to the recording). Notes above and below
  A4 are transposed via playback rate; some inharmonicity at the
  extremes is expected with wavetable transposition.
*/
