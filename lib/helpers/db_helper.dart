import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper dbHelper = DBHelper._();

  final String studentsTable = "students";
  final String colId = "id";
  final String colName = "name";
  final String colAge = "age";
  final String colCourse = "course";
  final String colImage = "image";

  Database? db;

  Future<void> init() async {
    var directoryPath = await getDatabasesPath();
    String path = join(directoryPath, "demo.db");

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        String query =
            "CREATE TABLE IF NOT EXISTS $studentsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colAge INTEGER, $colCourse TEXT, $colImage BLOB);";

        await db.execute(query);
      },
    );
  }

  Future<int> insertRecord(
      {required String name,
      required int age,
      required String course,
      Uint8List? image}) async {
    await init();

    String query =
        "INSERT INTO $studentsTable($colName, $colAge, $colCourse, $colImage) VALUES(?, ?, ?, ?);";
    List args = [name, age, course, image];

    int id =
        await db!.rawInsert(query, args); // returns no. of inserted record's id

    return id;
  }

  Future<List<Map<String, dynamic>>> fetchAllRecords() async {
    await init();

    String query = "SELECT * FROM $studentsTable";

    List<Map<String, dynamic>> allData = await db!.rawQuery(query);

    return allData;
  }

  Future<int> updateRecord(
      {required String name,
      required int age,
      required String course,
      Uint8List? image,
      required int id}) async {
    await init();

    String query =
        "UPDATE $studentsTable SET $colName=?, $colAge=?, $colCourse=?, $colImage=? WHERE $colId=?";
    List args = [name, age, course, image, id];

    int res = await db!
        .rawUpdate(query, args); // returns total no. of updated records

    return res;
  }

  Future<int> deleteRecord({required int id}) async {
    await init();

    String query = "DELETE FROM $studentsTable WHERE id=?";
    List args = [id];

    int res = await db!
        .rawDelete(query, args); // returns total no. of deleted records

    return res;
  }

  Future<int> deleteAllRecords() async {
    await init();

    String query = "DELETE FROM $studentsTable;";

    int id = await db!.rawDelete(query);

    return id;
  }

  Future<List<Map<String, dynamic>>> fetchSearchedRecords(
      {required String name}) async {
    await init();

    String query =
        "SELECT * FROM $studentsTable WHERE $colName LIKE '%$name%' OR $colCourse LIKE '%$name%';";

    List<Map<String, dynamic>> searchedData = await db!.rawQuery(query);

    return searchedData;
  }
}
