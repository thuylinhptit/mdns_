import 'package:flutter/material.dart';
import 'package:mdns/handle.dart';
import 'package:mdns/ui_screen.dart';
import 'package:provider/provider.dart';

const String name = '_airplay._tcp.local';
Future<void> main() async {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Handle()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<Handle>(context, listen: false).handle();
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UIScreen(),
    );
  }

}


