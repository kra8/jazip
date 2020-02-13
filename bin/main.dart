// import 'package:jazip/jazip.dart' as jazip;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

final argParser = ArgParser();
final CSV_DATA_FILE_NAME = 'KEN_ALL_ROME.CSV';

void main(List<String> arguments) {
  final argResults = argParser.parse(arguments);
  if (argResults.rest.isEmpty) {
    exit(1);
  }

  final postcode = argResults.rest.first;
  getAddressCSVFile().then((csvFile) => runCommand(csvFile, postcode));
}

void runCommand(File csvFile, String postcode) {
  Stream fileReader = csvFile.openRead();
  fileReader
    .transform(utf8.decoder)
    .transform(LineSplitter())
    .listen(
    (String line) {
      var values = line.split(',');
      if (values.first.contains(postcode)) {
        var output = '${values[1]},${values[2]},${values[3]}'.replaceAll('"', '').replaceAll('　', '');
        stdout.writeln(output);
        exit(0);
      }
    },
    onDone: () => exit(1)
  );
}

String getHomePath() {
  String home;
  final envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }

  return home;
}

Directory configureCacheDirectory() {
  final cacheDir = Directory(path.fromUri('${getHomePath()}/.jazip'));
  if (!cacheDir.existsSync()) {
    cacheDir.createSync();
  }
  return cacheDir;
}

Future<File> getAddressCSVFile() async {
  final cacheDir = configureCacheDirectory();
  final csvPath = path.join(cacheDir.path, CSV_DATA_FILE_NAME);
  final csvFile = File(csvPath);
  if (!csvFile.existsSync()) {
    return fetchAddressData(csvFile);
  }

  var completer = Completer<File>();
  completer.complete(csvFile);
  return completer.future;
}

Future<File> fetchAddressData(File file) async {
  final url = 'https://raw.githubusercontent.com/kra8/jazip/master/data/${CSV_DATA_FILE_NAME}';
  var httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  await response.pipe(file.openWrite());
  return file;
}
