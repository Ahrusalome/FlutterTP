import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tp_firebase/pages/notes.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  void _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e is FirebaseAuthException) {
        print('Authentification Error : ${e.message}');
        _addNote('Error',
            'Authentification error, please make sure you have entered a valid email');
      } else {
        print('Error : ${e.message}');
        _addNote('Error', 'An unexpected error has occured');
      }
      return;
    }
    _addNote('Success', 'You have successfully registered');
  }

  void _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        print('Error with credentials : ${e.message}');
        _addNote('Error',
            'Authentification error, please make sure you have entered a valid password');
      } else if (e is FirebaseAuthException) {
        print('Authentification Error : ${e.message}');
        _addNote('Error', 'Authentification error');
      } else {
        print('Error : ${e.message}');
        _addNote('Error', 'An unexpected error has occured');
      }
      return;
    }
    print('Successfully logged in with email : ${_emailController.text}');
    _addNote('Success',
        'Successfully logged in with email : ${_emailController.text}');
  }

  // void _addUser() async {
  //   try {
  //     await users.add({
  //       'username': '_usernameController.text',
  //       'email': '_emailController.text'
  //     });
  //   } catch (e) {
  //     print('Error adding user : $e');
  //   }
  // }

  // void _sendData() {
  //   _register();
  //   _addUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification'),
      ),
      body: Center(
          child: Column(
        children: [
          // TextField(
          //   decoration: const InputDecoration(hintText: "Username"),
          //   controller: _usernameController,
          // ),
          TextField(
            decoration: const InputDecoration(hintText: "Email"),
            controller: _emailController,
          ),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password"),
            controller: _passwordController,
          ),
          ElevatedButton(onPressed: _register, child: const Text("Register")),
          ElevatedButton(
              onPressed: () {
                _login();
                connectedUser();
              },
              child: const Text("Login"))
        ],
      )),
    );
  }

  _addNote(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context, 'ok'),
                      child: const Text('ok')),
                ]));
  }
}
