import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:session25/screens/todo_screen.dart';

import 'cubit/todo_cubit.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options:FirebaseOptions(
        apiKey: 'AIzaSyCYycq852LI5N10OkmFIJeSV5yHsob-i3Q',
        appId: '1:32062310167:web:ee486fff07a7f213381952',
        messagingSenderId: '32062310167',
        projectId: 'session-25-f5946',
        authDomain: 'session-25-f5946.firebaseapp.com',
        storageBucket: 'session-25-f5946.firebasestorage.app',
        measurementId: 'G-EV12DTHTN3',
      ));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firestore CRUD',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TodoScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
