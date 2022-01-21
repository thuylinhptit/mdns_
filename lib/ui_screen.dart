import 'package:flutter/material.dart';
import 'package:mdns/handle.dart';
import 'package:mdns/item.dart';
import 'package:mdns/speaker.dart';
import 'package:provider/provider.dart';

class UIScreen extends StatefulWidget {
  const UIScreen({Key? key}) : super(key: key);

  @override
  _UIScreen createState() => _UIScreen();
}

class _UIScreen extends State<UIScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Device'),
      ),
      body: Consumer<Handle>(
        builder: (context, _, child) {
          return RefreshIndicator(
              child: ListView.builder(
                itemCount: _.arrSpeaker.length,
                itemBuilder: (context, i) {
                  return Item(
                      speaker: Speaker(_.arrSpeaker[i].name, _.arrIP[i],
                          _.arrDeviceId[i], _.arrTimeDelay[i]));
                },
              ),
              onRefresh: _refreshLocal);
        },
      ),
    );
  }
  Future<Null> _refreshLocal() async {
    Provider.of<Handle>(context, listen: false).arrSpeaker.clear();
    Provider.of<Handle>(context, listen: false).handle();
  }
}

