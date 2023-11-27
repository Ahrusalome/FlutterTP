// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../main.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   void _register() async {
//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       // Utilisateur enregistré avec succès
//     } on FirebaseAuthException catch (e) {
//       print('Error : ${e.message}');
//     }
//   }

//   void _login() async {
//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       // Utilisateur enregistré avec succès
//     } on FirebaseAuthException catch (e) {
//       print('Error : ${e.message}');
//     }
//   }

//   void _addUser() async {
//     await users.add({
//       'username': _usernameController,
//       'email': _emailController
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Authentification'),
//       ),
//       body: Center(
//           child: Column(
//         children: [
//           TextField(
//             decoration: const InputDecoration(hintText: "Username"),
//             controller: _usernameController,
//           ),
//           TextField(
//             decoration: const InputDecoration(hintText: "Email"),
//             controller: _emailController,
//           ),
//           TextField(
//             decoration: const InputDecoration(hintText: "Password"),
//             controller: _passwordController,
//           ),
//           ElevatedButton(
//               onPressed: () => {
//                 _register,
//                 _addUser()}, child: const Text("Register")),
//           ElevatedButton(onPressed: _login, child: const Text("Login"))
//         ],
//       )),
//     );
//   }
// }
