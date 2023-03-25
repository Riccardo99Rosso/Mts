(
var win, mainVue, s, synths, clicked = nil, relativeWhere, synthTypes,
myX, myY, createBus = false, currBus, allBusStart = [],
allBusEnd = [], allBus = [], busReceiver = nil, dirDist, scrollView,
busEliminator = [];
var mtsDict, mtsSynth, mtsWebDoc;
/*** INITIALIZATIONS ***/
s = Server.local;


/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("mtsMain.scd", "");
~mtsConstantsPath = ~path ++ "mtsConstants.scd";
~mtsSynthPath = ~path ++ "mtsSynth.scd";
~mtsWebDocPath = ~path ++ "mtsWebDocumentation.scd";
mtsDict = FileLoader(~mtsConstantsPath);
mtsSynth = FileLoader(~mtsSynthPath);
mtsWebDoc = FileLoader(~mtsWebDocPath);

/*** WINDOWS GENERATOR ***/
win = Window.new;
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
						"New".postln
					})
					.shortcut_("Ctrl+n")
					.font_(mtsDict[\menuFont]),
					MenuAction("Open", {
						"Open".postln
					})
					.shortcut_("Ctrl+o")
					.font_(mtsDict[\menuFont]),
					MenuAction("Save", {
						"Save".postln
					})
					.shortcut_("Ctrl+s")
					.font_(mtsDict[\menuFont]),
					MenuAction("Save as...", {
						"Save as...".postln
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
			MenuAction("Bus eliminator", {
				var synths, pos, bTmp;
				busEliminator = busEliminator.add(0);
				busEliminator = busEliminator.add(1);
				busEliminator = busEliminator.add(Point(0,0));
				busEliminator = busEliminator.add(Point(0,0));
				win.refresh;
			}).shortcut_("Ctrl+q"),

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
				busSize = allBus.size;
				win.refresh;
			}),
			MenuAction("Create Bus", {
				createBus = true;
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
		//busEliminator.postln;
		busEliminator = mtsSynth[\createBusEliminator].(busEliminator, clicked, synths);
		//busEliminator[2].postln;

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
		//busEliminator[3].postln;
		win.refresh;
	}

};

mainVue.mouseUpAction = {
	arg v, x, y, mod, button;
	var relativeWhere, busTmp, centroid, i;

	if((button == mtsDict[\leftClick]) && (createBus == true)) {
		createBus = false;

		synths.do {
			arg synth, i;
			if(synth.contains(Point(x, y)), {
				busReceiver = i;
				relativeWhere = Point(x, y) - synth.origin;
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
				allBus = allBus.add(Point(clicked, busReceiver));
			}
		);

	};

	if((button == mtsDict[\leftClick]) && (busEliminator[0].notNil)){
		synths.do {
			arg synth, i;
			if(synth.contains(Point(x, y)), {
				busReceiver = i;
				relativeWhere = Point(x, y) - synth.origin;
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

		#synths, synthTypes = mtsSynth[\newSynth].
		(mainVue, myX, myY, synths, synthTypes);
		win.refresh;
	};

	//[view, char, modifiers, unicode,keycode].postln;
};


/*** CLOSING ALL ***/
win.onClose = {Window.closeAll; Server.freeAll;};

)