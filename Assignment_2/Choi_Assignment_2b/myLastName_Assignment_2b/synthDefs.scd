/*
Project Title: choi_Assignment_2b
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

~myProtoNotes.add(
    \synthDef_msWT -> CtkSynthDef.new(
        \synthDef_msWT,
        { |dur = 9.5,
          gain = -12.0,
          freq = 440.0,
          fundamentalFreq = 440.0,
          riseTime    = 0.10,
          decayTime   = 0.30,
          crescTime   = 4.5,
          decrescTime = 4.5,
          pitchNoise  = 0.08,
          wtSelLead   = 0.30,
          buf0 = 0, buf1 = 1, buf2 = 2, buf3 = 3,
          buf4 = 4, buf5 = 5, buf6 = 6, buf7 = 7,
          panAngle = 0.0,
          outBus = 0|

            var amp    = gain.dbamp;
            var pos    = panAngle.neg / 45;
            var ampEnv, wtSelEnv;
            var pitchDev, modFreq;
            var osc0, osc1, osc2, osc3, osc4, osc5, osc6, osc7;
            var wtSig, panSig;

            ampEnv = EnvGen.kr(
                Env(
                    levels: [ 0, 1.0, 1.0, 1.0, 0 ],
                    times:  [ riseTime, crescTime, decrescTime, decayTime ],
                    curve:  [ \lin, \sin, \sin, \lin ]
                ),
                levelScale: amp,
                doneAction: Done.freeSelf
            );

            wtSelEnv = EnvGen.kr(
                Env(
                    levels: [ 0.0, 0.0, 4.0, 7.0, 7.0 ],
                    times: [
                        (riseTime    - wtSelLead).max(0.001),
                        (crescTime   - wtSelLead).max(0.001),
                        (decrescTime + wtSelLead).max(0.001),
                        decayTime.max(0.001)
                    ],
                    curve: [ \lin, \sin, \sin, \lin ]
                )
            );

            pitchDev = LFNoise2.kr(0.8).range(
                (pitchNoise.neg / 12).midiratio,
                (pitchNoise      / 12).midiratio
            );

            modFreq = freq * pitchDev;

            osc0 = Osc.ar(buf0, modFreq);
            osc1 = Osc.ar(buf1, modFreq);
            osc2 = Osc.ar(buf2, modFreq);
            osc3 = Osc.ar(buf3, modFreq);
            osc4 = Osc.ar(buf4, modFreq);
            osc5 = Osc.ar(buf5, modFreq);
            osc6 = Osc.ar(buf6, modFreq);
            osc7 = Osc.ar(buf7, modFreq);

            wtSig  = LinSelectX.ar(wtSelEnv, [ osc0, osc1, osc2, osc3, osc4, osc5, osc6, osc7 ]);
            panSig = Pan2.ar(wtSig * ampEnv, pos);

            Out.ar(outBus, panSig)
        }
    )
);