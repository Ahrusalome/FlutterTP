import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class FirestorePage extends StatelessWidget {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  void _addNote() async {
    await notes.add({
      'id': UniqueKey().toString(),
      'user': connectUser,
      'title': _titleController.text,
      'content': _contentController.text,
    });
  }

  void _deleteNote(id) async {
    DocumentReference doc;
    print(id);
    await notes.where('id', isEqualTo: id).get().then((value) {
      doc = value.docs[0].reference;
      doc.delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
    });
  }

  void _modifyNote(id) async {
    DocumentReference doc;
    await notes.where('id', isEqualTo: id).get().then((value){
      doc = value.docs[0].reference;
      doc.set({
          'user': connectUser,
          'title': _titleController.text,
          'content': _contentController.text,
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 3))
        .catchError((onError) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Center(
        child: Column(children: [
          Text('Welcome ${connectUser ?? "Guest"}'),
          StreamBuilder<QuerySnapshot>(
              stream: notes.where("user", isEqualTo: connectUser).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return Expanded(
                    child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Dismissible(
                      key: Key(UniqueKey().toString()),
                      onDismissed: (direction) async {
                        _deleteNote(data['id']);
                      },
                      child: ListTile(
                          title: Text(data['title']),
                          subtitle: Text(data['content']),
                          onLongPress: () async => showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Modify your note"),
                                    content: Column(children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                            hintText: "Title"),
                                        controller: _titleController,
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                            hintText: "Content"),
                                        controller: _contentController,
                                      ),
                                    ]),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'cancel'),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            _modifyNote(data['id']);
                                          },
                                          child: const Text('Modify')),
                                    ],
                                  ))),
                    );
                  }).toList(),
                ));
              })
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text("Add your note"),
                  content: Column(children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "Title"),
                      controller: _titleController,
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: "Content"),
                      controller: _contentController,
                    ),
                  ]),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, 'cancel'),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => _addNote(), child: const Text('Add')),
                  ],
                )),
        child: const Icon(Icons.add),
      ),
    );
  }
}
