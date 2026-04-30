/*
Project Title: myLastName_Assignment_1a
Date: Wed Apr 29 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
────────────────────────────────────────────────────────────────────────────────
Problem 1a — Single Sinusoid Additive Synthesis: String Ensemble Model
────────────────────────────────────────────────────────────────────────────────

INSTRUMENT MODEL
  SHARC library:  cello_vibrato
  Rational:  The SHARC cello_vibrato spectrum captures the warm, slightly
  chorus-like quality of a bowed cello with natural vibrato applied.  It
  provides a rich set of 20–30 meaningful partials, making it well-suited
  for modelling a fuller string ensemble by summing independently shaped
  sinusoids.

SYNTHESIS METHOD
  Single Sinusoid Additive Synthesis (projectSimpleAS pattern):
  • One SynthDef instance (\addStringSingle) per partial per note.
  • The scoring function looks up the SHARC cello_vibrato spectrum for the
    nearest available MIDI key to each scale degree, then spawns one CtkNote
    per non-zero partial.
  • Each CtkNote carries the SHARC-normalised partial amplitude as an argument,
    so the spectral shape is faithfully reproduced.

SCALE
  Key:   C major, ascending one octave
  Notes: C4 D4 E4 F4 G4 A4 B4 C5  (MIDI 60–72)
  Each note uses its own SHARC .spect lookup (nearest available MIDI key).

REALISM MODIFIERS
  1. Portamento     Lag.kr on the fundamental frequency argument smooths
                    discrete pitch steps, approximating a gliding bow.
  2. Random pitch   LFNoise2 FM deviation on instantaneous partial frequency
     deviation      models the micro-fluctuation of bow pressure and speed.
  3. Vibrato        SinOsc LFO on pitch; depth ramped from 0 → target over
                    vibratoOnset seconds (D&J fig 5.12 / 5.13 style).
                    Rate ≈ 5.5 Hz, depth ≈ 0.20 semitones.
  4. Tremolo        LFNoise2 amplitude modulation models bow-pressure flutter.
  5. Ensemble spread Three-partial detuning via the \detuneStereoBeat basis
                    function creates a string-section chorus effect.

FREQUENCY-DEPENDENT DECAY  (problem requirement)
  Each partial k is given its own sustain duration τ_k:
      τ_k = baseSustain × (1 − decayExp × (k−1) / (numPartials−1))
  k = 1 (fundamental) → full sustain
  k = numPartials     → sustain × (1 − decayExp)    [decayExp = 0.68]
  This causes higher partials to die away before the fundamental, matching
  the natural physics of a bowed string.  The scoring function computes
  τ_k and passes it as the `sustain` argument to each CtkNote.

ALTERNATIVE BASIS FUNCTIONS
  Four basis functions from additiveBasisFuncs.scd are available; selected
  via ~myData[\basisFunc]:
    \pure             → SinOsc (clean reference)
    \detuneStereoBeat → stereo detuning with beats  ← default
    \ringNoiseMono    → ring-mod with LFNoise2 (warm, grainy)
    \fmNoiseStereo    → FM noise deviation in quadrature stereo

  The SynthDef builds all four oscillator networks simultaneously and gates
  the chosen one via an integer \basisIndex argument.  This allows the
  scoring function to switch basis functions per-note if desired.

FILES
  readme.scd      this file
  data.scd        all synthesis parameters (scale, SHARC, envelope, realism)
  functions.scd   SHARC lookup, partial-sustain, score-building functions
  synthDefs.scd   \addStringSingle CtkProtoNote / SynthDef
  scratchPad.scd  interactive RT exploration (boot server first)
  main.scd        full NRT render pipeline → WAV in sounds/
  sounds/         output directory (created automatically)

WORKFLOW
  1. Open scratchPad.scd for interactive exploration (RT).
  2. Open main.scd and evaluate block-by-block for NRT render.
  3. To compare basis functions, see the multi-render block in main.scd.

REFERENCES
  D&J fig 5.12 — vibrato onset envelope shape
  D&J fig 5.13 — vibrato depth as function of partial number
  SHARC HelpBrowser.openLink("link::Tutorials/Data/SHARCData::")
  ProjectSHARCWTsWPs HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")
*/


// post project files & folders
(
    "Files & folders in this project:\n".postln;
    PathName.new(
        Document.current.dir
    ).streamTree(Post, 1);
    "".postln
);
