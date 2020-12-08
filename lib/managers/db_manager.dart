import 'package:coocoo/models/ChatMessage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager db = DBManager._();

  Database _database;

  // final String contactsTable = "Contacts";
  final String messagesTable = "Messages";
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
  final String msgStatusColumn = "msgStatus"; // 0=> Received, 1=> Sent

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
        // we need 3 tables
        // 1. for storing users data
        // await db.execute(
        //     "CREATE TABLE $contactsTable ($phoneNumberColumn TEXT PRIMARY KEY, $chatIdColumn TEXT, "
        //     "$nameColumn TEXT, $usernameColumn TEXT,"
        //     "$photoUrlColumn TEXT, $isContactColumn INTEGER, $blockStatusColumn INTEGER)");

        // 2. for storing the messages for the chat screen
        await db.execute("CREATE TABLE $messagesTable ("
            "$chatIdColumn TEXT, $msgColumn TEXT, $msgTypeColumn TEXT, "
            "$timeColumn INTEGER, $msgStatusColumn INTEGER)");

        // 3. for storing the last message to show in the home screen in the chat cards
        await db.execute(
            "CREATE TABLE $chatsTable ($phoneNumberColumn TEXT PRIMARY KEY, $nameColumn TEXT,"
            "$chatIdColumn TEXT, $usernameColumn TEXT, $photoUrlColumn TEXT, $isContactColumn INTEGER, $blockStatusColumn INTEGER,"
            " $msgColumn TEXT, $msgTypeColumn TEXT, "
            "$timeColumn INTEGER)");
      },
    );
  }

  Future<void> updateMessageToChatTable(
      String chatId, String newMsg, String msgType, int currTime) async {
    final Database db = await database;

    int numOfUpdates = await db.rawUpdate(
        "UPDATE $chatsTable SET $msgColumn = ?, $timeColumn = ?, $msgTypeColumn = ? WHERE $chatIdColumn = ?",
        [newMsg, currTime, msgType, chatId]);

    print("$numOfUpdates rows were changed in Chats Table");
  }

  Future<void> addNewMessageToMessagesTable(String chatId, String newMsg,
      String msgType, int currTime, int msgStatus) async {
    final Database db = await database;

    await db.insert(
      messagesTable,
      {
        chatIdColumn: chatId,
        msgColumn: newMsg,
        msgTypeColumn: msgType,
        timeColumn: currTime,
        msgStatusColumn: msgStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<ChatMessage> readMessageFromChatTable(String chatId) async {
    final Database db = await database;

    List<Map<String, dynamic>> res = await db.query(chatsTable,
        columns: [
          msgColumn,
          msgTypeColumn,
          timeColumn,
          chatIdColumn,
          msgStatusColumn
        ],
        where: "$chatIdColumn = ?",
        whereArgs: [chatId]);

    ChatMessage chatMessage = ChatMessage.fromMap(res[0]);

    print("Most recent message read From Db :::::::: $chatMessage");
    return chatMessage;
  }

  Future<List<ChatMessage>> readAllMessagesfromMessagesTable(
      String chatId) async {
    final Database db = await database;

    var res = await db
        .query(messagesTable, where: "$chatIdColumn = ?", whereArgs: [chatId]);

    return res.map((e) => ChatMessage.fromMap(e)).toList();
  }

// get all conversations from chat table to show in the home page
  Future<List<Map<dynamic, dynamic>>> getAlConversationsFromChatTable() async {
    final Database db = await database;

    var res = await db.query(chatsTable, where: "$msgColumn IS NOT NULL");
    List<Map> output = List<Map>.from(res);

    return output;
  }

  Future<void> updateProfilePicInChatsTable(
      String photoUrl, String chatId) async {
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
        photoUrlColumn: photoUrl,
        isContactColumn: isContact,
        blockStatusColumn: 1, // At first it will be unblocked ofcourse
        msgColumn: null,
        msgTypeColumn: null,
        timeColumn: null,
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

// check if contact is blocked or unblocked
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
