var dict = Dictionary();
var mtsDict, synthCreator, synthTerminator, synthMovement;

mtsDict = FileLoader(~mtsConstantsPath);
//mtsDict[\synthSize]-(mtsDict[\synthSize]/2)

synthCreator = {
	arg mainVue, x, y;
	var synth, tFieldTmp;
	synth = Rect(x-10, y-10, mtsDict[\synthSize], mtsDict[\synthSize]);
	tFieldTmp = TextField(mainVue,
		Rect(
			x,
			y+21,
			80,
			40)).align_(\center);
	tFieldTmp.font = mtsDict[\synthFont];
	tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
	tFieldTmp.stringColor_(mtsDict[\synthTypeStringColor]);
	[synth, tFieldTmp];
};

synthTerminator = {
	arg synths, clicked, synthTypes;
	synths.removeAt(clicked);
	synthTypes[clicked].remove;
	synthTypes.removeAt(clicked);

	clicked = nil;
	[synths, clicked, synthTypes];
};

synthMovement = {
	arg x, y, synths, synthTypes, clicked, mainVue, relativeWhere;
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp, rectTmp;

	synth = synths.at(clicked);
	synths.put(clicked, synth.origin =
		(Point(x.asInteger, y.asInteger) - relativeWhere.asPoint));

	synthTmp = Rect(0,0,
		(mtsDict[\synthSize].asInteger-20),
		(mtsDict[\synthSize].asInteger-20)
	);
	synthTmp.origin = (Point(x+10, y+10) - relativeWhere);

	synthTypeTextTmp = synthTypes[clicked].string;
	synthTypes[clicked].remove;
	rectTmp = Rect(0,0,80,40);
	rectTmp.origin = (Point(x+10,y+31) - relativeWhere);
	tFieldTmp = TextField(mainVue, rectTmp).align_(\center);
	tFieldTmp.font = mtsDict[\synthFont];
	tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
	tFieldTmp.stringColor_(mtsDict[\synthTypeStringColor]);
	synthTypes[clicked] = tFieldTmp;
	synthTypes[clicked].string = synthTypeTextTmp;

	[synths, synthTypes, clicked];
};


dict.put(\newSynth, synthCreator);
dict.put(\deleteSynth, synthTerminator);
dict.put(\synthMovement, synthMovement);

dict;