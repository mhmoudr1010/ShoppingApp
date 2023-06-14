import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/list_items.dart';
import '../models/shopping_list.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    db ??= await openDatabase(
      join(await getDatabasesPath(), "shopping.db"),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE lists(id INTEGER PRIMARY KEY, name TEXT, priority INTEGER)');
        db.execute(
            'CREATE TABLE items(id INTEGER PRIMARY KEY, idList INTEGER, name TEXT, quantity TEXT, note TEXT, '
            'FOREIGN KEY(idList) REFERENCES lists(id))');
      },
      version: version,
    );
    return db!;
  }

  Future testDb() async {
    db = await openDb();
    await db?.execute('INSERT INTO lists VALUES (0, "Fruit", 2)');
    await db?.execute(
        'INSERT INTO items VALUES (0, 0, "Apples", "2 Kg", "Better if they are green")');
    List lists = await db!.rawQuery('select * from lists');
    List items = await db!.rawQuery('select * from items');
  }

  Future<int> insertList(ShoppingList list) async {
    int id = await db!.insert('lists', list.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  Future<int> deleteList(ShoppingList list) async {
    int result =
        await db!.delete('items', where: 'idList = ?', whereArgs: [list.id]);
    result = await db!.delete('lists', where: 'id = ?', whereArgs: [list.id]);
    return result;
  }

  Future<int> insertItem(ListItem item) async {
    int id = await db!.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> deletItem(ListItem item) async {
    int result =
        await db!.delete('items', where: 'id = ?', whereArgs: [item.id]);
    return result;
  }

  Future<List<ShoppingList>> getLists() async {
    final List<Map<String, dynamic>> maps =
        await db?.query('lists') as List<Map<String, dynamic>>;
    return List.generate(
      maps.length,
      (index) {
        return ShoppingList(
            id: maps[index]['id'],
            name: maps[index]['name'],
            priority: maps[index]['priority']);
      },
    );
  }

  Future<List<ListItem>> getItems(int idList) async {
    final List<Map<String, dynamic>> maps =
        await db?.query('items', where: 'idList = ?', whereArgs: [idList])
            as List<Map<String, dynamic>>;
    return List.generate(
      maps.length,
      (index) {
        return ListItem(
          id: maps[index]['id'],
          idList: maps[index]['idList'],
          name: maps[index]['name'],
          quantity: maps[index]['quantity'],
          note: maps[index]['note'],
        );
      },
    );
  }
}
