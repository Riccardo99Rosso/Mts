var dict = Dictionary();
var mtsDict, showSynthDef, loadAll;

mtsDict = FileLoader(~mtsConstantsPath);

showSynthDef = {
	var win, scroll, i=0, canvas = View(),
	createSynthDef, layout, dy = Dictionary();

	win  = Window("SynthDef Editor").front.alwaysOnTop_(true);
	scroll = ScrollView(win);

	createSynthDef = {
		arg name="UntitledSynthDef", editName = false;
		var sName;
		var view = View().background_(mtsDict[\synthColor]).layout_(
			HLayout(
				sName = TextField()
				.string_(name)
				.enabled_(editName)
				.font_(mtsDict[\synthFont]),
				Button().states_([["Code"]]).action_({
					var file, path, code, tView, tWin;

					path = mtsDict[\allSynthDefPath] ++
					"/" ++ sName.string ++ ".scd";
					file = File(path.standardizePath, "r");

					if((file.isOpen != false),
						{
							code = file.readAllString;
						},
						{
							code = "";
						}
					);
					file.close;

					tWin = Window(name, Rect(800, 350, 300, 350), false);
					tView = TextView(tWin, Rect(
						0,
						0,
						tWin.bounds.width,
						tWin.bounds.height))
					.font_(mtsDict[\synthFont])
					.string_(code)
					.palette_(QPalette.dark);  // set all colors here


					tWin.layout_(
						VLayout(
							ToolBar(
								MenuAction("Save", {
									file = File(path.standardizePath, "w");
									file.write(tView.string);
									file.close;
								}).font_(mtsDict[\menuFont])
							),
							tView
						).margins_(0).spacing_(0);
					);


					tWin.front.alwaysOnTop_(true);

				}),
				//Button().states_([["Delete"]]).action_({view.remove; i = i - 1;})
			)
		);
		i = i + 1;
		view;
	};

	win.layout_(
		VLayout(
			ToolBar(
				MenuAction("Create SynthDef", {
					layout.insert(createSynthDef.("UntitledSynthDef", true));
				}).font_(mtsDict[\menuFont])
			),
			scroll
		).margins_(0).spacing_(0);
	);

	layout = VLayout();
	canvas.layout = layout;
	scroll.canvas = canvas;
	scroll.canvas.background_(mtsDict[\synthTypeLabelColor]);

	dy.add(\data ->
		PathName(mtsDict[\allSynthDefPath])
		.entries.collect({
			arg sf;
			var file, synthDef, buffer, name;

			sf = sf.fullPath;
			sf = sf.replace(".scd", "");
			buffer = sf.split($\\);
			name = buffer[(buffer.size - 1)];
			layout.insert(createSynthDef.(name, false));
		});
	);
};

loadAll = {
	var dy = Dictionary();
	~synthDefs = [];
	dy.add(\data ->
		PathName(mtsDict[\allSynthDefPath])
		.entries.collect({
			arg sf;
			var file, synthDef, name, buffer;

			sf = sf.fullPath;
			synthDef = File(sf.standardizePath, "r");
			file = synthDef.readAllString;
			this.interpret(file);

			sf = sf.replace(".scd", "");
			buffer = sf.split($\\);
			name = buffer[(buffer.size - 1)];
			~synthDefs = ~synthDefs.add(name);
			synthDef.close;
		});
	);
};


dict.put(\showSynthDef, showSynthDef);
dict.put(\loadAll, loadAll);

dict;