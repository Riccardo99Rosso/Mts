(
var win, mainVue, s, synths, clicked = nil, relativeWhere, synthTypes,
myX, myY;
var mtsDict, mtsSynth;
/*** INITIALIZATIONS ***/
s = Server.local;


/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("mtsMain.scd", "");
~mtsConstantsPath = ~path ++ "mtsConstants.scd";
~mtsSynthPath = ~path ++ "mtsSynth.scd";
mtsDict = FileLoader(~mtsConstantsPath);
mtsSynth = FileLoader(~mtsSynthPath);

/*** WINDOWS GENERATOR ***/
win = Window(mtsDict[\title], Rect(
	mtsDict[\mainX],
	mtsDict[\mainY],
	mtsDict[\mainWidth],
	mtsDict[\mainHeight]),
).layout_(
	VLayout(
		View().fixedHeight_(45).layout_(HLayout(
			ToolBar(
				MenuAction("File", {
					"File".postln;
					Menu(
						MenuAction("New", {
							"New".postln
						})
						.shortcut_("Ctrl+n"),
						MenuAction("Open", {
							"Open".postln
						})
						.shortcut_("Ctrl+o"),
						MenuAction("Save", {
							"Save".postln
						})
						.shortcut_("Ctrl+s"),
						MenuAction("Save as...", {
							"Save as...".postln
						})
						.shortcut_("Ctrl+shift+s"),
					).front;
				}).font_(mtsDict[\menuFont]),
				MenuAction("Edit", {
					"Edit".postln }
				).font_(mtsDict[\menuFont]),
				MenuAction("Put", {
					"Pur".postln }
				).font_(mtsDict[\menuFont]),
				MenuAction("Help", {
					"Help".postln }
				).font_(mtsDict[\menuFont])
			);
		)),
		mainVue = UserView(win, Rect(
			0,
			0,
			mtsDict[\mainWidth],
			mtsDict[\mainHeight]
		));
	).margins_(0)
).front;
win.acceptsMouseOver = true;
mainVue.background = mtsDict[\mainBackground];
mainVue.resize = 5;


/*** MAIN GUI DRAWING ***/
mainVue.drawFunc = {
	synths.do { |x, i|
		Pen.addOval(x);
		Pen.color = mtsDict[\synthColor];
		Pen.draw;
	};
	Pen.stroke
};


/*** MOUSE ACTIONS ***/
mainVue.mouseDownAction = {
	arg v, x, y, mod, button, clkCount;

	postf("Click: (%,%)\n", x, y);

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
				var synthGen;

				synthGen = mtsSynth[\newSynth].(mainVue, x, y);
				synths = synths.add(synthGen[0]);
				synthTypes = synthTypes.add(synthGen[1]);
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
				#synths, clicked =
				mtsSynth[\deleteSynth].(synths, clicked, synthTypes);
				win.refresh;
			})
		).front;

	};
};

mainVue.mouseMoveAction = {
	arg v, x, y;
	var synth, synthTmp, synthTypeTextTmp, tFieldTmp, rectTmp;

	if((clicked.notNil) &&
		(x.asInteger > 0) &&
		(y.asInteger > 0) &&
		(x.asInteger <= (mainVue.bounds.width)) &&
		(y.asInteger <= (mainVue.bounds.height))){

		#synths, synthTypes, clicked =
		mtsSynth[\synthMovement].(
			x, y, synths, synthTypes, clicked, mainVue, relativeWhere);

		win.refresh;
	};
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

		synthGen = mtsSynth[\newSynth].(mainVue, myX, myY);
		synths = synths.add(synthGen[0]);
		synthTypes = synthTypes.add(synthGen[1]);
		win.refresh;
	};

	[view, char, modifiers, unicode,keycode].postln;
};

mainVue.mouseUpAction = {
	clicked = nil;
};


/*** CLOSING ALL ***/
win.onClose = {Window.closeAll; Server.freeAll;};

)