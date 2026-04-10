import 'package:flutter/material.dart';
import 'package:shopping_list_app/grocery_item.dart';
import 'package:shopping_list_app/new_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/categories.dart';


class GroceryList extends StatefulWidget {                     // Stateful Widget
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();     // Creates _GroceryListState to manage the widget's state
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];                        // List of our added items
  var _isLoading = true;                                       // Whether the app is loading or not
  String? _error;                                              // Error or not [ initially null ]

  @override
  void initState() {                // Overriding the initState method (which runs once when the widget is first created)
    super.initState();              // Fetching the data from the Firebase
    _loadItems();                   // Hence when we open the app for the first time then Items should appear.
  }

  // "async" used because of the future promise (We don't want to block the UI)(Because the network call takes time).
  void _loadItems() async {                                    // Fetches the data from the "Firebase Realtime Database".
    final url = Uri.https('flutter-apps-26500-default-rtdb.firebaseio.com', 'shopping-list.json');
    // (Builds Firebase Realtime Database URL). Firebase URL to fetch the shopping list data.

    try {                                                      // "try" used to handle the potential errors (Like the network erros)
      final response = await http.get(url);                    // HTTP Get request to the URL and waits for the response
      // Above "response" handles all the things that we have obtained from the Firebase.

      if (response.statusCode >= 400) {                        // Preparing for the error in getting the response
        setState(() {                                          // UI Update
          _error = 'Failed to fetch data. Please try again later.';
          _isLoading = false;                                  // No more further uploads
        });
        return;                                                // Stops the execution
      }

      if (response.body == 'null') {                           // When there is nothing to display, then Firebase return the string 'null
        setState(() {
          _isLoading = false;
        });
        return;                                                // Stops the execution
      }

      final Map<String, dynamic> listData = json.decode(response.body);      // Decodes the JSON response into a map
      // dynamic means "anytype". [ Above converts Json to dart map. ]
      final List<GroceryItem> loadedItems = [];                // Temporary list to store the parsed data.

      for (final item in listData.entries) {                   // Looping through the map.
        final category = categories.entries                    // Finding the matching category object
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])   // Compare category title with stored string
            .value;                                            // returns the matching category
        loadedItems.add(                                       // Adding the groceryitem in our list
          GroceryItem(
            id: item.key,                                      // Uses the firebase "key" as ID
            name: item.value['name'],                          // Map ke andar Dictionary or map types
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;                           // _groceryItems are displayed on the screen
        _isLoading = false;
      });
    } 
    catch (error) {                                            // Catching the error
      setState(() {
        _error = 'Something went wrong! Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(       // Waits for the "newItem"
      MaterialPageRoute(                                       // Navigates to the NewItem and awaits result (GroceryItem or null).
        builder: (ctx) => const NewItem(),                     // Opens or navigates to the AddItem screen.
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);                              // Added the new Item in the grocery list.
    });
  }

  void _removeItem(GroceryItem item) async {                   // Async method to remove an item.
    final index = _groceryItems.indexOf(item);                 // Stores the item index for roll_back
    setState(() {
      _groceryItems.remove(item);                              // Remove the item from the list
    });

    // Constructs the URL for deleting the specific item from Firebase.
    final url = Uri.https('flutter-apps-26500-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');

    final response = await http.delete(url);                   // Send a delete request

    if (response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _groceryItems.insert(index, item);                     // If error occurs, then again insert it.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));      // Text shown when no Shopping item is there

    if (_isLoading) {                                                           // We don't get error in getting response from Firebase.
      content = const Center(child: CircularProgressIndicator());               // ProgressIndicator
    }

    if (_groceryItems.isNotEmpty) {                                             // When we have List items 
      content = ListView.builder(                                               // Efficiently builds list items on demand
        itemCount: _groceryItems.length,                                        // Number of items to display
        itemBuilder: (ctx, index) => Dismissible(                               // itemBuilder: Function creating each list item
          onDismissed: (direction) {                                            // Swipe to delete functionality
            _removeItem(_groceryItems[index]);                                  // Calls _removeitem when swipe
          },
          key: ValueKey(_groceryItems[index].id),                               // Uniquely identifying the list items
          child: ListTile(                                                      // Standard List item layout
            title: Text(_groceryItems[index].name),
            leading: Container(                                                 // Coloring the square shape to show category
              width: 24,                                                        // Leading means pehle (Text se)
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),                         // Representing the quantity
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));                                   // Showing the error, When we have one
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,               // When we press the AppBar Plus icon, then we move to "newItem" screen
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
