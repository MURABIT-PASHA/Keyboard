import 'package:flutter/material.dart';
import 'package:keyboard/connection_provider.dart';
import 'package:keyboard/empty_page.dart';
import 'package:keyboard/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Keyboard());
}

class Keyboard extends StatelessWidget {
  const Keyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ConnectionProvider(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ConnectionStateChecker()),
    );
  }
}

class ConnectionStateChecker extends StatelessWidget {
  const ConnectionStateChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionStatus =
        Provider.of<ConnectionProvider>(context, listen: true);
    return connectionStatus.isConnected ? const HomePage() : const EmptyPage();
  }
}