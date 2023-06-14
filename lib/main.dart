import 'package:flutter/material.dart';

import 'util/dbhelper.dart';
import './models/shopping_list.dart';
import './ui/item_screen.dart';
import '../ui/shopping_list_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ShList(),
    );
  }
}

class ShList extends StatefulWidget {
  const ShList({super.key});

  @override
  State<ShList> createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  DbHelper helper = DbHelper();
  List<ShoppingList>? shoppingList;

  late ShoppingListDialog dialog;

  @override
  void initState() {
    dialog = ShoppingListDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      body: ListView.builder(
        itemCount: (shoppingList != null) ? shoppingList?.length : 0,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(shoppingList![index].name),
            onDismissed: (direction) {
              String strName = shoppingList![index].name;
              helper.deleteList(shoppingList![index]);
              setState(() {
                shoppingList?.removeAt(index);
              });
              // insted of Scaffold.of() we use ScaffoldMessenger.of().... ;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$strName deleted')));
            },
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ItemScreen(shoppingList: shoppingList![index]),
                    ));
              },
              title: Text(shoppingList![index].name),
              leading: CircleAvatar(
                child: Text(shoppingList![index].priority.toString()),
              ),
              trailing: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => dialog.buildDialog(
                          context, shoppingList![index], false),
                    );
                  },
                  icon: const Icon(Icons.edit)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => dialog.buildDialog(
                context, ShoppingList(id: 0, name: '', priority: 0), true),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future showData() async {
    await helper.openDb();
    shoppingList = await helper.getLists();
    setState(() {
      shoppingList = shoppingList;
    });
  }
}
