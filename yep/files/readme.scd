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

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
Assignment 2b — Problem 1b
Multi-Segment Wavetable Synthesis of a long spectrally modulating tone
=======================================================================

Problem addressed: 1b — Model a _long_ spectrally modulating instrument tone
                        via multi-segment Wavetable Synthesis

Source recording:
  saxophone_A4_very-long_cresc-decresc_normal.mp3
  London Philharmonia Orchestra Sound Samples Library
  Accessed via Internet Archive Wayback Machine (https://web.archive.org)
  Stored as: sounds/saxophone_A4_very-long_cresc-decresc_normal.aiff (converted)

────────────────────────────────────────────────────────────────────────────
Approach
────────────────────────────────────────────────────────────────────────────
Three spectral snapshots are sampled from the recording at positions that
capture the full dynamic arc of the cresc-decresc tone:

  Snapshot 0  t ≈ 1.0 s   pp (sparse, soft onset)
  Snapshot 1  t ≈ 5.5 s   ff (loudest point, richest harmonics)
  Snapshot 2  t ≈ 9.0 s   pp (soft decay)

Each snapshot is Hann-windowed, FFT-analysed (4096-point rfft, 22 harmonics),
and stored as a CtkBuffer wavetable via CtkBuffer:-sine3.

The SynthDef \synthDef_msWT uses LinSelectX to continuously interpolate
between the three Osc oscillators, controlled by a multi-segment
wavetable-selection envelope (wtSelEnv, range 0.0 → 1.0 → 2.0).

A separate multi-segment amplitude envelope (ampEnv) controls overall
loudness, using \sin curve segments for a natural S-curve swell.

The two envelopes are deliberately offset by wtSelLead seconds:
the spectrum brightens slightly before the amplitude peak and darkens
slightly before the amplitude falls — matching the physical behaviour
of a saxophonist's embouchure during a crescendo.

────────────────────────────────────────────────────────────────────────────
Realism features (cf. D&J Fig 5.12 / 5.13)
────────────────────────────────────────────────────────────────────────────
  Vibrato     Vibrato UGen — delayed onset, slow fade-in,
              rate and depth variation
  pitchNoise  LFNoise2.kr — slow random pitch deviation
  Envelope    \sin curve on cresc/decresc segments
  wtSelLead   Spectral envelope leads amplitude by ~0.3 s

────────────────────────────────────────────────────────────────────────────
Scores rendered in main.scd
────────────────────────────────────────────────────────────────────────────
  Score A  Single A4 tone — full cresc-decresc arc (9.5 s)
  Score B  Ascending D major scale (D4–D5), 6 s per note

────────────────────────────────────────────────────────────────────────────
Workflow
────────────────────────────────────────────────────────────────────────────
  1. data.scd    — download MP3, convert to AIFF, run spectral analysis,
                   build ~wtBufs
  2. scratchPad.scd — explore parameters interactively on RT server
  3. main.scd    — render final NRT score to sounds/_<project>.wav

*/

// post project files & folders
(
    "Files & folders in this project:\n".postln;
    PathName.new(
        Document.current.dir
    ).streamTree(Post, 1);
    "".postln
);
