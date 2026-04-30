/*
Title: additiveBasisFuncs
Date: Thu Apr  9 14:26:05 2026

EE P 598a - Sp26
Authors: Joseph Anderson
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
alternative basis funcs for additive synthesis

*/
s.boot;
s.scope;
FreqScope.new;

// sinusoid wave
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;

	var amp = gain.dbamp;

	SinOsc.ar(freq, phase, amp).dup(2)
}.play
)

// variants on sinusoid wave?


// sinusoid wave - quadrature
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = [0.0, 0.5pi];

	var amp = gain.dbamp;

	SinOsc.ar(freq, phase, amp)
}.play
)

// sinusoid wave - detune in stereo
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;
	var beats = 1.0;

	var amp = gain.dbamp;

	// make freq beating
	freq = freq + (beats / 2 * [1, -1]);

	SinOsc.ar(freq, phase, amp)
}.play
)

// sinusoid wave - detune in mono
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;
	var beats = 1.0;

	var amp = gain.dbamp;

	// make freq beating
	freq = freq + (beats / 2 * [1, -1]);

	SinOsc.ar(freq, phase, amp).sum.dup(2)
}.play
)

// sinusoid wave - ringmod in mono
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;
	var beats = 1.0;
	var amp = gain.dbamp;

	var modOsc = SinOsc.ar(beats / 2);

	SinOsc.ar(freq, phase, amp).dup(2) * modOsc
}.play
)

// sinusoid wave - ringmod in stereo
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;
	var beats = 1.0;
	var modPhase = [0.0, 0.5pi];
	var amp = gain.dbamp;

	var modOsc = SinOsc.ar(beats / 2, modPhase);

	SinOsc.ar(freq, phase, amp).dup(2) * modOsc
}.play
)


// sinusoid wave - ringmod w/ noise in mono
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = 0.0;
	// var noiseFreq = 1.0;
	// var noiseFreq = freq / 1.0;  // around an octave
	// var noiseFreq = freq / 2.0;  // around an 1/2 octave
	// var noiseFreq = freq / 4.0;  // around an 1/4 octave
	var noiseFreq = freq / 20.0;  // around an 1/20 octave
	var amp = gain.dbamp;

	var modNoise = LFNoise2.ar(noiseFreq);

	// modNoise
	SinOsc.ar(freq, phase, amp).dup(2) * modNoise
}.play
)

// sinusoid wave - ringmod w/ noise in stereo
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = [0.0, 0.5pi];
	// var noiseFreq = 1.0;
	// var noiseFreq = freq / 1.0;  // around an octave
	// var noiseFreq = freq / 2.0;  // around an 1/2 octave
	// var noiseFreq = freq / 4.0;  // around an 1/4 octave
	// var noiseFreq = freq / 20.0;  // around an 1/20 octave
	var noiseFreq = freq / 200.0;  // around an 1/200 octave
	var amp = gain.dbamp;

	// var modNoise = LFNoise2.ar(noiseFreq.dup(2));  // returns 2 noise UGens
	var modNoise = LFNoise2.ar(noiseFreq.dup(2)).range(-12.dbamp, 0.dbamp);  // returns 2 noise UGens

	// modNoise
	SinOsc.ar(freq, phase, amp) * modNoise
}.play
)


// sinusoid wave - FM mod w/ noise in stereo
(
{
	var freq = 440.0;
	var gain = -18.0;
	var phase = [0.0, 0.5pi];
	var noiseFreq = 1.0;
	var detuneFreq = 5.0;
	var amp = gain.dbamp;

	var modNoise = LFNoise2.ar(noiseFreq.dup(2), detuneFreq);  // returns 2 noise UGens UGens
	// var modNoise = LFNoise0.ar(noiseFreq.dup(2), detuneFreq);  // returns 2 noise UGens UGens

	// modNoise
	SinOsc.ar(freq + modNoise, phase, amp)
}.play
)



// subtractive synthesis - BPF & WhiteNoise - mono
(
{
	var freq = 440.0;
	var gain = -18.0;
	var amp = gain.dbamp;
	var noise = WhiteNoise.ar(amp);
	// var q = 500.0;
	var q = Line.ar(10.0, 500.0, 10.0);

	BPF.ar(noise, freq, q.reciprocal).dup(2) * q.sqrt;

}.play
)

// subtractive synthesis - BPF & WhiteNoise - stereo
(
{
	var freq = 440.0;
	var gain = 0.0;
	var amp = gain.dbamp;
	var noise = WhiteNoise.ar(amp.dup(2));
	var q = 500.0;
	// var q = Line.ar(10.0, 500.0, 10.0);

	BPF.ar(noise, freq, q.reciprocal) * q.sqrt;

}.play
)


// subtractive synthesis - BPF & Dust - stereo
(
{
	var freq = 440.0;
	var gain = 0.0;
	var amp = gain.dbamp;
	var dustFreq = 20.0;
	var noise = Dust.ar(dustFreq, amp.dup(2));
	var q = 500.0;
	// var q = Line.ar(10.0, 500.0, 10.0);

	BPF.ar(noise, freq, q.reciprocal) * q.sqrt;

}.play
)
