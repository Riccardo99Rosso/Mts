var dict = Dictionary();

var webDoc = {
	var browser, webview, reloadStop, prev, next, urlBox, go;

	webview = WebView()
	.minSize_(300@200);
	reloadStop = Button()
	.states_([["※"], ["◙"]])
	.fixedSize_(36@28);
	prev = Button()
	.states_([["⇦"]])
	.fixedSize_(36@28);
	next = Button()
	.states_([["⇨"]])
	.fixedSize_(36@28);
	urlBox = TextField()
	.minWidth_(100);
	go = Button()
	.states_([["Go"]])
	.fixedSize_(36@28);

	reloadStop.action = {
		|v|
		if (v.value == 1) {
			webview.reload(true);
		} {
			webview.stop;
		}
	};

	prev.action = { webview.back };
	next.action = { webview.forward };
	urlBox.action = { webview.url = urlBox.string };
	go.action = { webview.url = urlBox.string };

	webview.onUrlChanged = {
		|view, url|
		urlBox.string = url;
	};

	webview.onLoadStarted = {
		reloadStop.value = 1;
		urlBox.background = Color.grey(0.5);
	};

	webview.onLoadFinished = {
		reloadStop.value = 0;
		urlBox.background = Color.grey(0.6);
	};

	webview.onLoadFailed = {
		reloadStop.value = 0;
		urlBox.background = Color.red(1, 0.2);
	};

	browser = View(bounds:900@700).layout_(VLayout(
		HLayout(
			prev, reloadStop, next,
			urlBox,
			go
		),
		webview
	));

	browser.front;

	urlBox.valueAction = "https://github.com/Riccardo99Rosso/Mts"
};

dict.put(\webDoc, webDoc);

dict;
