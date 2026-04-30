HelpBrowser.openHelpFor("SHARCData")
HelpBrowser.openLink("link::Other/CiteGuidelines#Repository::")
HelpBrowser.openLink("link::Classes/Signal#-normalizeShaperTU::")
/*
download and prep SHARC data for use in wavetable and/or wavepacket project(s)

the resulting data will be returned in ~specDict
*/

// create folder to download data files to
~dataFolderPath = "~/Desktop/sharcData".standardizePath;  // on the desktop!
File.mkdir(~dataFolderPath);


// download README
/*
need this to grab reference frequencies for a chosen instrument

instrument names can be found here:
*/
HelpBrowser.goTo("https://github.com/gregsandell/sharc/blob/master/spect/README#L105-L124");


// choose an instrument
// ~instName = \bass_clarinet;
~instName = \trombone;

// make instrument target folder
~instFolderPath = ~dataFolderPath +/+ ~instName;
File.mkdir(~instFolderPath);


// README file source and target
~readmeURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/%/CONTENTS".format(~instName.asString);
~readmePath = ~instFolderPath +/+ PathName.new(~readmeURL).fileName;


// download...
// ... and read into ~readme
Download.new(
    ~readmeURL,
    ~readmePath,
    {  // finishedFunc
        ~readme = FileReader.read(~readmePath, skipBlanks: true);
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~readmeURL, ~readmePath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
);


// the raw line by line readme as array
~readme;

/*
The details of the meaning of these lines can be found here:
*/
HelpBrowser.goTo("https://github.com/gregsandell/sharc/blob/master/spect/README#L307-L330");


// create and fill a dictionary, so as to easily parse ~readme
/*
We're interested in capturing is...

Column 6: The actual fundamental frequency, as measured from the samples for this tone.

... which is the reference frequence of the measured spectrum.
*/
~readmeDict = Dictionary.new;
~readme.do({ |item|
    ~readmeDict.put(item.at(0).asSymbol, item.at(5).asFloat)
});

// let's see...
~readmeDict;


// set up pitch indices for data to be read
/*
D maj scale
*/
~pitches = [ 'd2', 'e2', 'f#2', 'g2', 'a2', 'b2', 'c#3', 'd3' ];  // will specify which data to pull

// find reference frequencies
~refFreqs = ~readmeDict.atAll(~pitches);


/*
Now we're ready to read the spectral data and fill a dictionary with the SHARC data we'd like to use
*/
~specDict = Dictionary.new;

// convert pitches to SHARC names for #
// # --> %23
/*
needed to reference actual url names
*/
~pitchesSharc = ~pitches.collect({ |item|
    item.asString.replace("#", "%23")
});



// download SHARC spec files
~pitchesSharc.do({ |item, i|
    var requestedURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/%/%.spect".format(~instName.asString, item.asString);
    var targetPath = ~instFolderPath +/+ PathName.new(PathName.new(requestedURL).fileName).fileName;

    Download.new(
        requestedURL,
        targetPath,
        {  // finishedFunc
            var spectData = FileReader.read(targetPath, skipBlanks: true);
            var harmsGainsPhases = spectData.collect({ |item, i|  // add harmonic numbers & collect data as floats
                [ i + 1, item[0].asFloat, (item[1].asFloat + 0.5pi).wrap(pi.neg, pi) ]  // update phase from cosine to sine basis
            });
            var harmsAmpsPhases = harmsGainsPhases.collect({ |item|  // convert gain in dB to amplitude scalar
                [ item[0], item[1].dbamp, item[2] ]
            });

            ~specDict.put(
                ~pitches.at(i),
                Dictionary.newFrom([
                    \refFreq, ~refFreqs.at(i), \harmsAmpsPhases, harmsAmpsPhases,
                ])
            )
        }, {  // errorFunc
            Error.new(
                "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(requestedURL, targetPath)
            ).throw
        }, { |rec, tot|  // progressFunc
            "\t % of %".format(rec, tot).postln;
        }
    )
});


// now we have the SHARC spectral data!
~specDict;

/*
if we use -postcs, we can display the complete data in the post window

if we'd like to use in a project, we can just copy this into a data file associated with the project
*/
~specDict.postcs;


// for fun, let's inspect...
~specDict.keys;

// pitch \d2
~specDict.at(\d2).keys;
~specDict.at(\d2).at(\refFreq);
~specDict.at(\d2).at(\harmsAmpsPhases);

// pitch \a2
~specDict.at(\a2).keys;
~specDict.at(\a2).at(\refFreq);
~specDict.at(\a2).at(\harmsAmpsPhases);


// it is always good to clean up after ourselves..
// ... when we're finished we can delete the download folder
File.deleteAll(~dataFolderPath);

// sum of cosines & sines
(
var size = 1024;
var data = ~specDict.at(\a2).at(\harmsAmpsPhases);
var amplitudes = data.collect(_[1]);
var phases = data.collect(_[2]);

var tableTU = Signal.chebyTUFill(size, amplitudes, phases);
var normTU = tableTU.at(0).normalizeShaperTU(tableTU.at(1));
var modIndices = Array.interpolation(5, 0.0, 1.0);
var analytic = Signal.analyticFill(size, [ 1.0 ]);
var waves = modIndices.collect({ |index, i|
    analytic.real.shaperTU(analytic.imag, tableTU, index) * normTU.at(index * (size - 1))
});

// plot!
waves.plot("ChebyshevTU - normalized; mod index: %".format(modIndices), minval: -1.0, maxval: 1.0)
)

// quadrature waveshaping returns sum of sines & cosines
FreqScope.new;
(
s.waitForBoot({
    var size = 1024;
    var amplitudes = [0, 1, 1, 2, 1];
    var phases = 2pi.dup(amplitudes.size).rand;
    var chebyTU = Signal.chebyTUFill(size.div(2) + 1, amplitudes, phases);
    b = chebyTU.collect({ |sig| Buffer.loadCollection(s, sig.asWavetableNoWrap) });
    c = Buffer.loadCollection(s, chebyTU[0].normalizeShaperTU(chebyTU[1], discardDC: true));
    s.sync;
    x = {
        var index = SinOsc.kr(0.1, 0, 0.5, 0.5);
        var in = SinOsc.ar(100, [ 0.5pi, 0.0 ], index);  // cosine & sine
        LeakDC.ar(
            Shaper.ar(b[1], in[0], in[1], Shaper.ar(b[0], in[0])),
            mul: IndexL.kr(c, index * (c.numFrames - 1), 0.5)
        )
    }.scope;
})
)
x.free; b.do(_.free); b = nil; c.free; c = nil