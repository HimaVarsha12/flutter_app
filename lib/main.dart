import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'authentication_screen.dart';
import 'person_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String appId = 'uMpMkeocwhu9Uyzu9kEFohs9ozgq3D5x9wYpiZvg';
  const String clientKey = 'bRilcQHYxLTgvL3fplZOJAhEfH4mmu0eyv60YiA7';
  const String parseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    appId,
    parseServerUrl,
    clientKey: clientKey,
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task CRUD with Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthenticationScreen(),
    );
  }
}
