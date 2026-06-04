import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartDatabaseHelper {
  static final CartDatabaseHelper instance = CartDatabaseHelper._init();
  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cart_items ADD COLUMN categoryId TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE cart_items ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE cart_items ADD COLUMN isRecommended INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        price         REAL NOT NULL,
        image         TEXT NOT NULL,
        categoryId    TEXT NOT NULL,
        rating        REAL NOT NULL DEFAULT 0.0,
        description   TEXT,
        isRecommended INTEGER NOT NULL DEFAULT 0,
        quantity      INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  // ── INSERT or UPDATE ────────────────────────────────────────────────────────
  Future<void> upsertItem({
    required String id,
    required String name,
    required double price,
    required String image,
    required double rating,
    required int quantity,
    required String categoryId,
    String? description,
    required bool isRecommended,
  }) async {
    final db = await database;
    await db.insert(
        'cart_items',
        {
          'id': id,
          'name': name,
          'price': price,
          'image': image,
          'categoryId': categoryId,
          'rating': rating,
          'description': description,
          'isRecommended': isRecommended ? 1 : 0,
          'quantity': quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── UPDATE QUANTITY ONLY ────────────────────────────────────────────────────
  Future<void> updateQuantity(String id, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ONE ──────────────────────────────────────────────────────────────
  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  // ── DELETE ALL ──────────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // ── FETCH ALL ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchAllItems() async {
    final db = await database;
    return await db.query('cart_items');
  }

  // ── CLOSE ───────────────────────────────────────────────────────────────────
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
