/*
Project Title: Assignment 4
Date: Mon May 11 15:33:36 2026

EE P 598a: Advanced Topics In Electrical And Computer Engineering (Introduction to Digital Audio)
Authors: Joseph Anderson, Junkai Wu, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")
*/


// -------------------------
// instantiate CtkProtoNotes


// -------------------------
// add synthDefs
SynthDef(\fof_voice, { |out=0, freq=220, amp=0.3,
    voicedSwitch= -1,
    f1=800,  f2=1150, f3=2900, f4=3900, f5=4950,
    bw1=0.08, bw2=0.07, bw3=0.05, bw4=0.04, bw5=0.04,
    a1=1.0,  a2=0.6,  a3=0.3,  a4=0.1,  a5=0.1,
    vibratoDepth=0, vibratoOnset=0.3|

    var depth      = Line.kr(0, vibratoDepth, vibratoOnset);
    var lfo        = SinOsc.kr(6, mul: depth);
    var modFreq    = freq + lfo;

    var voiced     = Impulse.ar(modFreq);
    var unvoiced   = PinkNoise.ar(0.3);
    var excitation = XFade2.ar(voiced, unvoiced, voicedSwitch);

    var bank = Mix([
        Formlet.ar(excitation, f1, 0.005, bw1, a1),
        Formlet.ar(excitation, f2, 0.005, bw2, a2),
        Formlet.ar(excitation, f3, 0.005, bw3, a3),
        Formlet.ar(excitation, f4, 0.005, bw4, a4),
        Formlet.ar(excitation, f5, 0.005, bw5, a5),
    ]);

    var env = EnvGen.ar(Env.asr(0.01, 1, 0.1), doneAction: 2);
    Out.ar(out, Pan2.ar(bank * env * amp));
}).add;