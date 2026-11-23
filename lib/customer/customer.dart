/// Represents a customer in the Airline Management System.
///
/// Stores the customer's personal information, including their name,
/// address, birthday, and optional database ID.
class Customer {
  /// The unique database ID assigned to the customer.
  ///
  /// This value is null when a customer has not yet been assigned
  /// an ID by the database.
  final int? id;

  /// The customer's first name.
  final String firstName;

  /// The customer's last name.
  final String lastName;

  /// The customer's residential address.
  final String address;

  /// The customer's birthday stored as a String.
  final String birthday;

  /// Creates a [Customer] object.
  ///
  /// [id] is optional because the database may assign it when the
  /// customer is saved.
  ///
  /// All other fields are required to create a customer.
  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.birthday,
  });
}