import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../models/note_model.dart';
import '../models/contact_model.dart';

class DbService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moneyid_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            amount REAL,
            channel TEXT,
            payeePhone TEXT,
            payeeName TEXT,
            type TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            detail TEXT,
            status TEXT,
            timestamp TEXT,
            amount REAL,
            debtType TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            preferredChannel TEXT
          )
        ''');
      },
    );
  }

  // Transaction Operations
  static Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  static Future<List<TransactionModel>> getTransactions({String? query}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'transactions',
        where: 'payeeName LIKE ? OR payeePhone LIKE ? OR channel LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('transactions', orderBy: 'id DESC');
    }
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // Note Operations
  static Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  static Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  static Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<NoteModel>> getNotes({String? filterStatus}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (filterStatus != null && filterStatus != 'all') {
      maps = await db.query(
        'notes',
        where: 'status = ?',
        whereArgs: [filterStatus],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('notes', orderBy: 'id DESC');
    }
    return maps.map((m) => NoteModel.fromMap(m)).toList();
  }

  // Contact Operations
  static Future<int> insertContact(PayeeContact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  static Future<List<PayeeContact>> getContacts({String? query}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'contacts',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('contacts', orderBy: 'id DESC');
    }
    return maps.map((m) => PayeeContact.fromMap(m)).toList();
  }

  static Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
