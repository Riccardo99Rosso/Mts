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

b = Bus.audio(s, 1);

(
x = Synth(\Mic, [\in, 0, \out, b]);
o = Synth(\Out2, [\in, b, \out, 0]);
)

o.moveAfter(x);
o.moveBefore(x);


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