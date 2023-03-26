var dict = Dictionary();
var synthNames =
[
	"In",
	"Out",
	"Midi"
];

dict.put(\mainX, 300);
dict.put(\mainY, 150);
dict.put(\mainWidth, 800);
dict.put(\mainHeight, 600);
dict.put(\mainBackground, Color.gray(0.2));
dict.put(\leftClick, 0);
dict.put(\rightClick, 1);
dict.put(\title, "Mts");
dict.put(\menuFont, Font("Monaco", 16));
dict.put(\synthFont, Font("Monaco", 14));
dict.put(\synthSize, 80);
dict.put(\menuColor, Color.gray(0.5));
dict.put(\synthColor, Color.cyan(0.8));
dict.put(\selSynthBlend, 0.9);
dict.put(\busColor, Color.white(0.8));
dict.put(\busEliminatorColor, Color.red(1));
dict.put(\synthTypeLabelColor, Color.cyan(0.5));
dict.put(\synthGoodTypeLabelColor, Color.cyan(0.9));
dict.put(\synthTypeStringColor, Color.black);
dict.put(\synthNames, synthNames);

dict;