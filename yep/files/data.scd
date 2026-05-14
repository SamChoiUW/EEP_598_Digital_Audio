/*
Project Title: myLastName_Assignment_2b
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

~saxData = Dictionary.new;


// -------------------------
// add associations

// ─────────────────────────────────────────────────────────────────────────────
// 0. Paths
// ─────────────────────────────────────────────────────────────────────────────

~soundsDir = PathName.new(Document.current.dir +/+ "sounds");

// After converting MP3 → AIFF (see NOTE below), set this path:
~saxPath = ~soundsDir +/+ "saxophone_A4_very-long_cresc-decresc_normal.aiff";

/*
Source: London Philharmonia Orchestra Sound Samples Library
        accessed via Internet Archive Wayback Machine: https://web.archive.org

NOTE on format conversion:
SuperCollider cannot decode MP3 directly. Convert with ffmpeg first:

    ffmpeg -i saxophone_A4_very-long_cresc-decresc_normal.mp3 \
               saxophone_A4_very-long_cresc-decresc_normal.aiff

Place the resulting AIFF in this project's sounds/ folder.
*/

// Step 1 — Download the MP3 (evaluate this block once):
(
    var mp3Path = ~soundsDir +/+ "saxophone_A4_very-long_cresc-decresc_normal.mp3";
    var saxURL  = "https://web.archive.org/web/2024/https://www.philharmonia.co.uk/assets/audio/samples/saxophone/saxophone_A4_very-long_cresc-decresc_normal.mp3";

    Download.new(
        saxURL,
        mp3Path.fullPath,
        { "MP3 download complete. Now convert to AIFF (see NOTE above).".postln },
        { |err| ("Download failed: " ++ err).postln },
        { |rec, tot| "\t% / % bytes".format(rec, tot).postln }
    )
);

// Step 2 — Convert (run in terminal, then continue below):
// ffmpeg -i sounds/saxophone_A4_very-long_cresc-decresc_normal.mp3
//         sounds/saxophone_A4_very-long_cresc-decresc_normal.aiff


// ─────────────────────────────────────────────────────────────────────────────
// 1. Boot server & load soundfile
// ─────────────────────────────────────────────────────────────────────────────

s.boot;

~saxBuf = Buffer.read(s, ~saxPath.fullPath, action: {
    "Saxophone buffer loaded: % frames @ % Hz (% sec)".format(
        ~saxBuf.numFrames,
        ~saxBuf.sampleRate,
        (~saxBuf.numFrames / ~saxBuf.sampleRate).round(0.01)
    ).postln
});


// ─────────────────────────────────────────────────────────────────────────────
// 2. Spectral analysis parameters
// ─────────────────────────────────────────────────────────────────────────────

/*
The cresc-decresc recording is roughly 10–12 seconds long.
Approximate dynamic arc:
  0.0 – 1.5 s   soft onset   (pp)
  1.5 – 5.0 s   crescendo
  5.0 – 6.5 s   peak loudness (ff)
  6.5 – 10.0 s  decrescendo  (pp)

Three spectral snapshots are taken at:
  snapshot 0 — t ≈ 1.0 s   pp onset
  snapshot 1 — t ≈ 5.5 s   ff peak  (richest spectrum)
  snapshot 2 — t ≈ 9.0 s   pp decay

Inspect your converted AIFF in SFPlayer and adjust ~snapTimes if needed.
*/

~wtSize          = 4096;    // wavetable buffer size (power of 2)
~fftSize         = 4096;    // FFT analysis window size
~fundamentalFreq = 440.0;   // A4 — concert pitch of the recording
~numHarmonics    = 22;      // harmonics in the 0–10 kHz range at A4

~snapTimes = [ 1.0, 5.5, 9.0 ];   // seconds into the file — adjust after inspection


// ─────────────────────────────────────────────────────────────────────────────
// 3. Spectral analysis function
//    Reads a Hann-windowed slice of ~saxBuf, runs an rfft, returns
//    an Array of [ harmNum, amp, phase ] triplets (sine basis).
// ─────────────────────────────────────────────────────────────────────────────

~analyseSnapshot = { |buf, timePos, fftSize, fundamentalFreq, numHarmonics|
    var sr         = buf.sampleRate;
    var startFrame = (timePos * sr).round.asInteger;
    var signal     = Signal.newClear(fftSize);
    var cosTable, spectrum, binWidth, harmsAmpsPhases;

    buf.loadToFloatArray(startFrame, fftSize, { |arr|
        signal = Signal.newFrom(arr)
    });
    s.sync;

    // Hann window — reduces spectral leakage
    signal = signal * Signal.hanningWindow(fftSize);

    // forward real FFT → [cosineSignal, sineSignal]
    cosTable = Signal.rfftCosTable(fftSize.div(2) + 1);
    spectrum  = signal.rfft(cosTable);

    binWidth = sr / fftSize;

    harmsAmpsPhases = Array.new(numHarmonics);
    numHarmonics.do({ |i|
        var harmNum = i + 1;
        var binIdx  = (fundamentalFreq * harmNum / binWidth).round.asInteger;
        var re, im, amp, phase;

        (binIdx < (fftSize.div(2) + 1)).if({
            re    = spectrum[0][binIdx];
            im    = spectrum[1][binIdx];
            amp   = ((re * re) + (im * im)).sqrt * (2 / fftSize);  // normalise
            phase = im.atan2(re);    // sine-basis phase
            harmsAmpsPhases.add([ harmNum, amp, phase ])
        })
    });

    harmsAmpsPhases
};


// ─────────────────────────────────────────────────────────────────────────────
// 4. Run analysis at each snapshot time
//    Evaluate AFTER ~saxBuf has loaded (confirm in Post window first).
// ─────────────────────────────────────────────────────────────────────────────

(
    ~snapData = ~snapTimes.collect({ |t, i|
        var hap = ~analyseSnapshot.(
            ~saxBuf, t, ~fftSize, ~fundamentalFreq, ~numHarmonics
        );
        "Snapshot %: t=% s  →  % harmonics extracted".format(i, t, hap.size).postln;
        hap
    });
);

// inspect
~snapData[0];   // pp onset
~snapData[1];   // ff peak
~snapData[2];   // pp decay


// ─────────────────────────────────────────────────────────────────────────────
// 5. Build CtkBuffers (wavetables) — one per snapshot
//    \synthDef_msWT will interpolate between them via LinSelectX.
// ─────────────────────────────────────────────────────────────────────────────

(
    ~wtBufs = ~snapData.collect({ |hap, i|
        var buf = CtkBuffer.buffer(~wtSize).sine3(
            0.0, 1,      // normalise, wavetable format
            1,           // additive flag
            *hap.flatten // harmNum, amp, phase triplets
        );
        buf.load(sync: true);
        "Wavetable % loaded (bufnum: %)".format(i, buf.bufnum).postln;
        buf
    });
);


// ─────────────────────────────────────────────────────────────────────────────
// 6. Store in ~saxData
// ─────────────────────────────────────────────────────────────────────────────

~saxData[\snapTimes]       = ~snapTimes;
~saxData[\snapData]        = ~snapData;
~saxData[\wtBufs]          = ~wtBufs;
~saxData[\fundamentalFreq] = ~fundamentalFreq;
~saxData[\numHarmonics]    = ~numHarmonics;
~saxData[\saxBuf]          = ~saxBuf;

"~saxData ready. Keys: %".format(~saxData.keys).postln;
