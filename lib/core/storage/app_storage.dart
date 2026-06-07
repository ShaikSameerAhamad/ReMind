import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract final class AppStorage {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _initialized = true;
  }

  static Future<Box<Map>> openSavedItemsBox() async {
    await ensureInitialized();
    return Hive.openBox<Map>('saved_items');
  }
}
