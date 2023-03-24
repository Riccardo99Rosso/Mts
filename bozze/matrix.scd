(
var array;
~counter = 0;
~size = 3;
~matrix = Array2D(~size, ~size);

array = ~matrix.asArray;

array.collect({
	arg item, i;
	array[i] = [nil,nil];
});

~matrix = Array2D.fromArray(~size, ~size, array);

~addSynth = {
	~counter = ~counter + 1;
};

~addLink = {
	arg sender, receiver;
	~matrix.put(sender, receiver, [-1,1]);
};

~removeLink = {
	arg sender, receiver;
	~matrix.put(sender, receiver, [nil, nil]);
};

~print = {
	arg matrix = [], size = 10;

	matrix.rowsDo({
		arg row;
		row.postln;
	});
};

)
~addLink.(1,0)
~addLink.(0,1)
~removeLink.(1,2)


~print.(~matrix, ~size);
~matrix.putCol(0, [nil, nil]);

(
for(0, ~size-1, {
	arg i;
	~matrix.put(i,0, [nil, nil])
});
)
l = [];
(
for (0, ~size, {
	arg i;
	for (0, ~size, {
		arg j;
		l = l.add(~matrix.at(i,j));
	})
});
)

l.postln;

~matrix[0] = [nil, nil];
~matrix[,0] = [nil, nil];











