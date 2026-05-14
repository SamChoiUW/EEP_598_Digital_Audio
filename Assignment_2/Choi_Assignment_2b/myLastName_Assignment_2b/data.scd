/*
Project Title: choi_Assignment_2b
Date: Wed Apr 15 17:21:21 2026

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
data here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


// -------------------------
// instantiate dictionaries
(
~saxData = Dictionary.new;

// -------------------------
// add associations


~hannPadWindowFunc = { |size = 4096, padFac = 0|
	Signal.hannWindow(
		size,
		(size * padFac).asInteger
	)
};





~dataDir = PathName.new(Document.current.dir +/+ "data/saxophone");
~saxPath = ~dataDir +/+ "saxophone_A4_very-long_cresc-decresc_normal.mp3";

~wtSize          = 8192;
~fftSize         = 8192;
~fundamentalFreq = 440.0;
~numHarmonics    = 22;

~snapTimes = [ 0.1, 1.1, 2.0, 3.1, 4.7, 5.5 , 6.5, 8.6];



~analyseSnapshot = { |path, timePos, fftSize, fundamentalFreq, numHarmonics|
    var sf          = SoundFile.openRead(path);
    var sr          = sf.sampleRate;
    var numChans    = sf.numChannels;
    var nyquist     = sr / 2;
    var startFrame  = (timePos * sr).round.asInteger;
    var window      = Signal.hannWindow(fftSize);
    var arr         = FloatArray.newClear(fftSize * numChans);
    var signal, cosTable, spectrum, binWidth, harmsAmpsPhases;

    sf.seek(startFrame, 0);
    sf.readData(arr);
    sf.close;

    signal = (numChans > 1).if({
        Signal.newFrom(
            Array.series(fftSize, 0, numChans).collect({ |i| arr[i] })
        )
    }, {
        Signal.newFrom(arr)
    });

    signal   = signal * window;
    cosTable = Signal.rfftCosTable(fftSize.div(2) + 1);
    spectrum = signal.rfft(cosTable);
    binWidth = sr / fftSize;
    harmsAmpsPhases = Array.new(numHarmonics);

    numHarmonics.do({ |i|
        var harmNum  = i + 1;
        var harmFreq = fundamentalFreq * harmNum;
        var binIdx   = (harmFreq / binWidth).round.asInteger;

        (binIdx < (fftSize.div(2) + 1) && { harmFreq < nyquist }).if({
            var re    = spectrum.real[binIdx];
            var im    = spectrum.imag[binIdx];
            var amp   = ((re * re) + (im * im)).sqrt;
            var phase = im.atan2(re);
            harmsAmpsPhases.add([ harmNum, amp, phase ])
        })
    });

    harmsAmpsPhases
};

~snapData = ~snapTimes.collect({ |t, i|
    var hap    = ~analyseSnapshot.(~saxPath.fullPath, t, ~fftSize, ~fundamentalFreq, ~numHarmonics);
    var amps   = hap.collect(_[1]);
    var maxAmp = amps.maxItem;

    (maxAmp > 0).if({
        hap = hap.collect({ |h| [ h[0], h[1] / maxAmp, h[2] ] })
    });

    "Snapshot % at % s analysed".format(i, t).postln;
    hap
});

~saxBuf = Buffer.read(s, ~saxPath.fullPath, action: { |buf|
    [
        buf.numFrames,
        buf.sampleRate,
        (buf.numFrames / buf.sampleRate).round(0.01)
    ].postln;

    ~wtBufs = ~snapData.collect({ |hap, i|
        var wtBuf = CtkBuffer.buffer(~wtSize).sine3(0.0, 1, 1, *hap.flatten);
        wtBuf.load(sync: true);
        "Wavetable % loaded (bufnum: %)".format(i, wtBuf.bufnum).postln;
        wtBuf
    });

    ~saxData[\snapTimes]       = ~snapTimes;
    ~saxData[\snapData]        = ~snapData;
    ~saxData[\wtBufs]          = ~wtBufs;
    ~saxData[\fundamentalFreq] = ~fundamentalFreq;
    ~saxData[\numHarmonics]    = ~numHarmonics;
    ~saxData[\saxBuf]          = buf;

    "~saxData ready. Keys: %".format(~saxData.keys).postln;
});
)