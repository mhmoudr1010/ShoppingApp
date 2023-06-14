import 'package:flutter/material.dart';

import '../models/list_items.dart';
import '../util/dbhelper.dart';

class ListItemDialog {
  final txtName = TextEditingController();
  final txtQuantity = TextEditingController();
  final txtNote = TextEditingController();

  Widget buildDialog(BuildContext context, ListItem list, bool isNew) {
    DbHelper helper = DbHelper();
    if (!isNew) {
      txtName.text = list.name;
      txtQuantity.text = list.quantity;
      txtNote.text = list.note;
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text(
        (isNew ? 'New shopping item' : 'Edit shopping item'),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: txtName,
              decoration: const InputDecoration(
                hintText: 'Item name',
              ),
            ),
            TextField(
              controller: txtQuantity,
              decoration: const InputDecoration(
                hintText: 'Item quantity',
              ),
            ),
            TextField(
              controller: txtNote,
              decoration: const InputDecoration(
                hintText: 'Item note',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                list.name = txtName.text;
                list.quantity = txtQuantity.text;
                list.note = txtNote.text;
                helper.insertItem(list);
                Navigator.pop(context);
              },
              child: const Text('Save item'),
            ),
          ],
        ),
      ),
    );
  }
}
