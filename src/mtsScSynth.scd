var dict = Dictionary();
var properties, createScSynth, freeScSynth;


properties = {
	arg clicked;
	var title;
	if((~scSynths[clicked] != nil),
		{
			title = "~scSynths[" ++ clicked ++ "]";
		},
		{
			title = "No synth"
		}
	);
	Window(title).front;
};

createScSynth = {
	arg clicked, name;

	if((name.containsStringAt(0, "Out") == true),
		{
			name = name.asSymbol;
			~scSynths[clicked] = Synth(name, [\out, 0, \in, ~inGarbageBus]);
		},
		{
			name = name.asSymbol;
			~scSynths[clicked] = Synth(name, [\out, ~garbageBus]);
		}
	);
};

dict.put(\properties, properties);
dict.put(\createScSynth, createScSynth);
dict.put(\freeScSynth, freeScSynth);

dict;