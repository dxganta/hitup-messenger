import 'package:coocoo/models/ChatMessage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  DBManager._();

  static final DBManager db = DBManager._();

  Database _database;

  final String contactsTable = "Contacts";
  final String messagesTable = "Messages";
  final String chatTable = "Chats";

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
        await db.execute(
            "CREATE TABLE $contactsTable ($phoneNumberColumn TEXT PRIMARY KEY, $chatIdColumn TEXT, "
            "$nameColumn TEXT, $usernameColumn TEXT,"
            "$photoUrlColumn TEXT, $isContactColumn INTEGER, $blockStatusColumn INTEGER)");

        // 2. for storing the messages for the chat screen
        await db.execute("CREATE TABLE $messagesTable ("
            "$chatIdColumn TEXT, $msgColumn TEXT, $msgTypeColumn TEXT, "
            "$timeColumn INTEGER, $msgStatusColumn INTEGER)");

        // 3. for storing the last message to show in the home screen in the chat cards
        await db.execute(
            "CREATE TABLE $chatTable ($phoneNumberColumn TEXT PRIMARY KEY,"
            "$chatIdColumn TEXT, $msgColumn TEXT, $msgTypeColumn TEXT, "
            "$timeColumn INTEGER)");
      },
    );
  }

  Future<void> updateMessageToChatTable(String chatId, String newMsg,
      String msgType, int currTime, int msgStatus) async {
    final Database db = await database;

    int numOfUpdates = await db.rawUpdate(
        "UPDATE $chatTable SET $msgColumn = ?, $timeColumn = ?, $msgTypeColumn = ?, $msgStatusColumn = ? WHERE $chatIdColumn = ?",
        [newMsg, currTime, msgType, msgStatus, chatId]);

    print("$numOfUpdates rows were changed in Chats Table");
  }

  Future<void> addNewMessageToMessagesTable(String chatId, String newMsg,
      String msgType, int currTime, int msgStatus) async {
    final Database db = await database;

    // TODO: Implement
  }

  Future<ChatMessage> readMessageFromChatTable(String chatId) async {
    final Database db = await database;

    List<Map<String, dynamic>> res = await db.query(chatTable,
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
    //TODO: Implement
  }

// get all conversations from chat table to show in the home page
  Future<List<Map<dynamic, dynamic>>> getAlConversationsFromChatTable() async {
    final Database db = await database;

    var res = await db.query(chatTable, where: "$msgColumn IS NOT NULL");
    List<Map> output = List<Map>.from(res);

    return output;
  }

  Future<void> updateProfilePicInContactsTable(
      String photoUrl, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $contactsTable SET $photoUrlColumn = ? WHERE $chatIdColumn = ?",
      [photoUrl, chatId],
    );
  }

  Future<List<Map<dynamic, dynamic>>> getAllContacts() async {
    final Database db = await database;

    var res = await db.query(
      contactsTable,
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
//TODO: Need to create row for both chatTable & contactsTable
    await db.insert(
      contactsTable,
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

    await db.delete(contactsTable,
        where: "$phoneNumberColumn = ?", whereArgs: [phoneNum]);
  }

  Future<bool> checkIfContactExistsInDb(String phoneNumber) async {
    final Database db = await database;

    var result = await db.rawQuery(
      "SELECT COUNT(1) FROM $contactsTable WHERE $phoneNumberColumn = ? LIMIT 1",
      [phoneNumber],
    );
    return result[0]["COUNT(1)"] == 1 ? true : false;
  }

  Future<bool> checkIfUsernameExistsInDb(String username) async {
    final Database db = await database;
    var result = await db.rawQuery(
      "SELECT COUNT(1) FROM $contactsTable WHERE $usernameColumn = ? LIMIT 1",
      [username],
    );
    return result[0]["COUNT(1)"] == 1 ? true : false;
  }

  Future<void> deleteTable() async {
    final Database db = await database;

    await db.delete(contactsTable, where: '1');
  }

// check if contact is blocked or unblocked
  Future<bool> isBlocked(String chatId) async {
    final Database db = await database;

    var res = await db.query(contactsTable,
        columns: [blockStatusColumn],
        where: '$chatIdColumn = ?',
        whereArgs: [chatId]);

    return (res[0]["blockStat"] == 1 ? false : true);
  }

  Future<void> updateBlockStatus(int newStatus, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $contactsTable SET $blockStatusColumn = ? WHERE $chatIdColumn = ?",
      [newStatus, chatId],
    );
  }

  Future<void> updateName(String newName, String chatId) async {
    final Database db = await database;

    await db.rawUpdate(
      "UPDATE $contactsTable SET $nameColumn = ? WHERE $chatIdColumn = ?",
      [newName, chatId],
    );
  }
}

//TODO: Change database structure in db_manager file. Need 2 databases now. one to store users. one to store messages
//TODO: Change mqtt_manager. when message is sent update it to the db. also when new message is received update it to the db
//TODO: Print the data and see if everything is working fine or not
//TODO: Change user interface of chat_screen
//TODO: Write logic in chat_screen
