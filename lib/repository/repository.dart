import 'package:highfive/model/high_five_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

final String highfiveTable = 'highfive';
final String phoneTable = 'phone';
final String sendToTable = 'send_to';
final String highfiveModelId = 'highfive_id';
final String id = 'id';
final String phoneId = 'phone_id';
final String phoneNumber = 'phone_number';
final String comment = 'comment';
final String timestamp = 'timestamp';
final String senderId = 'sender_id';
final String acknowledged = 'acknowledged';

Future<Database> getDb() async {
  if (db == null) {
    var databasePath = await getDatabasesPath();
    db = await openDatabase(join(databasePath, 'highfive.db'), onCreate: (db, version) {
      return db
          .execute(
            'CREATE TABLE $highfiveTable($id TEXT PRIMARY KEY, $highfiveModelId INTEGER, $comment TEXT, $timestamp INTEGER, $senderId INTEGER, $acknowledged INTEGER)',
          )
          .then((value) => db.execute('CREATE TABLE $phoneTable($id INTEGER PRIMARY KEY autoincrement, $phoneNumber TEXT)'))
          .then((value) =>
              db.execute('CREATE TABLE $sendToTable($id INTEGER PRIMARY KEY autoincrement, $highfiveModelId TEXT, $phoneId INTEGER)'));
    }, version: 1);
  }
  return db;
}

Future<void> insertReceivedHighFive(HighFiveData highFiveData) {
  return getDb().then((db) {
    return db.query(phoneTable, where: '$phoneNumber = ?', whereArgs: [highFiveData.sender]).then((phone) {
      if (phone != null && phone.length > 0) {
        return phone.first[id];
      } else {
        return db.insert(phoneTable, {phoneNumber: highFiveData.sender});
      }
    });
  }).then((senderPhoneId) => db.insert(highfiveTable, {
        id: highFiveData.documentId,
        highfiveModelId: highFiveData.highfiveId,
        comment: highFiveData.comment,
        timestamp: highFiveData.timestamp,
        senderId: senderPhoneId,
        acknowledged: 0
      }));
}

Future<int> acknowledge(String id) async {
  return await db.update(highfiveTable, {acknowledged: 1});
}

Future<void> deleteRow(String docId) async {
  return await db.delete(highfiveTable, where: '$id = ?', whereArgs: [docId]);
}

Future<List<HighFiveData>> readHighFives() {
  return getDb()
      .then((db) => db.rawQuery('SELECT hf.*, p.$phoneNumber FROM $highfiveTable as hf inner join $phoneTable as p on hf.$senderId=p.$id'))
      .then((rows) {
    return rows.map((row) {
      var highFiveData = HighFiveData(row[phoneNumber], row[highfiveModelId], row[comment], row[timestamp], row[id]);
      highFiveData.acknowledged = row[acknowledged] == null ? false : row[acknowledged] == 1;
      return highFiveData;
    }).toList();
  });
}
