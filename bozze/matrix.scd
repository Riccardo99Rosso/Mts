(
~counter = 0;
~size = 6;
~matrix = Array2D(~size, ~size);

~addSynth = {
	~counter = ~counter + 1;
};

~addLink = {
	arg sender, receiver;
	~matrix.put(sender, receiver, 1);
};

~removeLink = {
	arg sender, receiver;
	~matrix.put(sender, receiver, nil);
};

~print = {
	arg matrix = [], size = 10;

	matrix.rowsDo({
		arg row;
		row.postln;
	});
};

)
~addLink.(1,2)
~addLink.(3,5)
~removeLink.(1,2)



~print.(~matrix, ~size);

















