/*
Project Title: myLastName_Assignment_2b
Date: Wed Apr 15 17:21:21 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")
*/


// -------------------------
// instantiate CtkProtoNotes

~myProtoNotes = Dictionary.new;


// -------------------------
// add synthDefs

/*
\synthDef_msWT — Multi-Segment Wavetable SynthDef
--------------------------------------------------
Models the saxophone cresc-decresc tone via three spectral wavetables
(pp onset, ff peak, pp decay) interpolated continuously by LinSelectX.

Two independent multi-segment envelopes (cf. D&J Fig 5.12 / 5.13):

  ampEnv     — overall loudness arc: soft → loud → soft
               uses \sin curve for a natural S-curve swell

  wtSelEnv   — wavetable selection: sweeps 0.0 → 1.0 → 2.0
               driving LinSelectX between buf0 (pp), buf1 (ff), buf2 (pp)
               offset from ampEnv by wtSelLead seconds so spectrum
               brightens just before the loudness peak — matching
               real saxophone behaviour

Realism (cf. D&J Fig 5.13 / Vibrato UGen):
  Vibrato    — Vibrato UGen, delayed onset + slow fade-in
  pitchNoise — LFNoise2.kr slow random deviation (liveness)

Arguments:
  dur             total note duration (seconds)
  gain            overall amplitude (dB)
  freq            playback frequency (Hz)
  fundamentalFreq reference frequency of the wavetables (Hz)
  riseTime        amplitude attack (seconds)
  decayTime       amplitude release (seconds)
  crescTime       time from note start to ff peak (seconds)
  decrescTime     time from ff peak back to pp (seconds)
  vibratoRate     vibrato rate (Hz)
  vibratoDepth    vibrato depth (semitones)
  vibratoDelay    seconds before vibrato onset
  vibratoOnset    vibrato fade-in duration (seconds)
  pitchNoise      random pitch deviation depth (semitones)
  wtSelLead       seconds wavetable selection leads amplitude envelope
  buf0            bufnum — pp onset wavetable
  buf1            bufnum — ff peak wavetable
  buf2            bufnum — pp decay wavetable
  panAngle        stereo pan angle (degrees; 0 = centre)
  outBus          output bus
*/

~myProtoNotes.add(
    \synthDef_msWT -> CtkSynthDef.new(
        \synthDef_msWT,
        { |dur = 8.0,
          gain = -12.0,
          freq = 440.0,
          fundamentalFreq = 440.0,
          riseTime    = 0.10,
          decayTime   = 0.30,
          crescTime   = 4.5,
          decrescTime = 4.0,
          vibratoRate   = 5.5,
          vibratoDepth  = 0.40,   // semitones
          vibratoDelay  = 0.80,   // seconds before vibrato onset
          vibratoOnset  = 0.60,   // vibrato fade-in duration
          pitchNoise    = 0.08,   // semitones of slow random deviation
          wtSelLead     = 0.30,   // seconds wavetable selection leads amplitude
          buf0 = 0, buf1 = 1, buf2 = 2,
          panAngle = 0.0,
          outBus = 0|

            var amp        = gain.dbamp;
            var pos        = panAngle.neg / 45;
            var softLevel  = 0.18;   // pp relative to ff (~-15 dB)

            // ── 1. Amplitude envelope ──────────────────────────────────────
            // pp → ff → pp with S-curve cresc/decresc segments
            var ampEnv = EnvGen.kr(
                Env(
                    levels: [ 0, softLevel, 1.0, softLevel, 0 ],
                    times:  [ riseTime, crescTime, decrescTime, decayTime ],
                    curve:  [ \lin, \sin, \sin, \lin ]
                ),
                levelScale: amp,
                doneAction: Done.freeSelf
            );

            // ── 2. Wavetable selection envelope ────────────────────────────
            // 0.0 = buf0 (pp), 1.0 = buf1 (ff), 2.0 = buf2 (pp)
            // Leads the amplitude envelope by wtSelLead seconds
            var wtSelEnv = EnvGen.kr(
                Env(
                    levels: [ 0.0, 0.0, 1.0, 2.0, 2.0 ],
                    times: [
                        (riseTime    - wtSelLead).max(0.001),
                        (crescTime   - wtSelLead).max(0.001),
                        (decrescTime + wtSelLead).max(0.001),
                        decayTime.max(0.001)
                    ],
                    curve: [ \lin, \sin, \sin, \lin ]
                )
            );

            // ── 3. Vibrato & pitch noise ───────────────────────────────────
            // Vibrato UGen: sinusoidal pitch modulation, delayed onset
            var vibratoSig = Vibrato.kr(
                freq,
                rate:           vibratoRate,
                depth:          vibratoDepth / 1200,  // semitones → ratio
                delay:          vibratoDelay,
                onset:          vibratoOnset,
                rateVariation:  0.04,
                depthVariation: 0.10
            );

            // Slow random pitch deviation (liveness)
            var pitchDev = LFNoise2.kr(0.8).range(
                (pitchNoise.neg / 12).midiratio,
                (pitchNoise      / 12).midiratio
            );

            // Modulated frequency: vibrato × noise deviation
            var modFreq = vibratoSig * pitchDev;

            // ── 4. Three wavetable oscillators ─────────────────────────────
            var osc0 = Osc.ar(buf0, modFreq);
            var osc1 = Osc.ar(buf1, modFreq);
            var osc2 = Osc.ar(buf2, modFreq);

            // ── 5. LinSelectX — smooth interpolation between wavetables ────
            var wtSig = LinSelectX.ar(wtSelEnv, [ osc0, osc1, osc2 ]);

            // ── 6. Apply amplitude envelope & stereo pan ───────────────────
            Out.ar(outBus, Pan2.ar(wtSig * ampEnv, pos))
        }
    )
);
