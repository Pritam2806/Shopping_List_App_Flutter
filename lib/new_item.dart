import 'package:flutter/material.dart';
import 'package:shopping_list_app/categories.dart';
import 'package:shopping_list_app/category.dart';
import 'package:shopping_list_app/grocery_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;                   // "flutter pub add http" in the terminal.

class NewItem extends StatefulWidget {                     // Stateful as UI Updates, as the user types
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // GlobalKey<FormState>() creates a unique key that can access the state of a "Form" widget anywhere in the widget tree
  final _formKey = GlobalKey<FormState>();                             // Tracks "form" validation and saving (Global_Key)
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;          // Default Category
  var _isSending = false;

  void _saveItem() async {                                             // "Async" Function
    // "Validating" the form means checking each input field to make sure the entered data is acceptable before saving it
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();                                   // Save the values if values are validated
      setState(() {
        _isSending = true;
      });

      // Building a secure HTTPS URL for the Firebase Realtime Database endpoint. Resource path "shopping-list.json" is also used
      final url = Uri.https('flutter-apps-26500-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(                       // Sending a POST request to Firebase
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(                                    // Dart Map into json string
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      // Decodes the HTTP response body from JSON into a Dart map.
      // resData now contains Firebase’s response, usually with the generated item ID.
      final Map<String, dynamic> resData = json.decode(response.body);

      // Checks whether the current state object is "still mounted" in the widget tree.
      // Essential after an await, because the widget may have been removed while the network request was in flight.
      // If the widget is no longer mounted, it returns early and avoids using context.
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(                   // Go back to the Main screen with the added data
        GroceryItem(                               // See the "NewItem Async function". Ussi ka data hai
          id: resData['name'],                     // Way to provide the unique id
          name: _enteredName,                      // Taking back the written values
          quantity: _enteredQuantity,              
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,                                              // Important line (What will be used as key)
          child: Column(
            children: [
              TextFormField(                                          // Type of container to get user input
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;                              // onSaved stores the name
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(                             // User input
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,             // Number Keyboard type
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);          // int to string
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(                    // Another type of Dropdown (Modern)
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();              // Reset all the things
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,            // Save a thing
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*

class _NewItemState extends State<NewItem> {
  void _saveItem() {
    if (_formKey.currentState!.validate()) {                             // Validate the form (When we have null form validators)
      _formKey.currentState!.save();                                     // Save field values into state vars
      Navigator.of(context).pop(                                         // Going back where they came from
        GroceryItem(                                                     // Taking back the written values
          id: DateTime.now().toString(),                                 
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }
*/