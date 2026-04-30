/*
Project Title: myLastName_Assignment_1a
Date: Wed Apr 29 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
Problem 1a: Single Sinusoid Additive Synthesis — String Ensemble Model

SynthDef design notes
─────────────────────
• \addStringSingle  : core partial synthDef.
  One instance per partial, per note. The scoring function spawns N of
  these (N = number of SHARC partials) for each scale degree.

• Basis function: chosen via ~myData[\basisFunc]; the scoring function
  selects among the alternatives from additiveBasisFuncs:
    \pure             → SinOsc (reference)
    \detuneStereoBeat → detune in stereo (beats between L/R copies)
    \ringNoiseMono    → ring-mod with LFNoise2 in mono
    \fmNoiseStereo    → FM deviation with LFNoise2 in stereo

• Realism chain (signal path for each partial):
    1. Portamento   : Lag.kr on fundamental freq argument
    2. Rand dev.    : LFNoise2 FM on instantaneous partial freq
    3. Vibrato      : SinOsc LFO on freq; depth ramped via Env (onset)
    4. Basis osc    : one of the four alternatives above
    5. Tremolo      : LFNoise2 amplitude modulation
    6. Amp env      : per-partial ADSR with frequency-dependent sustain
    7. Pan          : slight per-partial spread for ensemble width

• Frequency-dependent decay (problem requirement):
    τ_k = sustain * (1 − decayExp * (k−1) / (maxK−1))
    k=1 (fundamental) gets full sustain; k=maxK gets reduced sustain.
    The scoring function computes τ_k and passes it as the `sustain` arg.

• All musically meaningful parameters are exposed as CtkNote arguments
  so the scoring function has full per-note, per-partial control.
*/


// -------------------------
// instantiate CtkProtoNotes

~myProtoNotes = Dictionary.new;


// -------------------------
// add synthDefs

// ────────────────────────────────────────────────────────────────────────────
// Basis function data — mirrors the additiveBasisFuncs.scd examples.
// Each entry is a Function of (freq, phase, amp, extraArgs) → stereo signal.
// The synthDef selects one at instantiation via the \basisFunc arg (selector).
// ────────────────────────────────────────────────────────────────────────────
~myBasisFuncData = Dictionary.new;

// 1. Pure sinusoid (reference)
~myBasisFuncData[\pure] = { |freq, phase = 0.0, amp = 1.0,
                               beats = 0.55, noiseFreq = 1.0, detuneHz = 5.0|
    SinOsc.ar(freq, phase, amp).dup(2)
};

// 2. Sinusoid – detune in stereo (beating between L & R)
//    From additiveBasisFuncs: "sinusoid wave – detune in stereo"
~myBasisFuncData[\detuneStereoBeat] = { |freq, phase = 0.0, amp = 1.0,
                                          beats = 0.55, noiseFreq = 1.0, detuneHz = 5.0|
    var freqLR = freq + (beats / 2 * [1, -1]);
    SinOsc.ar(freqLR, phase, amp)   // returns stereo array
};

// 3. Sinusoid – ringmod with LFNoise2 in mono → duped to stereo
//    From additiveBasisFuncs: "sinusoid wave – ringmod w/ noise in mono"
~myBasisFuncData[\ringNoiseMono] = { |freq, phase = 0.0, amp = 1.0,
                                       beats = 0.55, noiseFreq = 1.0, detuneHz = 5.0|
    var modNoise = LFNoise2.ar(noiseFreq / 20.0).range(-12.dbamp, 0.dbamp);
    (SinOsc.ar(freq, phase, amp) * modNoise).dup(2)
};

// 4. Sinusoid – FM deviation with LFNoise2 in stereo
//    From additiveBasisFuncs: "sinusoid wave – FM mod w/ noise in stereo"
~myBasisFuncData[\fmNoiseStereo] = { |freq, phase = 0.0, amp = 1.0,
                                       beats = 0.55, noiseFreq = 1.0, detuneHz = 5.0|
    var modNoise = LFNoise2.ar(noiseFreq.dup(2), detuneHz);
    SinOsc.ar(freq + modNoise, [phase, phase + 0.5pi], amp)
};


