import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart';

class FirestorePage extends StatefulWidget {
  const FirestorePage({super.key});
  @override
  FirestorePageState createState() => FirestorePageState();
}

class FirestorePageState extends State<FirestorePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  void _addNote() async {
    if (connectUser == null) return;
    if (pickedFile != null) {
      await uploadFile();
    }
    await notes.add({
      'id': UniqueKey().toString(),
      'user': connectUser,
      'title': _titleController.text,
      'content': _contentController.text,
      'image': urlDownload
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
    await notes.where('id', isEqualTo: id).get().then((value) {
      doc = value.docs[0].reference;
      doc
          .set({
            'user': connectUser,
            'title': _titleController.text,
            'content': _contentController.text,
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 3))
          .catchError((onError) {});
    });
  }

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? urlDownload;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<Map<String, dynamic>> _loadImages(path) async {
    final result = FirebaseStorage.instance.ref('files/$path');
    final String fileUrl = await result.getDownloadURL();
    final FullMetadata fileMeta = await result.getMetadata();
    final file = {
      "url": fileUrl,
      "path": result.fullPath,
      "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
      "description": fileMeta.customMetadata?['description'] ?? 'No description'
    };
    return file;
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() {});
    setState(() {
      uploadTask = null;
    });
    urlDownload = await snapshot.ref.getDownloadURL();
    print("url : $urlDownload");
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                  ),
                  Center(
                    child: Text('${(100 * progress).roundToDouble()}%'),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(height: 50);
          }
        },
      );

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
                if (connectUser == null)
                  return const Text("You should log in to see your notes");
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
                        child: Flexible(
                          child: ListTile(
                              leading: data['image'] == null
                                  ? const Icon(Icons.image, size: 20)
                                  : Image.network(data['image'],
                                      fit: BoxFit.contain),
                              title: Text(data['title']),
                              subtitle: Text(data['content']),
                              onLongPress: () async => showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
                                              onPressed: () => Navigator.pop(
                                                  context, 'cancel'),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () {
                                                _modifyNote(data['id']);
                                              },
                                              child: const Text('Modify')),
                                        ],
                                      ))),
                        ));
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
                    ElevatedButton(
                        onPressed: selectFile,
                        child: const Text("Select a picture"))
                  ]),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, 'cancel'),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => _addNote(), child: const Text('Add')),
                    buildProgress()
                  ],
                )),
        child: const Icon(Icons.add),
      ),
    );
  }
}
