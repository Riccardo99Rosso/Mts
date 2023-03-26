
// writing
(
var path, file;
path = thisProcess.nowExecutingPath.replace("fileWriter.scd", "file.txt");
file = File(path.standardizePath, "w");
file.write("funziona?\n");
file.write("forse si\n");
file.close;
)

// appending
(
var path, file;
path = thisProcess.nowExecutingPath.replace("fileWriter.scd", "file.txt");
file = File(path.standardizePath, "a");
file.write("Ancora una riga\n");
file.close;
)

// reading
(
var path, file, strings;
path = thisProcess.nowExecutingPath.replace("fileWriter.scd", "file.txt");
file = File(path.standardizePath, "r");
strings = file.readAllString;
strings = strings.replace("\n", "#");
strings.post;
file.close;
)