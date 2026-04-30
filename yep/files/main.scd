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

_main_ orchestrates the full NRT (non-realtime) render pipeline:
  1. Load functions, data, synthDefs
  2. Set RT/NRT environment variables
  3. Build the main score via ~myScoreFuncs[\scoreScale]
  4. Optionally inspect the score
  5. Write the score to a WAV file and open in SFPlayer

Evaluate each section block-by-block from top to bottom.
The server does NOT need to be booted for NRT rendering (step 5).
*/


///////////////// 1.  load functions, data & synthDefs ///////////////

(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "data.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

currentEnvironment.keys.postln;  // confirm environment is populated


///////////////// 2.  set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({
    // NRT default when RT server is not booted
    44100
}, {
    s.sampleRate.asInteger
});

~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;   // stereo

~headerFormat = "WAV";
~sampleFormat = "int24";

~outputFilePath = PathName.new(
    "%/%/_%.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);

"Output path: %".format(~outputFilePath.fullPath).postln;


///////////////// 3.  build main score ///////////////

/*
~myScoreFuncs[\scoreScale] iterates over all 8 C major scale degrees,
looks up the nearest SHARC cello_vibrato spectrum for each,
and adds one CtkNote per partial (with frequency-dependent sustain).

To render with a different basis function, change ~myData[\basisFunc]
before evaluating this block:
    ~myData[\basisFunc] = \pure;             // plain sinusoids
    ~myData[\basisFunc] = \detuneStereoBeat; // stereo beating (default)
    ~myData[\basisFunc] = \ringNoiseMono;    // ring-mod noise
    ~myData[\basisFunc] = \fmNoiseStereo;    // FM noise stereo
*/

~mainScore = ~myScoreFuncs[\scoreScale].(~myData, ~myProtoNotes);


///////////////// 4.  (optional) inspect score ///////////////

// Post all notes — useful for verifying partial counts and timing
// Comment out if the score is large (24 partials × 8 notes = 192 CtkNotes)
// ~myScoreFuncs[\postNotes].(~mainScore);


///////////////// 5.  render the main score ///////////////

/*
Ensure the sounds/ subfolder exists:
    File.mkdir(Document.current.dir +/+ "sounds");

Then evaluate the block below to write the WAV and open in SFPlayer.
NRT render does NOT require the RT server to be booted.
*/

(
    // make sure output directory exists
    File.mkdir(PathName.new(~outputFilePath.fullPath).pathOnly);

    ~mainScore.write(
        path:         ~outputFilePath.fullPath,
        sampleRate:   ~sampleRate,
        headerFormat: ~headerFormat,
        sampleFormat: ~sampleFormat,
        options:      ~serverOptions,
        action:       ~myScoreFuncs[\scoreWriteOpenSFPlayer].(~mainScore, ~outputFilePath)
    )
);

/*
──────────────────────────────────────────────────────────────────────
RENDERING MULTIPLE SCALES (basis function comparison)
──────────────────────────────────────────────────────────────────────
Evaluate this block to render all four basis functions in sequence,
each to its own WAV file.  Demonstrates the range of outcomes.

(
    [\pure, \detuneStereoBeat, \ringNoiseMono, \fmNoiseStereo].do { |sym|
        ~myData[\basisFunc] = sym;

        var filePath = PathName.new(
            "%/%/_%-%.%".format(
                Document.current.dir,
                "sounds",
                PathName.new(Document.current.dir).fileName,
                sym.asString,
                ~headerFormat.toLower
            )
        );

        var score = ~myScoreFuncs[\scoreScale].(~myData, ~myProtoNotes);

        score.write(
            path:         filePath.fullPath,
            sampleRate:   ~sampleRate,
            headerFormat: ~headerFormat,
            sampleFormat: ~sampleFormat,
            options:      ~serverOptions,
            action: { |exitCode, pid|
                (exitCode == 0).if({
                    "Rendered: %".format(filePath.fileName).postln
                })
            }
        )
    }
)
*/
