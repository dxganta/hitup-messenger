import 'package:coocoo/models/ChatMessage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager db = DBManager._();

  Database _database;

  final String chatsTable = "Chats";
  final String phoneNumberColumn = "phoneNumber";
  final String chatIdColumn = "chatId";
  final String nameColumn = 'name';
  final String usernameColumn = 'username';
  final String msgColumn = "msg";
  final String timeColumn = "time";
  final String photoUrlColumn = "photoUrl";
  final String msgTypeColumn = 'msgType';
  final String isContactColumn = 'isContact';
  final String blockStatusColumn = 'blockStat'; // 0 => Blocked, 1 => Unblocked

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, "chat_database.db"),
      version: 1,
      // onCreate is called only if there was no prior database in the specified path
      onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE $chatsTable ($phoneNumberColumn TEXT PRIMARY KEY, $chatIdColumn TEXT, "
            "$nameColumn TEXT, $usernameColumn TEXT, $msgColumn TEXT, $msgTypeColumn TEXT,"
            " $timeColumn INTEGER, $photoUrlColumn TEXT, $isContactColumn INTEGER, $blockStatusColumn INTEGER)");
      },
    );
  }

  Future<void> updateMessageToDb(
      String chatId, String newMsg, String msgType, int currTime) async {
    final Database db = await database;

    int numOfUpdates = await db.rawUpdate(
        "UPDATE $chatsTable SET $msgColumn = ?, $timeColumn = ?, $msgTypeColumn = ? WHERE $chatIdColumn = ?",
        [newMsg, currTime, msgType, chatId]);

    print("$numOfUpdates rows were changed in Chats Table");
  }

  Future<ChatMessage> readMessageFromDb(String chatId) async {
    final Database db = await database;

    List<Map<String, dynamic>> res = await db.query(chatsTable,
        columns: [msgColumn, msgTypeColumn, timeColumn, chatIdColumn],
        where: "$chatIdColumn = ?",
        whereArgs: [chatId]);

    ChatMessage chatMessage = ChatMessage.fromMap(res[0]);

    print("Most recent message read From Db :::::::: $chatMessage");
    return chatMessage;
  }

  Future<List<Map<dynamic, dynamic>>> getAllMessages() async {
    final Database db = await database;

    var res = await db.query(chatsTable, where: "$msgColumn IS NOT NULL");
    List<Map> output = List<Map>.from(res);

    return output;
  }

  Future<void> updateProfilePicInDb(String photoUrl, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $chatsTable SET $photoUrlColumn = ? WHERE $chatIdColumn = ?",
      [photoUrl, chatId],
    );
  }

  Future<List<Map<dynamic, dynamic>>> getAllContacts() async {
    final Database db = await database;

    var res = await db.query(
      chatsTable,
      columns: [
        phoneNumberColumn,
        nameColumn,
        usernameColumn,
        photoUrlColumn,
        chatIdColumn
      ],
      where: "$isContactColumn = ?",
      whereArgs: [1],
    );
    List<Map> output = List<Map>.from(res);

    return output;
  }

  Future<void> createRow(String phoneNum, String chatId, String contactName,
      String username, String photoUrl, int isContact) async {
    final Database db = await database;

    await db.insert(
      chatsTable,
      {
        phoneNumberColumn: phoneNum,
        chatIdColumn: chatId,
        nameColumn: contactName,
        usernameColumn: username,
        msgColumn: null,
        msgTypeColumn: null,
        timeColumn: null,
        photoUrlColumn: photoUrl,
        isContactColumn: isContact,
        blockStatusColumn: 1, // At first it will be unblocked ofcourse
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteContact(String phoneNum) async {
    final Database db = await database;

    await db.delete(chatsTable,
        where: "$phoneNumberColumn = ?", whereArgs: [phoneNum]);
  }

  Future<bool> checkIfContactExistsInDb(String phoneNumber) async {
    final Database db = await database;

    var result = await db.rawQuery(
      "SELECT COUNT(1) FROM $chatsTable WHERE $phoneNumberColumn = ? LIMIT 1",
      [phoneNumber],
    );
    return result[0]["COUNT(1)"] == 1 ? true : false;
  }

  Future<bool> checkIfUsernameExistsInDb(String username) async {
    final Database db = await database;
    var result = await db.rawQuery(
      "SELECT COUNT(1) FROM $chatsTable WHERE $usernameColumn = ? LIMIT 1",
      [username],
    );
    return result[0]["COUNT(1)"] == 1 ? true : false;
  }

  Future<void> deleteTable() async {
    final Database db = await database;

    await db.delete(chatsTable, where: '1');
  }

  Future<bool> isBlocked(String chatId) async {
    final Database db = await database;

    var res = await db.query(chatsTable,
        columns: [blockStatusColumn],
        where: '$chatIdColumn = ?',
        whereArgs: [chatId]);

    return (res[0]["blockStat"] == 1 ? false : true);
  }

  Future<void> updateBlockStatus(int newStatus, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $chatsTable SET $blockStatusColumn = ? WHERE $chatIdColumn = ?",
      [newStatus, chatId],
    );
  }

  Future<void> updateName(String newName, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $chatsTable SET $nameColumn = ? WHERE $chatIdColumn = ?",
      [newName, chatId],
    );
  }
}
