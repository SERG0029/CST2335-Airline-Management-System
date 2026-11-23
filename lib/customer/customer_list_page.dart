import 'package:flutter/material.dart';
import 'package:airline_management_system/customer/customer_database.dart';
import 'package:airline_management_system/customer/customer_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Displays the customer management page of the Airline Management System.
///
/// This page allows users to:
/// - Add new customers.
/// - View the customer list.
/// - Search customers by name or address.
/// - View customer details.
/// - Edit and delete customer information.
/// - Copy previously entered customer information.
/// - Select customer birthdays.
/// - Switch between English and French.
/// - Access help and instructions.
///
/// Customer information is stored in an SQLite database, while the
/// previous customer's information is stored using Shared Preferences.
class CustomerListPage extends StatefulWidget {
  /// Creates the customer list page.
  const CustomerListPage({super.key});

  /// Creates the state associated with this customer list page.
  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

/// Manages the state and functionality of the customer list page.
class _CustomerListPageState extends State<CustomerListPage> {
  /// Controls the customer's first name input field.
  final TextEditingController firstNameController = TextEditingController();

  /// Controls the customer's last name input field.
  final TextEditingController lastNameController = TextEditingController();

  /// Controls the customer's address input field.
  final TextEditingController addressController = TextEditingController();

  /// Controls the customer's birthday input field.
  final TextEditingController birthdayController = TextEditingController();

  /// Controls the customer search input field.
  final TextEditingController searchController = TextEditingController();

  /// Stores the customers currently displayed and managed by the page.
  final List<Map<String, String>> customers = [];

  /// Stores the currently selected language.
  ///
  /// English is the default language.
  String currentLanguage = 'en';

  /// Returns true when French is the currently selected language.
  bool get isFrench => currentLanguage == 'fr';

  /// Initializes the page and loads customers from the database.
  ///
  /// This method runs when the page is first created.
  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  // --------------------------------------------------
  // TRANSLATIONS
  // --------------------------------------------------

  /// Returns text in the currently selected language.
  ///
  /// [english] contains the English text.
  /// [french] contains the French translation.
  ///
  /// Returns the French text when French is selected,
  /// otherwise returns the English text.
  String translate(String english, String french) {
    return isFrench ? french : english;
  }

  // --------------------------------------------------
  // LOAD CUSTOMERS FROM SQLITE
  // --------------------------------------------------

  /// Loads customer records from the SQLite database.
  ///
  /// Converts database records into string maps and updates
  /// the customer list displayed on the page.
  Future<void> loadCustomers() async {
    final databaseCustomers =
    await AirlineCustomerDB.instance.getCustomers();

    if (!mounted) return;

    setState(() {
      customers.clear();

      for (final customer in databaseCustomers) {
        customers.add({
          'id': customer['id'].toString(),
          'firstName': customer['firstName'].toString(),
          'lastName': customer['lastName'].toString(),
          'address': customer['address'].toString(),
          'birthday': customer['birthday'].toString(),
        });
      }
    });
  }

  // --------------------------------------------------
  // BIRTHDAY DATE PICKER
  // --------------------------------------------------

  /// Opens a date picker to select the customer's birthday.
  ///
  /// The selected date is formatted as YYYY-MM-DD and stored
  /// in the birthday text controller.
  Future<void> selectBirthday() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      helpText: translate(
        'SELECT CUSTOMER BIRTHDAY',
        'SÉLECTIONNER LA DATE DE NAISSANCE',
      ),
    );

    if (pickedDate == null) return;

    birthdayController.text =
    '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

