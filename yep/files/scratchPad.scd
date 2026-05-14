/*
Project Title: myLastName_Assignment_2b
Date: Wed Apr 15 17:21:21 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
scratch here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
_scratchPad_ is the place to write test / scratch code, testing out ideas and
working on code that we'll later formally include in the project.

Work through these blocks top-to-bottom. Each block is self-contained.
Prerequisites: evaluate data.scd fully before starting here.
*/

/////////////// explore interaction with sclang & interpreter ///////////////

// -------------------------
// load functions

(Document.current.dir +/+ "functions.scd").load;

currentEnvironment.keys;


// -------------------------
// load data

// (data.scd must have already been evaluated to populate ~saxData / ~wtBufs)

// inspect
~saxData.keys;
~saxData[\wtBufs].size;          // should be 3
~saxData[\fundamentalFreq];      // 440.0


// -------------------------
// inspect data

~saxData[\snapTimes];            // [ 1.0, 5.5, 9.0 ]
~saxData[\snapData][0];          // pp onset harmonics
~saxData[\snapData][1];          // ff peak harmonics
~saxData[\snapData][2];          // pp decay harmonics


/////////////// explore interaction with scsynth & interpreter ///////////////


// -------------------------
// load synthDefs (& ctkProtoNotes)

(Document.current.dir +/+ "synthDefs.scd").load;

currentEnvironment.keys;


// -------------------------
// list project synthDefs

~myProtoNotes.keys;   // should contain \synthDef_msWT


// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;


// -------------------------
// prepare wavetable(s) for synthesis

// confirm wavetable buffers are loaded
~wtBufs = ~saxData[\wtBufs];
~wtBufs.do({ |buf, i| "buf %: bufnum = %".format(i, buf.bufnum).postln });


// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;


// ── Audition each wavetable individually ──────────────────────────────────
// Hear the spectral difference between pp and ff snapshots:

{ Osc.ar(~wtBufs[0].bufnum, 440) * 0.12 ! 2 }.play;   // pp onset
s.freeAll;

{ Osc.ar(~wtBufs[1].bufnum, 440) * 0.12 ! 2 }.play;   // ff peak
s.freeAll;

{ Osc.ar(~wtBufs[2].bufnum, 440) * 0.12 ! 2 }.play;   // pp decay
s.freeAll;


// ── Manual LinSelectX sweep — hear the spectral transition ─────────────────
// Sweeps pp → ff → pp over 8 seconds:
(
    {
        var sel = EnvGen.kr(
            Env([ 0, 1, 2 ], [ 4, 4 ], \sin),
            doneAction: Done.freeSelf
        );
        var sig = LinSelectX.ar(sel, [
            Osc.ar(~wtBufs[0].bufnum, 440),
            Osc.ar(~wtBufs[1].bufnum, 440),
            Osc.ar(~wtBufs[2].bufnum, 440)
        ]);
        sig * 0.15 ! 2
    }.play
);


// ── Play the full \synthDef_msWT model via CtkNote ─────────────────────────
(
    ~myProtoNotes[\synthDef_msWT].note(
        starttime: 0.0,
        duration:  9.5
    )
    .dur_(9.5)
    .gain_(-12.0)
    .freq_(440.0)
    .fundamentalFreq_(440.0)
    .riseTime_(0.10)
    .decayTime_(0.30)
    .crescTime_(4.2)
    .decrescTime_(4.6)
    .vibratoRate_(5.5)
    .vibratoDepth_(0.40)
    .vibratoDelay_(0.80)
    .vibratoOnset_(0.60)
    .pitchNoise_(0.08)
    .wtSelLead_(0.30)
    .buf0_(~wtBufs[0].bufnum)
    .buf1_(~wtBufs[1].bufnum)
    .buf2_(~wtBufs[2].bufnum)
    .panAngle_(0.0)
    .outBus_(0)
    .play(s);
);


// ── Experiment: vary wtSelLead ─────────────────────────────────────────────
// 0.0 = spectrum and amplitude move together
// 0.5 = spectrum leads by half a second (try this vs 0.0 — audible difference)
(
    ~myProtoNotes[\synthDef_msWT].note(starttime: 0.0, duration: 9.5)
    .dur_(9.5).gain_(-12.0)
    .freq_(440.0).fundamentalFreq_(440.0)
    .riseTime_(0.10).decayTime_(0.30)
    .crescTime_(4.2).decrescTime_(4.6)
    .vibratoRate_(5.5).vibratoDepth_(0.40)
    .vibratoDelay_(0.80).vibratoOnset_(0.60)
    .pitchNoise_(0.08)
    .wtSelLead_(0.0)   // ← change me: try 0.0, 0.3, 0.6
    .buf0_(~wtBufs[0].bufnum)
    .buf1_(~wtBufs[1].bufnum)
    .buf2_(~wtBufs[2].bufnum)
    .panAngle_(0.0).outBus_(0)
    .play(s);
);


// ── Transpose to different pitches ────────────────────────────────────────
// D4 — below the recording pitch
(
    ~myProtoNotes[\synthDef_msWT].note(starttime: 0.0, duration: 6.0)
    .dur_(6.0).gain_(-12.0)
    .freq_(293.66).fundamentalFreq_(440.0)
    .riseTime_(0.08).decayTime_(0.25)
    .crescTime_(2.4).decrescTime_(2.7)
    .vibratoRate_(5.5).vibratoDepth_(0.35)
    .vibratoDelay_(0.70).vibratoOnset_(0.50)
    .pitchNoise_(0.08).wtSelLead_(0.25)
    .buf0_(~wtBufs[0].bufnum)
    .buf1_(~wtBufs[1].bufnum)
    .buf2_(~wtBufs[2].bufnum)
    .panAngle_(0.0).outBus_(0)
    .play(s);
);

// D5 — above the recording pitch
(
    ~myProtoNotes[\synthDef_msWT].note(starttime: 0.0, duration: 6.0)
    .dur_(6.0).gain_(-12.0)
    .freq_(587.33).fundamentalFreq_(440.0)
    .riseTime_(0.08).decayTime_(0.25)
    .crescTime_(2.4).decrescTime_(2.7)
    .vibratoRate_(5.5).vibratoDepth_(0.35)
    .vibratoDelay_(0.70).vibratoOnset_(0.50)
    .pitchNoise_(0.08).wtSelLead_(0.25)
    .buf0_(~wtBufs[0].bufnum)
    .buf1_(~wtBufs[1].bufnum)
    .buf2_(~wtBufs[2].bufnum)
    .panAngle_(0.0).outBus_(0)
    .play(s);
);


// when we're all finished, we should "clean up" and free up the space buffers use on the server

// free... when finished...
s.freeAll;
