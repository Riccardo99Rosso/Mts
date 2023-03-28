(
SynthDef(\Out2, {
	arg in=0, out=0;
	var sig;

	sig = In.ar(in);
	Out.ar(out, sig.dup(2));
}).add;
)