(
var win, mainVue, s, synths, clicked = nil, relativeWhere, synthTypes,
myX, myY, createBus = false, currBus, allBusStart = [],
allBusEnd = [], allBus = [], busReceiver = nil, dirDist, scrollView;
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
				"Edit".postln }
			).font_(mtsDict[\menuFont]),
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
	var endBus, dirPos, theta;

	Pen.color = mtsDict[\busColor];
	allBusStart.do{|startBus, i|
		//allBus[i].postln;
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
	Pen.color = mtsDict[\synthColor];
	synths.do { |x, i|
		Pen.addOval(x);
		Pen.draw;
	};
	Pen.stroke
};

/*** MOUSE ACTIONS ***/
mainVue.mouseDownAction = {
	arg v, x, y, mod, button, clkCount;
	var centroid;

	//postf("Click: (%,%)\n", x, y);

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
			}),

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

				while({i < allBus.size},
					{
						var bus, sender, receiver;

						bus = allBus[i];
						sender = bus.x;
						receiver = bus.y;
						if(((sender == clicked)||(receiver == clicked)),
							{
								allBus.removeAt(i);
								allBusStart.removeAt(i);
								allBusEnd.removeAt(i);

							},
							{
								if((sender.notNil) && (sender > clicked)){
									sender = sender-1;
									allBus[i] = Point(sender, receiver);
								};
								if((receiver.notNil) && (receiver > clicked)){
									receiver = receiver - 1;
									allBus[i] = Point(sender, receiver);
								};
								i = i + 1;
							}
						);
						allBus.postln;
				});

				#synths, clicked =
				mtsSynth[\deleteSynth].(synths, clicked, synthTypes);
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
		//postf("Start: (%,%)\n", x, y);
		centroid = synths[clicked].origin;
		centroid = Point(
			(centroid.x+(mtsDict[\synthSize]/2)),
			(centroid.y)+(mtsDict[\synthSize]/2));
		allBusStart = allBusStart.add(centroid);
		allBusEnd = allBusEnd.add(centroid);
		currBus = allBusStart.size - 1;
		//clicked = nil;
		win.refresh;
	}
};

mainVue.mouseMoveAction = {
	arg v, x, y, mod, button;
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp, rectTmp, centroid;

	if((clicked.notNil) &&
		(createBus == false) &&
		(x > 0) &&
		(y > 0) &&
		(x <= (mainVue.bounds.width)) &&
		(y <= (mainVue.bounds.height))){

		centroid = synths[clicked].origin;
		centroid = Point(
			(centroid.x+(mtsDict[\synthSize]/2)),
			(centroid.y)+(mtsDict[\synthSize]/2));

		allBus.do({
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

		#synths, synthTypes, clicked =
		mtsSynth[\synthMovement].(
			x, y, synths, synthTypes, clicked, mainVue, relativeWhere);
		win.refresh;
	};

	if((createBus == true)) {
		allBusEnd[currBus] = Point(x, y);
		win.refresh;
	};

};

mainVue.mouseUpAction = {
	arg v, x, y, mod, button;
	var relativeWhere, busTmp, centroid;

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
				win.refresh;
			},
			{
				centroid = synths[busReceiver].origin;
				centroid = Point(
					(centroid.x+(mtsDict[\synthSize]/2)),
					(centroid.y)+(mtsDict[\synthSize]/2));
				allBusEnd[currBus] = centroid;
				allBus = allBus.add(Point(clicked, busReceiver));
				allBus.postln;
				win.refresh;
			}
		);

	};
	//cableStartLinked = nil;
	//cableEndLinked = nil;
	clicked = nil;
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

	if(keycode == 68 && modifiers == 0) {
		var synthGen;

		synths.do { |synth, i|
			if(synth.contains(Point(myX, myY)), {
				clicked = i;
				relativeWhere = Point(myX, myY) - synth.origin;
			});
		};

		#synths, clicked =
		mtsSynth[\deleteSynth].(synths, clicked, synthTypes);
		win.refresh;
	};

	//[view, char, modifiers, unicode,keycode].postln;
};


/*** CLOSING ALL ***/
win.onClose = {Window.closeAll; Server.freeAll;};

)