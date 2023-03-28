s.boot;

(
SynthDef(\Mic, {
	arg in=0, out=0;
	var sig;

	sig = SoundIn.ar(in);
	Out.ar(out, sig);
}).add;

SynthDef(\Out, {
	arg in=0, out=0;
	var sig;

	sig = In.ar(in);
	Out.ar(out, sig);
}).add;

SynthDef(\Out2, {
	arg in=0, out=0;
	var sig;

	sig = In.ar(in);
	Out.ar(out, sig.dup(2));
}).add;


)
Server.default.options.numBuffers = 1024;
s.newBusAllocators;

(
var b1, b2, gOut, gIn, xG, oG;
b1 = Bus.audio(s, 1);
b2 = Bus.audio(s, 1);
gOut = Group(s);
gIn = Group(s, \addToHead);

xG = 0;
oG = gOut;

x = Synth(\Mic, [\in, 0, \out, b1], xG);
o = Synth(\Out2, [\in, b1, \out, 0], oG);
xG = Group(s);
)


o.set(\out, 0)

(
a = AudioDrivers();
a.booter;
)
().play
s.latency = 0.2;

s.reboot;

{SoundIn.ar()}.play

s.scope;