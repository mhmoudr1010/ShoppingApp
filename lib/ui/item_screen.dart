import 'package:flutter/material.dart';
import 'package:shopping/ui/list_item_dialog.dart';
import 'package:shopping/ui/shopping_list_dialog.dart';

import '../models/list_items.dart';
import '../models/shopping_list.dart';
import '../util/dbhelper.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key, required this.shoppingList});

  final ShoppingList shoppingList;

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  DbHelper? helper;
  List<ListItem>? items;

  late ListItemDialog dialog;

  @override
  void initState() {
    dialog = ListItemDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    helper = DbHelper();
    showData(widget.shoppingList.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoppingList.name),
      ),
      body: ListView.builder(
        itemCount: (items != null) ? items?.length : 0,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(items![index].name),
            onDismissed: (direction) {
              String strName = items![index].name;
              helper?.deletItem(items![index]);
              setState(() {
                items?.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$strName deleted"),
                duration: const Duration(seconds: 2),
              ));
            },
            child: ListTile(
              title: Text(items![index].name),
              subtitle: Text(
                  'Quantity: ${items?[index].quantity} - Note: ${items?[index].note}'),
              onTap: () {
                // to do editing
              },
              trailing: IconButton(
                  onPressed: () {
                    // edit the item
                    showDialog(
                      context: context,
                      builder: (context) =>
                          dialog.buildDialog(context, items![index], false),
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
                context,
                ListItem(
                    id: 0,
                    idList: widget.shoppingList.id,
                    name: '',
                    note: '',
                    quantity: ''),
                true),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future showData(int idList) async {
    await helper?.openDb();
    items = await helper?.getItems(idList);
    setState(() {
      items = items;
    });
  }
}
