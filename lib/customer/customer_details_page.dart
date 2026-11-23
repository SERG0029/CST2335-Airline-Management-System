import 'package:flutter/material.dart';
import 'customer_edit_page.dart';

/// Displays detailed information about a selected customer.
///
/// This page displays the customer's first name, last name,
/// address, and birthday. It also allows the user to edit
/// or delete the selected customer.
class CustomerDetailsPage extends StatelessWidget {
  /// Stores the information of the selected customer.
  final Map<String, String> customer;

  /// Creates the customer details page.
  ///
  /// [customer] contains the information to display.
  const CustomerDetailsPage({
    super.key,
    required this.customer,
  });

  /// Creates a card displaying one piece of customer information.
  ///
  /// [label] is the title of the information.
  /// [value] is the customer's information to display.
  /// [icon] is the icon associated with the information.
  ///
  /// Returns a Card containing a ListTile.
  Widget buildDetail(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF123B64)),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }

  /// Displays a confirmation dialog before deleting the customer.
  ///
  /// If the user confirms deletion, the details page returns
  /// true to the previous page. If the user cancels, the
  /// dialog closes without deleting the customer.
  ///
  /// [context] is used to display the dialog and navigate
  /// between pages.
  void deleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete '
                '${customer['firstName']} ${customer['lastName']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the customer details screen.
  ///
  /// Displays the customer's personal information and provides
  /// buttons to edit or delete the customer.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: const Color(0xFF123B64),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF123B64),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${customer['firstName']} ${customer['lastName']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            buildDetail(
              'First Name',
              customer['firstName'] ?? '',
              Icons.person_outline,
            ),

            buildDetail(
              'Last Name',
              customer['lastName'] ?? '',
              Icons.person_outline,
            ),

            buildDetail(
              'Address',
              customer['address'] ?? '',
              Icons.location_on,
            ),

            buildDetail(
              'Birthday',
              customer['birthday'] ?? '',
              Icons.calendar_today,
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () async {
                final updatedCustomer =
                await Navigator.push<Map<String, String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerEditPage(
                      customer: customer,
                    ),
                  ),
                );

                if (!context.mounted) return;

                if (updatedCustomer != null) {
                  Navigator.pop(context, updatedCustomer);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Customer'),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                deleteCustomer(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}