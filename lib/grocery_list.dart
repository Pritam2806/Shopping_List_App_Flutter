import 'package:flutter/material.dart';
import 'package:shopping_list_app/grocery_item.dart';
import 'package:shopping_list_app/new_item.dart';

class GroceryList extends StatefulWidget {                      // Stateful widget because 
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();                  // Creates _GroceryListState to manage the widget's state
  }    
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  // Hum jab newItem screen par jaayege, then uss time humaare paas value nahi hogi (Hence async use kar rahe (Promise))
  void _addItem() async {                        // async because navigation returns a future
    final newItem = await Navigator.of(context).push<GroceryItem>(               
      MaterialPageRoute(                         // Redirecting to new page [ Navigation ]
        builder: (ctx) => const NewItem(),       // Navigator.push(): Opens "NewItem" screen as a new route
      ),
    );

    if (newItem == null) {                       // Return nothing or do nothing on the main screen 
      return;
    }

    setState(() {                                // setState(): Triggers UI rebuild to show the new item
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {                                // setState(): Triggers UI rebuild to show the new item
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));          // Text shown when no Shopping item is there

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,                       // When we press the AppBar Plus icon, then we move to newItem screen
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
