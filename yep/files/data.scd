/*
Project Title: myLastName_Assignment_1a
Date: Wed Apr 29 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
data here

Problem 1a: Single Sinusoid Additive Synthesis — String Ensemble Model
SHARC instrument: cello_vibrato
Scale: one-octave ascending C major, C4 (MIDI 60) to C5 (MIDI 72)
*/


// -------------------------
// instantiate dictionaries

~myData = Dictionary.new;


// -------------------------
// add associations

// ----------------------------------------------------------
// Scale: C major, one octave ascending (C4–C5)
// MIDI note numbers
~myData[\scaleMidi] = [60, 62, 64, 65, 67, 69, 71, 72];

// Scale note names (for reference / posting)
~myData[\scaleNames] = ["C4","D4","E4","F4","G4","A4","B4","C5"];

// Fundamental frequencies (Hz) derived from MIDI
~myData[\scaleFreqs] = ~myData[\scaleMidi].collect({ |m| m.midicps });

// ----------------------------------------------------------
// SHARC instrument selection
// cello_vibrato captures the warm, slightly chorus-ed quality
// ideal for emulating a string section blend.
~myData[\sharcInstrument] = \cello_vibrato;

// ----------------------------------------------------------
// Note timing / rhythm
// Each note: duration in seconds (IOI = inter-onset interval)
~myData[\noteDur]     = 1.4;    // total note duration (s)  — envelope length
~myData[\noteIOI]     = 1.1;    // inter-onset interval (s) — legato overlap
~myData[\startTime]   = 0.1;    // score start offset (s)

// ----------------------------------------------------------
// Amplitude envelope parameters (ADSR-style, overall note shape)
~myData[\attack]      = 0.08;   // (s)  — slower bow attack on string
~myData[\decay]       = 0.05;   // (s)
~myData[\sustainLvl]  = 0.85;   // (0–1)
~myData[\release]     = 0.30;   // (s)
~myData[\peakAmp]     = 0.22;   // linear peak amplitude (headroom for partials)

// ----------------------------------------------------------
// Frequency-dependent partial decay
// Higher partials lose energy sooner — models bow string physics.
// partialDecayExp ∈ [0, 1):
//   0   → all partials share the same sustain length
//   0.7 → top partial sustain ≈ 30 % of fundamental sustain
~myData[\partialDecayExp] = 0.68;

// ----------------------------------------------------------
// Vibrato parameters  (D&J fig 5.12 / 5.13)
// Onset envelope ramps depth from 0 → vibratoDepth over vibratoOnset seconds.
~myData[\vibratoRate]  = 5.5;   // Hz  — typical cello vibrato
~myData[\vibratoDepth] = 0.20;  // semitones  (peak deviation)
~myData[\vibratoOnset] = 0.18;  // (s) — time to reach full vibrato depth

// ----------------------------------------------------------
// Random pitch deviation (bow micro-fluctuation)
// Implemented via LFNoise2 FM on the instantaneous frequency.
~myData[\randDevHz]    = 0.6;   // max Hz of jitter
~myData[\randDevRate]  = 2.5;   // rate of noise change (Hz)

// ----------------------------------------------------------
// Portamento (Lag)
// Smooths discrete pitch steps → simulates a gliding bow across strings.
~myData[\portamento]   = 0.03;  // Lag time in seconds

// ----------------------------------------------------------
// Tremolo (amplitude flutter from bow pressure micro-variation)
~myData[\tremoloDepth] = 0.035; // depth (0–1) — subtle
~myData[\tremoloRate]  = 5.1;   // Hz

// ----------------------------------------------------------
// Ensemble / chorus spread
// Three slightly detuned unison copies → string section width.
// Using the "sinusoid wave – detune in stereo" basis from additiveBasisFuncs.
~myData[\ensembleBeats]  = 0.55;  // Hz — beating between ensemble copies
~myData[\ensemblePan]    = 0.55;  // L/R spread (0 = center, 1 = full)
~myData[\ensembleMix]    = 0.40;  // wet mix of detuned copies (0–1)

// ----------------------------------------------------------
// Maximum partials to synthesise per note
// SHARC cello_vibrato data typically holds 20–30 meaningful partials;
// limiting to 24 keeps CPU manageable in NRT.
~myData[\maxPartials]    = 24;

// ----------------------------------------------------------
// Basis function selector
// Options (keys of ~myBasisFuncData, defined in synthDefs):
//   \pure           → plain SinOsc
//   \detuneStereoBeat → sinusoid wave – detune in stereo (per partial)
//   \ringNoiseMono  → sinusoid wave – ringmod w/ noise in mono
//   \fmNoiseStereo  → sinusoid wave – FM mod w/ noise in stereo
~myData[\basisFunc]      = \detuneStereoBeat;

// post confirmation
"data.scd loaded. Scale: %".format(~myData[\scaleNames]).postln;
