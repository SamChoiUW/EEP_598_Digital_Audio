/*
Project Title: myLastName_Assignment_2a
Date: Wed Apr 15 17:20:57 2026

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
 ~myProtoNotes.add(
    SynthDef.new(
		\synthDef_assignment1A,  // name - as Symbol

        { |dur = 1.0, gain = -14.0, riseTime = 0.1, decayTime = 0.1, freq = 440.0, phase = 0, noiseFreq = 0.5, panAngle = 0, bufnum = 0, outBus = 0|  // UGen graph function

            // vars for UGens
            var ampEnvSig;
            var wtSig;
            var sinSig;
            var panSig;
            var outSig;

            // vars for control
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			// vars for mod
			var ampNoise = LFNoise2.ar(noiseFreq).range(-12.dbamp, 0.dbamp);

            // ----
            // synthesis

            // amplitude envelope
            ampEnvSig = EnvGen.kr(
                Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
                levelScale: amp,
                doneAction: Done.freeSelf
            );  // EnvGen (control rate)

			// wavetable
            // oscillator
			wtSig = Osc.ar(bufBum, freq, phase, ampEnvSig) * ampNoise

            // stereo imager
            panSig = Pan2.ar(sinSig, pos);  // Pan2 (audio rate)

            // assign to out
            outSig = panSig;

            Out.ar(
                outBus,  // out bus - set as an argument
                outSig
            )  // Out (audio rate)
        }
    )
);

