(
SynthDef(\Mic, {
	arg in=0, out=0;
	var sig;

	sig = SoundIn.ar(in);
	Out.ar(out, sig);
}).add;
)