    setState(() {});
  }

  // --------------------------------------------------
  // SAVE PREVIOUS CUSTOMER USING SHARED PREFERENCES
  // --------------------------------------------------

  /// Saves the customer's information to Shared Preferences.
  ///
  /// The information is saved locally so it can be reused
  /// when creating another customer.
  ///
  /// [customer] contains the customer information to save.
  Future<void> savePreviousCustomer(
      Map<String, String> customer) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        'previousFirstName', customer['firstName'] ?? '');
    await prefs.setString(
        'previousLastName', customer['lastName'] ?? '');
    await prefs.setString(
        'previousAddress', customer['address'] ?? '');
    await prefs.setString(
        'previousBirthday', customer['birthday'] ?? '');
  }

  // --------------------------------------------------
  // COPY PREVIOUS CUSTOMER INTO THE FORM
  // --------------------------------------------------

  /// Copies the previously saved customer information into the form.
  ///
  /// If no previous customer exists, displays a SnackBar message.
  /// Otherwise, fills the form with the saved information.
  Future<void> copyPreviousCustomer() async {
    final prefs = await SharedPreferences.getInstance();

    final previousFirstName = prefs.getString('previousFirstName');

    if (previousFirstName == null || previousFirstName.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate(
              'No previous customer information found.',
              'Aucune information sur le client précédent.',
            ),
          ),
        ),
      );
      return;
    }

    firstNameController.text = previousFirstName;
    lastNameController.text =
        prefs.getString('previousLastName') ?? '';
    addressController.text =
        prefs.getString('previousAddress') ?? '';
    birthdayController.text =
        prefs.getString('previousBirthday') ?? '';

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translate(
            'Previous customer information copied!',
            'Les informations du client précédent ont été copiées!',
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ADD CUSTOMER
  // --------------------------------------------------

  /// Validates and saves a new customer.
  ///
  /// Checks that all form fields contain information,
  /// inserts the customer into SQLite, saves the information
  /// for future copying, updates the displayed customer list,
  /// clears the form, and displays a confirmation message.
  Future<void> addCustomer() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        birthdayController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate(
              'Please complete all fields.',
              'Veuillez remplir tous les champs.',
            ),
          ),
        ),
      );
      return;
    }

    final newCustomer = <String, String>{
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "address": addressController.text.trim(),
      "birthday": birthdayController.text.trim(),
    };

    final id = await AirlineCustomerDB.instance.insertCustomer(newCustomer);

    await savePreviousCustomer(newCustomer);

    newCustomer['id'] = id.toString();

    if (!mounted) return;

    setState(() {
      customers.insert(0, newCustomer);
    });

    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    birthdayController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translate(
            'Customer saved successfully!',
            'Client enregistré avec succès!',
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SEARCH CUSTOMERS
  // --------------------------------------------------

  /// Returns customers matching the current search text.
  ///
  /// Searches customer first names, last names, and addresses.
  /// When the search field is empty, returns the complete list.
  List<Map<String, String>> get filteredCustomers {
    final searchText = searchController.text.toLowerCase().trim();

    if (searchText.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final firstName = customer['firstName']!.toLowerCase();
      final lastName = customer['lastName']!.toLowerCase();
      final address = customer['address']!.toLowerCase();

      return firstName.contains(searchText) ||
          lastName.contains(searchText) ||
          address.contains(searchText);
    }).toList();
  }

  // --------------------------------------------------
  // OPEN CUSTOMER DETAILS
  // --------------------------------------------------

  /// Opens the details page for the selected customer.
  ///
  /// Allows the selected customer to be deleted or updated.
  /// Database changes are applied and the displayed customer
  /// list is refreshed when the details page returns.
  ///
  /// [index] is the index of the customer in the filtered list.
  Future<void> openCustomerDetails(int index) async {
    final customer = filteredCustomers[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsPage(
          customer: customer,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final originalIndex = customers.indexWhere(
          (item) => item['id'] == customer['id'],
    );

    if (originalIndex == -1) return;

    // DELETE CUSTOMER

    /// Deletes the selected customer from the database
    /// and removes the customer from the displayed list.
    if (result == true) {
      final id = int.parse(customer['id']!);

      await AirlineCustomerDB.instance.deleteCustomer(id);

      if (!mounted) return;

      setState(() {
        customers.removeWhere((item) => item['id'] == customer['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate(
              'Customer deleted successfully.',
              'Client supprimé avec succès.',
            ),
          ),
        ),
      );
    }

    // UPDATE CUSTOMER

    /// Updates the selected customer's information in the database
    /// and replaces the old information in the displayed list.
    else if (result is Map<String, String>) {
      final id = int.parse(customer['id']!);

      final updatedCustomer = {
        'firstName': result['firstName']!,
        'lastName': result['lastName']!,
        'address': result['address']!,
        'birthday': result['birthday']!,
      };

      await AirlineCustomerDB.instance.updateCustomer(
        id,
        updatedCustomer,
      );

      if (!mounted) return;

      setState(() {
        customers[originalIndex] = {
          'id': customer['id']!,
          ...result,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate(
              'Customer updated successfully.',
              'Client mis à jour avec succès.',
            ),
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // HELP / INSTRUCTIONS
  // --------------------------------------------------

  /// Displays a dialog containing customer management instructions.
  ///
  /// The instructions explain how to add, search, view, edit,
  /// delete, and copy customer information.
  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            translate(
              'Customer Management Help',
              'Aide - Gestion des clients',
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              translate(
                'CUSTOMER INSTRUCTIONS\n\n'
                    '1. Enter the customer first name.\n'
                    '2. Enter the customer last name.\n'
                    '3. Enter the address.\n'
                    '4. Select the birthday using the calendar.\n'
                    '5. Press Add Customer to save.\n'
                    '6. Use Search to find customers by name or address.\n'
                    '7. Click a customer to view, edit, or delete their information.\n'
                    '8. Use Copy Previous Customer to reuse the previous information.',
                'INSTRUCTIONS POUR LES CLIENTS\n\n'
                    '1. Entrez le prénom du client.\n'
                    '2. Entrez le nom de famille du client.\n'
                    '3. Entrez l’adresse.\n'
                    '4. Sélectionnez la date de naissance dans le calendrier.\n'
                    '5. Appuyez sur Ajouter un client pour enregistrer.\n'
                    '6. Utilisez la recherche pour trouver un client par nom ou adresse.\n'
                    '7. Cliquez sur un client pour consulter, modifier ou supprimer ses informations.\n'
                    '8. Utilisez Copier le client précédent pour réutiliser les informations.',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translate('Close', 'Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // LANGUAGE SWITCH
  // --------------------------------------------------

  /// Switches the displayed text between English and French.
  void switchLanguage() {
    setState(() {
      currentLanguage = currentLanguage == 'en' ? 'fr' : 'en';
    });
  }

  // --------------------------------------------------
  // DISPOSE CONTROLLERS
  // --------------------------------------------------

  /// Releases all text controllers when the page is removed.
  ///
  /// Disposing controllers prevents unnecessary resource usage.
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  /// Builds the customer management page interface.
  ///
  /// Displays the customer form, birthday picker, previous
  /// customer copy button, customer count, search field,
  /// and customer list.
  @override
  Widget build(BuildContext context) {
    final visibleCustomers = filteredCustomers;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF123B64),
        foregroundColor: Colors.white,
        elevation: 2,

        title: Row(
          children: [
            const Icon(Icons.flight),
            const SizedBox(width: 10),
            Text(
              translate(
                'Customer Management',
                'Gestion des clients',
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: translate('Help', 'Aide'),
            onPressed: showHelpDialog,
            icon: const Icon(Icons.help_outline),
          ),

          TextButton(
            onPressed: switchLanguage,
            child: Text(
              currentLanguage == 'en' ? 'FR' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // CUSTOMER FORM CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          color: Color(0xFF123B64),
                          size: 28,
                        ),
                        const SizedBox(width: 10),

                        Text(
                          translate(
                            'Add New Customer',
                            'Ajouter un client',
                          ),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: translate('First Name', 'Prénom'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: translate('Last Name', 'Nom'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: translate('Address', 'Adresse'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: birthdayController,
                      readOnly: true,
                      onTap: selectBirthday,
                      decoration: InputDecoration(
                        labelText: translate('Birthday', 'Date de naissance'),
                        hintText: translate(
                          'Select birthday',
                          'Sélectionner une date',
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF123B64),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: addCustomer,
                        icon: const Icon(Icons.person_add),
                        label: Text(
                          translate(
                            'Add Customer',
                            'Ajouter un client',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // COPY PREVIOUS CUSTOMER
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: copyPreviousCustomer,
                icon: const Icon(Icons.copy),
                label: Text(
                  translate(
                    'Copy Previous Customer',
                    'Copier le client précédent',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // CUSTOMER LIST HEADER
            Row(
              children: [
                const Icon(
                  Icons.people_alt,
                  color: Color(0xFF123B64),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    translate('Customers', 'Clients'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123B64),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${customers.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SEARCH BAR
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: translate(
                  'Search by name or address...',
                  'Rechercher par nom ou adresse...',
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // CUSTOMER LIST
            Expanded(
              child: visibleCustomers.isEmpty
                  ? Center(
                child: Text(
                  searchController.text.isEmpty
                      ? translate(
                    'No customers added yet.',
                    'Aucun client pour le moment.',
                  )
                      : translate(
                    'No matching customers found.',
                    'Aucun client correspondant trouvé.',
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: visibleCustomers.length,
                itemBuilder: (context, index) {
                  final customer = visibleCustomers[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF123B64),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        '${customer['firstName']} ${customer['lastName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(customer['address']!),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),

                      onTap: () => openCustomerDetails(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}