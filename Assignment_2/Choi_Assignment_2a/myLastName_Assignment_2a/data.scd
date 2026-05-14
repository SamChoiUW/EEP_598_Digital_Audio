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
~instName = \violin_martele ;

// make instrument target folder
~instFolderPath = ~dataFolderPath +/+ ~instName;
File.mkdir(~instFolderPath);


~pitches = [ \d4, \e4, 'f#4', \g4, \a4, \b4, 'c#5', \d5 ];

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

// find reference frequencies
~refFreqs = ~readmeDict.atAll(~pitches);


/*
Now we're ready to read the spectral data and fill a dictionary with the SHARC data we'd like to use
*/
~specDict = Dictionary.new;
~specDict.put(~instName, Dictionary.new);
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

			~specDict[~instName].put(
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
~specDict[\violin_martele].keys.postln;