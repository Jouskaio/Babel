import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

DatabaseFactory get platformDatabaseFactory => databaseFactoryIo;

Future<String> databasePath(String name) async =>
    '${(await getApplicationSupportDirectory()).path}/$name';
