import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tp_firebase/pages/notes.dart';
import 'firebase_options.dart';
import 'pages/authentification.dart';
import 'pages/notes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Main(),
        '/auth': (context) => AuthPage(),
        '/notes': (context) => FirestorePage()
      },
      onGenerateRoute: (settings) {
        return null;
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main'),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuthPage()));
              },
              child: const Text("Authentification")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FirestorePage()));
              },
              child: const Text("Notes page")),
          ElevatedButton(
              onPressed: () async {
                final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                firebaseAuth.signOut();
                const AlertDialog(title: Text("Logged out"));
              },
              child: const Text("Log out"))
        ],
      )),
    );
  }
}

CollectionReference notes = FirebaseFirestore.instance.collection('notes');
CollectionReference users = FirebaseFirestore.instance.collection('users');

String? connectUser;

void connectedUser() async {
  await FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      connectUser = "guest";
    } else {
      connectUser = user.email;
    }
  });
}

// String connectedUserName() {
//   User? connectedUser;
//   FirebaseAuth.instance.userChanges().listen((User? user) {
//     if (user == null) {
//       print('User is currently signed out!');
//     } else {
//       connectedUser = user;
//       users.where("email", isEqualTo: connectedUser?.email).get().then(
//           (querySnapshot) {
//         for (var docSnapshot in querySnapshot.docs) {}
//       }, onError: (e) => print("Error completing: $e"));
//     }
//   });
//   return "guest";
// }
