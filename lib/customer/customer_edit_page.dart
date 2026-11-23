import 'package:flutter/material.dart';

/// A page that allows the user to edit an existing customer's information.
///
/// The page receives customer information and displays it in editable
/// text fields. When the user saves the changes, the updated customer
/// information is returned to the previous page.
class CustomerEditPage extends StatefulWidget {
  /// The customer information that will be edited.
  final Map<String, String> customer;

  /// Creates the customer edit page.
  ///
  /// The [customer] parameter contains the customer's current information.
  const CustomerEditPage({
    super.key,
    required this.customer,
  });

  /// Creates the state for the customer edit page.
  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

/// Manages the state and functionality of the customer edit page.
class _CustomerEditPageState extends State<CustomerEditPage> {
  /// Controller for the customer's first name.
  late TextEditingController firstNameController;

  /// Controller for the customer's last name.
  late TextEditingController lastNameController;

  /// Controller for the customer's address.
  late TextEditingController addressController;

  /// Controller for the customer's birthday.
  late TextEditingController birthdayController;

  /// Initializes the text controllers using the existing customer information.
  @override
  void initState() {
    super.initState();

    firstNameController =
        TextEditingController(text: widget.customer['firstName']);
    lastNameController =
        TextEditingController(text: widget.customer['lastName']);
    addressController =
        TextEditingController(text: widget.customer['address']);
    birthdayController =
        TextEditingController(text: widget.customer['birthday']);
  }

  /// Validates the fields and returns the updated customer information.
  ///
  /// If any field is empty, a SnackBar displays an error message.
  /// Otherwise, the updated information is returned to the previous page.
  void saveChanges() {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        birthdayController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
      return;
    }

    final updatedCustomer = {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'address': addressController.text.trim(),
      'birthday': birthdayController.text.trim(),
    };

    Navigator.pop(context, updatedCustomer);
  }

  /// Releases the resources used by the text controllers.
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  /// Builds the customer editing interface.
  ///
  /// Displays text fields for the customer's information and a button
  /// that saves the changes.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
        backgroundColor: const Color(0xFF123B64),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Update Customer Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(
                labelText: 'Birthday (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}