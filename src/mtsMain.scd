(
var win, mainVue, s, synths = [], clicked = nil, relativeWhere, synthTypes = [],
myX, myY, createBus = false, currBus, allBusStart = [],
allBusEnd = [], allBus = [], busReceiver = nil, dirDist, scrollView,
busEliminator = [], filePath = nil, saveAs, save, new, open;
var mtsDict, mtsSynth, mtsWebDoc, mtsFileManager;

/*** INITIALIZATIONS ***/
s = Server.local;


/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("mtsMain.scd", "");
~mtsConstantsPath = ~path ++ "mtsConstants.scd";
~mtsSynthPath = ~path ++ "mtsSynth.scd";
~mtsWebDocPath = ~path ++ "mtsWebDocumentation.scd";
~mtsFileManager = ~path ++"mtsFileManager.scd";
mtsDict = FileLoader(~mtsConstantsPath);
mtsSynth = FileLoader(~mtsSynthPath);
mtsWebDoc = FileLoader(~mtsWebDocPath);
mtsFileManager = FileLoader(~mtsFileManager);

/*** WINDOWS GENERATOR ***/
win = Window(mtsDict[\title] ++ " - untitled.mt");
scrollView = ScrollView(win, Rect(
	0,
	0,
	mtsDict[\mainWidth],
	mtsDict[\mainHeight]));
scrollView.resize = 5;

mainVue = UserView(scrollView, Rect(
	0,
	0,
	4000,
	3000
));

win.layout_(
	VLayout(
		ToolBar(
			MenuAction("File", {
				"File".postln;
				Menu(
					MenuAction("New", {
						new.();
					})
					.shortcut_("Ctrl+n")
					.font_(mtsDict[\menuFont]),
					MenuAction("Open", {
						open.();
					})
					.shortcut_("Ctrl+o")
					.font_(mtsDict[\menuFont]),
					MenuAction("Save", {
						save.();
					})
					.shortcut_("Ctrl+s")
					.font_(mtsDict[\menuFont]),
					MenuAction("Save as...", {
						saveAs.();
					})
					.shortcut_("Ctrl+shift+s")
					.font_(mtsDict[\menuFont]),
				).front;
			}).font_(mtsDict[\menuFont]),
			MenuAction("Edit", {
				Menu(
					MenuAction("Preferences", {
						"Preferences".postln
					}).font_(mtsDict[\menuFont])
				).front
			}).font_(mtsDict[\menuFont]),
			MenuAction("Put", {
				"Put".postln }
			).font_(mtsDict[\menuFont]),
			MenuAction("Audio", {
				Menu(
					MenuAction("Audio drivers", {
						AudioDrivers().booter;
					}).font_(mtsDict[\menuFont])
				).front
			}).font_(mtsDict[\menuFont]),
			MenuAction("Help",{
				Menu(
					MenuAction("About Mts", {
						mtsWebDoc[\webDoc].();
					}).font_(mtsDict[\menuFont])
				).front
			}).font_(mtsDict[\menuFont]);
		),
		scrollView
	).margins_(0).spacing_(0);
);

win.acceptsMouseOver = true;
mainVue.background = mtsDict[\mainBackground];
mainVue.resize = 5;
win.front;

/*** MAIN GUI DRAWING ***/
dirDist = (mtsDict[\synthSize]/2);
mainVue.drawFunc = {
	var endBus, dirPos, theta, j,
	start, end;

	Pen.color = mtsDict[\busColor];
	allBusStart.do{|startBus, i|
		Pen.moveTo(startBus.x@startBus.y);
		endBus = allBusEnd[i];

		theta = atan2(
			endBus.y - startBus.y,
			endBus.x - startBus.x);

		dirPos = Point(
			(endBus.x - (dirDist*cos(theta))),
			(endBus.y - (dirDist*sin(theta)))
		);
		Pen.lineTo(endBus.x@endBus.y);
		Pen.addArc(dirPos, 10, 0*pi, 2*pi);
		Pen.fillStroke;
		busReceiver = nil;
	};

	Pen.color = mtsDict[\busEliminatorColor];
	if(busEliminator[0].notNil){
		start = busEliminator[2];
		end = busEliminator[3];
		Pen.moveTo(start.x@start.y);

		theta = atan2(
			end.y - start.y,
			end.x - start.x);

		dirPos = Point(
			(end.x - (dirDist*cos(theta))),
			(end.y - (dirDist*sin(theta)))
		);
		Pen.lineTo(end.x@end.y);
		Pen.addArc(dirPos, 10, 0*pi, 2*pi);
		Pen.fillStroke;
	};

	Pen.color = mtsDict[\synthColor];
	synths.do { |x, i|
		Pen.addOval(x);
		Pen.draw;
	};
	Pen.stroke;
};

/*** MOUSE ACTIONS ***/
mainVue.mouseDownAction = {
	arg v, x, y, mod, button, clkCount;

	synths.do { |synth, i|
		if(synth.contains(Point(x, y)), {
			clicked = i;
			relativeWhere = Point(x, y) - synth.origin;
		});
	};

	if((button == mtsDict[\rightClick] && clicked == nil), {
		Menu(
			MenuAction.separator.string_("Mts"),
			MenuAction("New synth", {
				#synths, synthTypes = mtsSynth[\newSynth].
				(mainVue, x, y, synths, synthTypes);
				win.refresh;
			}).shortcut_("s"),
			MenuAction("Delete bus", {
				var synths, pos, bTmp;
				busEliminator = busEliminator.add(0);
				busEliminator = busEliminator.add(1);
				busEliminator = busEliminator.add(Point(0,0));
				busEliminator = busEliminator.add(Point(0,0));
				win.refresh;
			}).shortcut_("Ctrl+k"),
			MenuAction("Create Bus", {
				createBus = true;
			}).shortcut_("Ctrl+l"),
		).front;
	});

	if(button == mtsDict[\rightClick] && clicked.notNil){
		Menu(
			MenuAction.separator.string_("Mts"),
			MenuAction("Properties", {
				"Properties".postln;
			}),
			MenuAction("Delete synth", {
				var busSize, toRemove, allBusTmp, i = 0;

				#synths, clicked, synthTypes, allBus, allBusStart, allBusEnd =
				mtsSynth[\deleteSynth].(
					synths, clicked, synthTypes, allBus, allBusStart, allBusEnd
				);
				win.refresh;
			})
		).front;
	};

	if((createBus == true) &&
		(button == mtsDict[\leftClick]) && (clicked.notNil)){

		#allBusStart, allBusEnd, currBus, clicked =
		mtsSynth[\createBus].(allBusStart, allBusEnd, currBus, clicked, synths);

		win.refresh;
	};

	if((busEliminator[0].notNil) && (button == mtsDict[\leftClick]) && (clicked.notNil)){
		busEliminator = mtsSynth[\createBusEliminator].(busEliminator, clicked, synths);

		win.refresh;
	}
};

mainVue.mouseMoveAction = {
	arg v, x, y, mod, button;
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp, rectTmp;

	if((clicked.notNil && busEliminator[0] == nil) &&
		(createBus == false) &&
		(x > 0) &&
		(y > 0) &&
		(x <= (mainVue.bounds.width)) &&
		(y <= (mainVue.bounds.height))){

		#synths, synthTypes, clicked, allBusStart, allBusEnd =
		mtsSynth[\synthMovement].(
			x, y, synths, synthTypes, clicked, mainVue,
			relativeWhere, allBus, allBusStart, allBusEnd);
		win.refresh;
	};

	if((createBus == true)) {
		allBusEnd[currBus] = Point(x, y);
		win.refresh;
	};

	if(busEliminator[0].notNil){
		busEliminator[3] = Point(x, y);
		win.refresh;
	};

	myX = x;
	myY = y;

};

mainVue.mouseUpAction = {
	arg v, x, y, mod, button;
	var i;

	if((button == mtsDict[\leftClick]) && (createBus == true)) {
		createBus = false;


		# allBus, allBusStart, allBusEnd, busReceiver =
		mtsSynth[\busInsertion].(
			synths, busReceiver, clicked, allBus,
			allBusStart, allBusEnd, currBus, x, y
		);

	};

	if((button == mtsDict[\leftClick]) && (busEliminator[0].notNil)){

		synths.do {
			arg synth, i;
			if(synth.contains(Point(x, y)), {
				busReceiver = i;
			});
		};
		if((busReceiver.notNil) && (busReceiver != clicked)){
			i = 0;
			while({i < allBus.size},
				{
					var bus, sender, receiver;

					bus = allBus[i];
					sender = bus.x;
					receiver = bus.y;
					if(((sender == clicked)&&(receiver == busReceiver)),
						{
							allBus.removeAt(i);
							allBusStart.removeAt(i);
							allBusEnd.removeAt(i);

						},
						{
							i = i + 1;
						}
					);
			});
		}
	};

	busEliminator = [];
	clicked = nil;
	win.refresh;
};

mainVue.mouseOverAction = {
	arg v, x, y;

	myX = x;
	myY = y;
};

/*** KEY ACTIONS ***/
mainVue.keyDownAction = {
	arg view, char, modifiers, unicode,keycode;

	if(keycode == 83 && modifiers == 0) {
		var synthGen;

		busReceiver = nil;
		synths.do {
			arg synth, i;
			if(synth.contains(Point(myX, myY)), {
				busReceiver = i;
			});
		};

		if(busReceiver == nil){
			#synths, synthTypes = mtsSynth[\newSynth].
			(mainVue, myX, myY, synths, synthTypes);
			win.refresh;
		}
	};

	if((modifiers == 262144) && (keycode == 75)){
		var synths, pos, bTmp;
		createBus = false;
		busEliminator = [];
		busEliminator = busEliminator.add(0);
		busEliminator = busEliminator.add(1);
		busEliminator = busEliminator.add(Point(0,0));
		busEliminator = busEliminator.add(Point(0,0));
		win.refresh;
	};

	if((modifiers == 262144) && (keycode == 76)){
		busEliminator = [];
		createBus = true;
	};

	if((modifiers == 393216) && (keycode == 83)){
		saveAs.();
	};

	if((modifiers == 262144) && (keycode == 83)){
		save.();
	};

	if((modifiers == 262144) && (keycode == 78)){
		new.();
	};

	if((modifiers == 262144) && (keycode == 79)){
		open.();
	};

	//[view, char, modifiers, unicode, keycode].postln;
};


/*** CLOSING ALL ***/
win.onClose = {Window.closeAll; Server.freeAll;};


/** FILE FUNCTIONS **/
new = {
	filePath = nil;
	# synths, synthTypes, allBus,
	allBusStart, allBusEnd, busEliminator,
	createBus =
	mtsFileManager[\newFile].(
		synths, synthTypes, allBus,
		allBusStart, allBusEnd,
		busEliminator, createBus
	);
	mainVue.removeAll;
	win.name = mtsDict[\title] ++ " - untitled.mt";
	win.refresh;
};

saveAs = {
	Dialog.savePanel({
		arg path;
		var name;
		filePath = path;
		# name =
		mtsFileManager[\saveFile].(
			path, synths, synthTypes, allBus,
			allBusStart, allBusEnd
		);
		win.name = mtsDict[\title] ++ " - " ++ name;
	},{
	});
};

save = {
	if(filePath == nil,
		{
			Dialog.savePanel({
				arg path;
				var name;
				filePath = path;
				# name =
				mtsFileManager[\saveFile].(
					path, synths, synthTypes, allBus,
					allBusStart, allBusEnd
				);
				win.name = mtsDict[\title] ++ " - " ++ name;
			},{
			});
		},
		{
			mtsFileManager[\saveFile].(
				filePath, synths, synthTypes, allBus,
				allBusStart, allBusEnd
			);
		}
	);
};

open = {
	Dialog.openPanel({
		arg path;
		var name;
		new.();
		filePath = path;
		# synths, synthTypes, allBus,
		allBusStart, allBusEnd, name =
		mtsFileManager[\openFile].(path, mainVue);
		win.name = mtsDict[\title] ++ " - " ++ name;
		win.refresh;
	},{
		"cancelled".postln;
	});
};


)