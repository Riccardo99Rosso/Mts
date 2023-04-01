var dict = Dictionary();
var mtsDict, newFile, saveFile, openFile;

mtsDict = FileLoader(~mtsConstantsPath);

newFile = {
	arg path, synths, synthTypes,
	allBusStart, allBusEnd, busEliminator, createBus;

	synths = [];
	synthTypes = [];
	~allBus = [];
	allBusStart = [];
	allBusEnd = [];
	busEliminator = [];
	createBus = false;

	[synths, synthTypes, ~allBus,
		allBusStart, allBusEnd, busEliminator, createBus];
};

saveFile = {
	arg path, synths, synthTypes,
	allBusStart, allBusEnd, synthNames = [];
	var file, buffer, name;

	path = path.replace(".mt", "");
	path = path ++ ".mt";
	buffer = path.split($/);
	buffer[(buffer.size - 1)];
	name = buffer[(buffer.size - 1)];

	file = File(path.standardizePath, "w");
	file.write(synths.asString);
	file.write("\n");
	synthTypes.do({
		arg name, i;
		if(name == nil){
			synthNames = synthNames.add("-");
		};
		if(name.notNil){
			synthNames = synthNames.add(name.value);
		};

	});
	file.write(synthNames.asString);
	file.write("\n");
	file.write(~allBus.asString);
	file.write("\n");
	file.write(allBusStart.asString);
	file.write("\n");
	file.write(allBusEnd.asString);
	file.close;

	[name];

};

openFile = {

	arg path, mainVue;
	var synths =  [], synthTypes = [],
	allBusStart = [], allBusEnd = [], buffer, name,
	synthNames = [], toSave, file, tFieldTmp;

	buffer = path.split($/);
	buffer[(buffer.size - 1)];
	name = buffer[(buffer.size - 1)];

	file = File(path.standardizePath, "r");
	toSave = file.readAllString;
	toSave = toSave.split($\n);
	file.close;

	synths = this.interpret(toSave[0]);
	~allBus = this.interpret(toSave[2]);
	allBusStart = this.interpret(toSave[3]);
	allBusEnd = this.interpret(toSave[4]);


	buffer = toSave[1].replace("[", "");
	buffer = buffer.replace("]", "");
	buffer = buffer.replace(" ", "");
	buffer = buffer.split($,);

	synths.do({
		arg synth, i;
		var x, y;

		x = (synth.origin.x+10);
		y = (synth.origin.y+10);

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
			if(((~synthDefs.find([field.value])) != nil),
				{
					tFieldTmp.background_(mtsDict[\synthGoodTypeLabelColor]);
				},
				{
					tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
				}
			);
		};

		tFieldTmp.valueAction = buffer[i].asString;
		buffer[i].postln;
		synthTypes = synthTypes.add(tFieldTmp);

	});

	[synths, synthTypes,
		allBusStart, allBusEnd, name];
};


dict.put(\newFile, newFile);
dict.put(\saveFile, saveFile);
dict.put(\openFile, openFile);

dict;

