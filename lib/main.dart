import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/state/auth.state.dart';
import 'package:test_app/pages/auth/login.dart';
import 'package:test_app/pages/auth/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthState())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Test App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
        routes: {
          'login': (context) => const Login(),
          'register': (context) => const Register(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ButtonBar(
        children: [
          ElevatedButton(
            key: const Key('loginButton'),
            child: const Text('Login'),
            onPressed: () {
              Navigator.pushNamed(context, 'login');
            },
          ),
          ElevatedButton(
            key: const Key('registerButton'),
            child: const Text('Register'),
            onPressed: () {
              Navigator.pushNamed(context, 'register');
            },
          ),
        ],
      ),
    );
  }
}
