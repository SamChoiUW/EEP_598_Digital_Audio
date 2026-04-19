//Part One

/*
Attribution:

[1] Oboe tone analysis

Sandell, G. J. Sandell Harmonic Archive (SHARC TIMBRE DATABASE). 2016.
GitHub repository: https://github.com/gregsandell/sharc [accessed April 3rd, 2014]

Downloaded on April 3rd, 2014
Oboe
Performer: UNKNOWN
Technicians: UNKNOWN
https://github.com/gregsandell/sharc/blob/master/spect/oboe/a%233.spect
https://raw.githubusercontent.com/gregsandell/sharc/master/spect/oboe/a%233.spect
License: UNKNOWN

Pitch: B-flat-3

See also:

Sandell, G. J. 1991. A library of orchestra instrument spectra.
Proceedings of the 1991 InternationalComputer Music Conference.
San Francisco, CA: International Computer Music Association, pp. 98-101.
Permalink: http://hdl.handle.net/2027/spo.bbp2372.1991.021 [accessed April 3rd, 2014]
*/
(
~requestedURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/oboe/a%233.spect";  // [1]
~targetPath = "~/Desktop/%".format(PathName.new(~requestedURL).fileName).standardizePath;

~size = 8192;  // target wavetable size

"\n-----------------\nReceived (bytes):".postln;
Download.new(
    ~requestedURL,
    ~targetPath,
    {  // finishedFunc
        var spectData = FileReader.read(~targetPath, skipBlanks: true);
        var harmsGainsPhases = spectData.collect({ |item, i|  // add harmonic numbers & collect data as floats
            [ i + 1, item[0].asFloat, item[1].asFloat ]
        });
        var harmsAmpsPhases = harmsGainsPhases.collect({ |item|  // convert gain in dB to amplitude scalar
            [ item[0], item[1].dbamp, item[2] ]
        });
        ~waveTable = Signal.newClear(~size.div(2)).cosineFill2(harmsAmpsPhases).normalize.asWavetable;
        ~waveTable.plot("waveform: %".format(PathName.new(~targetPath).fileName), minval: -1.0, maxval: 1.0);
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~requestedURL, ~targetPath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
)
)
// inspect?
Document.open(~targetPath);
//bassoon
(
~requestedURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/bassoon/a%233.spect";  // [1]
~targetPath = "~/Desktop/%".format(PathName.new(~requestedURL).fileName).standardizePath;

~size = 8192;  // target wavetable size

"\n-----------------\nReceived (bytes):".postln;
Download.new(
    ~requestedURL,
    ~targetPath,
    {  // finishedFunc
        var spectData = FileReader.read(~targetPath, skipBlanks: true);
        var harmsGainsPhases = spectData.collect({ |item, i|  // add harmonic numbers & collect data as floats
            [ i + 1, item[0].asFloat, item[1].asFloat ]
        });
        var harmsAmpsPhases = harmsGainsPhases.collect({ |item|  // convert gain in dB to amplitude scalar
            [ item[0], item[1].dbamp, item[2] ]
        });
        ~waveTable = Signal.newClear(~size.div(2)).cosineFill2(harmsAmpsPhases).normalize.asWavetable;
        ~waveTable.plot("waveform: %".format(PathName.new(~targetPath).fileName), minval: -1.0, maxval: 1.0);
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~requestedURL, ~targetPath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
)
)
Document.open(~targetPath);

//B-flat clarinet
(
~requestedURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/Bb_clarinet/a%233.spect";  // [1]
~targetPath = "~/Desktop/%".format(PathName.new(~requestedURL).fileName).standardizePath;

~size = 8192;  // target wavetable size

"\n-----------------\nReceived (bytes):".postln;
Download.new(
    ~requestedURL,
    ~targetPath,
    {  // finishedFunc
        var spectData = FileReader.read(~targetPath, skipBlanks: true);
        var harmsGainsPhases = spectData.collect({ |item, i|  // add harmonic numbers & collect data as floats
            [ i + 1, item[0].asFloat, item[1].asFloat ]
        });
        var harmsAmpsPhases = harmsGainsPhases.collect({ |item|  // convert gain in dB to amplitude scalar
            [ item[0], item[1].dbamp, item[2] ]
        });
        ~waveTable = Signal.newClear(~size.div(2)).cosineFill2(harmsAmpsPhases).normalize.asWavetable;
        ~waveTable.plot("waveform: %".format(PathName.new(~targetPath).fileName), minval: -1.0, maxval: 1.0);
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~requestedURL, ~targetPath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
)
)

Document.open(~targetPath);

//alto flute
(
~requestedURL = "https://raw.githubusercontent.com/gregsandell/sharc/master/spect/altoflute_vibrato/a%233.spect";  // [1]
~targetPath = "~/Desktop/%".format(PathName.new(~requestedURL).fileName).standardizePath;

~size = 8192;  // target wavetable size

"\n-----------------\nReceived (bytes):".postln;
Download.new(
    ~requestedURL,
    ~targetPath,
    {  // finishedFunc
        var spectData = FileReader.read(~targetPath, skipBlanks: true);
        var harmsGainsPhases = spectData.collect({ |item, i|  // add harmonic numbers & collect data as floats
            [ i + 1, item[0].asFloat, item[1].asFloat ]
        });
        var harmsAmpsPhases = harmsGainsPhases.collect({ |item|  // convert gain in dB to amplitude scalar
            [ item[0], item[1].dbamp, item[2] ]
        });
        ~waveTable = Signal.newClear(~size.div(2)).cosineFill2(harmsAmpsPhases).normalize.asWavetable;
        ~waveTable.plot("waveform: %".format(PathName.new(~targetPath).fileName), minval: -1.0, maxval: 1.0);
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~requestedURL, ~targetPath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
)
)
Document.open(~targetPath);


//Part Two
/*
Attribution:

[1] Soprano tone

Downloaded on April 3rd, 2014
Soprano
Performer: Kristen Butchatsky
Technicians: UNKNOWN
http://newt.phys.unsw.edu.au/jw/sounds/singers/low.wav
License: UNKNOWN

Pitch: B-flat-3

See also:
http://newt.phys.unsw.edu.au/jw/soprane.html
http://newt.phys.unsw.edu.au/music/
*/

(
~requestedURL = "http://newt.phys.unsw.edu.au/jw/sounds/singers/low.wav";  // [1]
~targetPath = "~/Desktop/%".format(PathName.new(~requestedURL).fileName).standardizePath;

~size = 8192;  // target wavetable size
~skipTime = 0.9;  // in seconds
~freq = 233.082;  // estimated frequency of waveform @ 0.9 seconds, in Hz - B-flat-3

"\n-----------------\nReceived (bytes):".postln;
Download.new(
    ~requestedURL,
    ~targetPath,
    {  // finishedFunc
        SoundFile.use(
            ~targetPath,
            { |soundFile|
                var sampleFrame = (soundFile.sampleRate * ~skipTime).asInteger;
                ~waveSignal = Signal.readWave(~targetPath, ~size.div(2), sampleFrame, freq: ~freq);
                ~waveTable = ~waveSignal.asWavetable;
                ~waveTable.plot("waveform: %".format(PathName.new(~targetPath).fileName), minval: -1.0, maxval: 1.0);
        })
    }, {  // errorFunc
        Error.new(
            "Failed to download!\n\trequestedURL: %\n\tlocalPath: %\n".format(~requestedURL, ~targetPath)
        ).throw
    }, { |rec, tot|  // progressFunc
        "\t % of %".format(rec, tot).postln;
    }
)
)

