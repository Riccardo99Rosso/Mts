var dict = Dictionary();
var mtsDict, synthCreator, synthTerminator, synthMovement,
busCreator, busInsertion, createBusEliminator, busEliminatorDone,
mtsScSynth, has_cycle;

mtsDict = FileLoader(~mtsConstantsPath);
mtsScSynth = FileLoader(~mtsScSynthPath);

synthCreator = {
	arg mainVue, x, y, synths, synthTypes;
	var synth, tFieldTmp, clicked;
	synth = Rect(x-10, y-10, mtsDict[\synthSize], mtsDict[\synthSize]);
	clicked = synthTypes.size;
	~scSynths = ~scSynths.add(clicked);
	mtsScSynth[\createScSynth].(clicked, "noSynth");
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
				//mtsScSynth[\createScSynth].(clicked, (field.value).asString);
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
	arg synths, clicked, synthTypes, allBusStart, allBusEnd;
	var i = 0;

	// Bus Terminator
	while({i < ~allBus.size},
		{
			var bus, sender, receiver;

			bus = ~allBus[i];
			sender = bus.x;
			receiver = bus.y;
			if(((sender == clicked)||(receiver == clicked)),
				{
					~allBus.removeAt(i);
					allBusStart.removeAt(i);
					allBusEnd.removeAt(i);

				},
				{
					if((sender.notNil) && (sender > clicked)){
						sender = sender-1;
						~allBus[i] = Point(sender, receiver);
					};
					if((receiver.notNil) && (receiver > clicked)){
						receiver = receiver - 1;
						~allBus[i] = Point(sender, receiver);
					};
					i = i + 1;
				}
			);
	});

	//Synths Terminator
	~scSynths[clicked].free;
	synths.removeAt(clicked);
	~scSynths.removeAt(clicked);
	synthTypes[clicked].remove;
	synthTypes.removeAt(clicked);
	clicked = nil;

	[synths, clicked, synthTypes, allBusStart, allBusEnd];
};

synthMovement = {
	arg x, y, synths, synthTypes, clicked, mainVue,
	relativeWhere, allBusStart, allBusEnd;
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp,
	rectTmp, labelBackground, oldAction, centroid;

	// Bus Movement
	centroid = synths[clicked].origin;
	centroid = Point(
		(centroid.x+(mtsDict[\synthSize]/2)),
		(centroid.y)+(mtsDict[\synthSize]/2));

	~allBus.do({
		arg bus, i;
		var sender, receiver;

		sender = bus.x;
		receiver = bus.y;

		if((sender == clicked)){
			allBusStart[i] = centroid;
		};
		if((receiver == clicked)){
			allBusEnd[i] = centroid;
		};

	});

	//Synths Movement
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
		if(((~synthDefs.find([field.value])) != nil),
			{
				tFieldTmp.background_(mtsDict[\synthGoodTypeLabelColor]);
				//mtsScSynth[\createScSynth].(clicked, (field.value).asString);
			},
			{
				tFieldTmp.background_(mtsDict[\synthTypeLabelColor]);
			}
		);
	};
	synthTypes[clicked] = tFieldTmp;

	[synths, synthTypes, clicked, allBusStart, allBusEnd];
};

busCreator = {
	arg allBusStart, allBusEnd, currBus, clicked, synths;
	var centroid;

	centroid = synths[clicked].origin;
	centroid = Point(
		(centroid.x+(mtsDict[\synthSize]/2)),
		(centroid.y)+(mtsDict[\synthSize]/2));
	allBusStart = allBusStart.add(centroid);
	allBusEnd = allBusEnd.add(centroid);
	currBus = allBusStart.size - 1;

	[allBusStart, allBusEnd, currBus, clicked];
};

busInsertion = {
	arg synths, busReceiver, clicked,
	allBusStart, allBusEnd, currBus, x, y, ok=true;
	var centroid, hasCycle = false, visited, stack;

	synths.do {
		arg synth, i;
		if(synth.contains(Point(x, y)), {
			busReceiver = i;
		});
	};

	if(((busReceiver == nil) || (busReceiver == clicked)),
		{
			allBusStart.removeAt(currBus);
			allBusEnd.removeAt(currBus);
		},
		{
			centroid = synths[busReceiver].origin;
			centroid = Point(
				(centroid.x+(mtsDict[\synthSize]/2)),
				(centroid.y)+(mtsDict[\synthSize]/2));
			allBusEnd[currBus] = centroid;

			~allBus.do({
				arg bus, i;
				if((bus.x == clicked) && (bus.y == busReceiver)){
					ok = false;
				}
			});

			if((ok == true),
				{
					~allBus = ~allBus.add(Point(clicked, busReceiver));
					//synths.postln;
					//~allBus.postln;
					if(has_cycle.(synths) == true){
						~allBus.pop();
						allBusStart.removeAt(currBus);
						allBusEnd.removeAt(currBus);
					}

					/*
					~allBus.do({
					arg bus, i;
					~scSynths[bus.y].moveAfter(~scSynths[bus.x]);
					});
					*/

				},
				{
					allBusStart.removeAt(currBus);
					allBusEnd.removeAt(currBus);
				}
			);
		}
	);

	[allBusStart, allBusEnd, busReceiver];
};

createBusEliminator = {
	arg busEliminator, clicked, synths;
	var centroid;

	centroid = synths[clicked].origin;
	centroid = Point(
		(centroid.x+(mtsDict[\synthSize]/2)),
		(centroid.y)+(mtsDict[\synthSize]/2));
	busEliminator[2] = centroid;
	busEliminator[3] = centroid;

	busEliminator;
};

has_cycle = {
	arg nodes;
	var visited = [], stack = [], node = nil, nodi = [], archi = [],
	current = nil, unvisited_neighbours = nil, edge = nil, ret = false;

	//nodi = nodes.asList;
	nodi = Array.fill(nodes.size, {
		arg i;
		i;
	});
	archi = ~allBus;
	//archi.postln;
	while({(nodi.size > 0) && (ret == false)}, {
		node = nodi.pop();
		//nodi.postln;
		//node.postln;
		if(visited.find([node]) == nil){
			visited = visited.add(node);
			stack = stack.add(node);
			//postf("visited: %\n", visited);
			//postf("stack: %\n", stack);
			while({(stack.size > 0) && (ret == false)}, {
				current = stack[stack.size - 1];
				unvisited_neighbours = false;
				archi.do({
					arg edge, i;
					if(edge.x == current){
						if((visited.find([edge.y]) == nil),
							{
								unvisited_neighbours = true;
								visited = visited.add(edge.y);
								stack = stack.add(edge.y);
							},
							{
								if(stack.find([edge.y]) != nil){
									ret = true;
								}
							}
						);
					}
				});
				if(unvisited_neighbours == false){
					stack.pop();
				}
			});
		};

	});

	ret;
};

dict.put(\newSynth, synthCreator);
dict.put(\deleteSynth, synthTerminator);
dict.put(\synthMovement, synthMovement);
dict.put(\createBus, busCreator);
dict.put(\busInsertion, busInsertion);
dict.put(\createBusEliminator, createBusEliminator);

dict;










