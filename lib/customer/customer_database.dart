import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Manages the SQLite database used to store airline customers.
///
/// This class handles creating the customer table and performing
/// database operations such as inserting, retrieving, updating,
/// and deleting customer records.
class AirlineCustomerDB {
  /// Provides a single shared instance of the database manager.
  static final AirlineCustomerDB instance = AirlineCustomerDB._init();

  /// Holds the database instance after it has been opened.
  static Database? _database;

  /// Private constructor used to create the database manager.
  AirlineCustomerDB._init();

  /// Returns the database instance.
  ///
  /// If the database is already open, it returns the existing instance.
  /// Otherwise, it initializes the database.
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('airline_customers.db');
    return _database!;
  }

  /// Opens or creates the SQLite database.
  ///
  /// [fileName] is the name of the database file.
  /// Returns the opened database.
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the customers table when the database is first created.
  ///
  /// The table stores the customer's ID, first name, last name,
  /// address, and birthday.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        address TEXT NOT NULL,
        birthday TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new customer into the database.
  ///
  /// [customer] contains the customer's information.
  ///
  /// Returns the ID assigned to the newly inserted customer.
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;

    return db.insert('customers', customer);
    }

  /// Retrieves all customers from the database.
  ///
  /// Customers are ordered by their ID in descending order,
  /// so the newest customers appear first.
  ///
  /// Returns a list of customer records.
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;

    return db.query(
      'customers',
      orderBy: 'id DESC',
    );
  }

  /// Updates an existing customer's information.
  ///
  /// [id] identifies the customer to update.
  /// [customer] contains the updated customer information.
  ///
  /// Returns the number of records updated.
  Future<int> updateCustomer(
      int id,
      Map<String, dynamic> customer,
      ) async {
    final db = await database;

    return db.update(
      'customers',
      customer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a customer from the database.
  ///
  /// [id] identifies the customer to delete.
  ///
  /// Returns the number of records deleted.
  Future<int> deleteCustomer(int id) async {
    final db = await database;

    return db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}