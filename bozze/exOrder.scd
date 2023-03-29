(
SynthDef(\sig, {
	arg freq=300, amp=0.2, ctrl=0;
	var sig;
	sig = SinOsc.ar(freq);
	sig = sig * amp;
	Out.ar(3, sig!2);
}).add;

SynthDef(\sig2, {
	arg freq=300, amp=0.2, ctrl=0;
	var sig;
	sig = Saw.ar(freq);
	sig = sig * amp;
	Out.ar(2, sig!2);
}).add;

SynthDef(\sig3, {
	arg freq=300, amp=0.2, ctrl=0;
	var sig;
	sig = Saw.ar(freq);
	sig = sig * amp;
	Out.ar(4, sig!2);
}).add;
)

x = Synth(\sig);
y = Synth(\sig2);
z = Synth(\sig3);
y.moveAfter(x)
x.moveAfter(y)
z.moveAfter(x)