// ────────────────────────────────────────────────────────────────────────────
// \addStringSingle  —  one sinusoidal partial of the string ensemble
// ────────────────────────────────────────────────────────────────────────────
~myProtoNotes[\addStringSingle] = CtkProtoNote(
    SynthDef(\addStringSingle, {

        // ── Partial identity ─────────────────────────────────────────────
        arg partialNum    = 1,        // which harmonic (1 = fundamental)
            fundamental   = 261.63,   // note fundamental Hz  (C4)
            partialAmp    = 1.0,      // SHARC-normalised amplitude for this k

        // ── Overall amplitude ────────────────────────────────────────────
            peakAmp       = 0.22,     // linear peak (shared headroom)

        // ── Amplitude envelope ───────────────────────────────────────────
            attack        = 0.08,
            decay         = 0.05,
            sustainLvl    = 0.85,
            sustain       = 1.2,      // frequency-dependent sustain length (s)
            release       = 0.30,

        // ── Portamento ───────────────────────────────────────────────────
            portamento    = 0.03,     // Lag time (s)

        // ── Random pitch deviation (bow noise) ───────────────────────────
            randDevHz     = 0.6,      // max Hz jitter
            randDevRate   = 2.5,      // noise rate (Hz)

        // ── Vibrato (D&J fig 5.12 / 5.13) ───────────────────────────────
            vibratoRate   = 5.5,      // LFO frequency (Hz)
            vibratoDepth  = 0.20,     // peak depth (semitones)
            vibratoOnset  = 0.18,     // ramp-to-full duration (s)

        // ── Tremolo ──────────────────────────────────────────────────────
            tremoloDepth  = 0.035,
            tremoloRate   = 5.1,

        // ── Ensemble / basis func args ───────────────────────────────────
            ensembleBeats = 0.55,     // Hz — stereo detuning beats
            basisNoiseFreq= 1.0,      // noise rate for ring/fm bases
            basisDetuneHz = 5.0,      // FM deviation magnitude

        // ── Pan ──────────────────────────────────────────────────────────
            pan           = 0.0,      // -1 (L) to +1 (R)

        // ── Output bus ──────────────────────────────────────────────────
            out           = 0;

        // ── 1. Portamento: smooth fundamental on control rate ────────────
        var fundSmooth   = Lag.kr(fundamental.kr, portamento);

        // ── 2. Instantaneous partial frequency ───────────────────────────
        var partialFreq  = fundSmooth * partialNum;

        // ── 3. Vibrato (onset envelope → depth ramps in) ─────────────────
        //    vibratoDepth is in semitones; convert to Hz deviation
        var vibratoEnv   = Env(
            [0, 0, vibratoDepth],
            [attack, vibratoOnset],
            \lin
        ).ar;                                        // depth in semitones
        var vibratoHz    = partialFreq * (
            2.pow(vibratoEnv / 12.0) - 1.0          // semitones → Hz offset
        );
        var vibratoSig   = SinOsc.kr(vibratoRate) * vibratoHz;

        // ── 4. Random pitch deviation (bow micro-fluctuation) ────────────
        var randDev      = LFNoise2.ar(randDevRate, randDevHz);

        // ── 5. Final instantaneous freq (with all deviations) ────────────
        var instFreq     = partialFreq + vibratoSig + randDev;

        // ── 6. Basis oscillator (chosen by scoring function argument) ─────
        //    We always build all four and gate with Select.
        //    This keeps a single SynthDef compilable without Func injection.
        //    Index: 0=pure, 1=detuneStereoBeat, 2=ringNoiseMono, 3=fmNoiseStereo
        var basisSig = Select.ar(0, [   // default: pure (overridden below)
            // pure
            SinOsc.ar(instFreq, 0.0, 1.0).dup(2),
            // detuneStereoBeat
            SinOsc.ar(instFreq + (ensembleBeats / 2 * [1, -1]), 0.0, 1.0),
            // ringNoiseMono
            (SinOsc.ar(instFreq, 0.0, 1.0) *
                LFNoise2.ar(basisNoiseFreq / 20.0).range(-12.dbamp, 0.dbamp)
            ).dup(2),
            // fmNoiseStereo
            SinOsc.ar(
                instFreq + LFNoise2.ar(basisNoiseFreq.dup(2), basisDetuneHz),
                [0.0, 0.5pi], 1.0
            )
        ]);

        // NOTE: since Select inside SynthDef requires a fixed index at compile
        // time for multi-channel signals, we instead use the four signals mixed
        // by a per-SynthDef conditional chosen at note-on via a 0-indexed arg.
        // The approach below uses four oscillators weighted by binary selectors
        // passed as args — one arg (\basisIndex 0–3) picks the winner.
        // This is SuperCollider-idiomatic for switchable basis functions.
        arg basisIndex = 1;   // 0=pure 1=detuneStereoBeat 2=ringNoise 3=fmNoise

        var pureSig    = SinOsc.ar(instFreq, 0.0).dup(2);
        var detuneSig  = SinOsc.ar(instFreq + (ensembleBeats / 2 * [1,-1]), 0.0);
        var ringNoise  = (SinOsc.ar(instFreq) *
            LFNoise2.ar(basisNoiseFreq / 20.0).range(-12.dbamp, 0.dbamp)
        ).dup(2);
        var fmNoise    = SinOsc.ar(
            instFreq + LFNoise2.ar([basisNoiseFreq, basisNoiseFreq + 0.1], basisDetuneHz),
            [0.0, 0.5pi]
        );

        // Gate: multiply each by its selector (0 or 1) and sum
        var b0 = (basisIndex sig== 0).asInteger.asFloat;
        var b1 = (basisIndex sig== 1).asInteger.asFloat;
        var b2 = (basisIndex sig== 2).asInteger.asFloat;
        var b3 = (basisIndex sig== 3).asInteger.asFloat;

        var chosenSig = (pureSig * b0) + (detuneSig * b1) +
                        (ringNoise * b2) + (fmNoise * b3);

        // ── 7. Tremolo (amplitude flutter) ───────────────────────────────
        var tremoloEnv = LFNoise2.kr(tremoloRate).range(
            1.0 - tremoloDepth, 1.0
        );

        // ── 8. Amplitude envelope (frequency-dependent sustain) ──────────
        //    sustain is already computed by the scoring function per-partial.
        var ampEnv = Env.adsr(
            attack, decay, sustainLvl, release
        ).ar(Done.freeSelf, gate: 1, timeScale: sustain / (attack + decay + 1.0 + release));

        // A cleaner approach: use a fixed-shape Env with absolute times
        var ampEnv2 = EnvGen.ar(
            Env(
                [0, 1, sustainLvl, sustainLvl, 0],
                [attack, decay, sustain - attack - decay, release],
                [\lin, \exp, \lin, \exp]
            ),
            doneAction: Done.freeSelf
        );

        // ── 9. Final signal ───────────────────────────────────────────────
        var sig = chosenSig * partialAmp * peakAmp * tremoloEnv * ampEnv2;

        // ── 10. Pan to output ─────────────────────────────────────────────
        Out.ar(out, Pan2.ar(sig.sum, pan))
    })
);

"synthDefs.scd loaded — ~myProtoNotes keys: %".format(~myProtoNotes.keys).postln;
