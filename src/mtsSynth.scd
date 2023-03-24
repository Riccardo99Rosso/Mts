var dict = Dictionary();
var mtsDict, synthCreator, synthTerminator, synthMovement;

mtsDict = FileLoader(~mtsConstantsPath);

synthCreator = {
	arg mainVue, x, y, synths, synthTypes;
	var synth, tFieldTmp;

	synth = Rect(x-10, y-10, mtsDict[\synthSize], mtsDict[\synthSize]);
	tFieldTmp = TextField(mainVue,
		Rect(
			x-3,
			y+16,
			65,
			30)).align_(\center);
	tFieldTmp.font = mtsDict[\synthFont];
	tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
	tFieldTmp.stringColor_(mtsDict[\synthTypeStringColor]);
	tFieldTmp.action = {
		arg field;

		"messo".postln;

		if(((mtsDict[\synthNames].find([field.value])) != nil),
			{
				tFieldTmp.background_(mtsDict[\synthGoodTypeLabelColor]);
			},
			{
				tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
			}
		);
	};
	synthTypes = synthTypes.add(tFieldTmp);
	synths = synths.add(synth);
	[synths, synthTypes];
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
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp,
	rectTmp, labelBackground, oldAction;

	synth = synths.at(clicked);
	synths.put(clicked, synth.origin =
		(Point(x.asInteger, y.asInteger) - relativeWhere.asPoint));

	synthTmp = Rect(0,0,
		(mtsDict[\synthSize].asInteger-20),
		(mtsDict[\synthSize].asInteger-20)
	);
	synthTmp.origin = (Point(x+10, y+10) - relativeWhere);

	synthTypeTextTmp = synthTypes[clicked].string;
	oldAction = synthTypes[clicked].action;
	labelBackground = synthTypes[clicked].background;
	synthTypes[clicked].remove;
	rectTmp = Rect(0,0,65,30);
	rectTmp.origin = (Point(x+7,y+26) - relativeWhere);
	tFieldTmp = TextField(mainVue, rectTmp).align_(\center);
	tFieldTmp.font = mtsDict[\synthFont];
	tFieldTmp.background_(labelBackground);
	tFieldTmp.stringColor_(mtsDict[\synthTypeStringColor]);
	tFieldTmp.string = synthTypeTextTmp;
	tFieldTmp.action = {
		arg field;

		if(((mtsDict[\synthNames].find([field.value])) != nil),
			{
				tFieldTmp.background_(mtsDict[\synthGoodTypeLabelColor]);
			},
			{
				tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
			}
		);
	};
	synthTypes[clicked] = tFieldTmp;

	[synths, synthTypes, clicked];
};


dict.put(\newSynth, synthCreator);
dict.put(\deleteSynth, synthTerminator);
dict.put(\synthMovement, synthMovement);

dict;