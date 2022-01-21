import 'package:flutter/material.dart';
import 'package:mdns/handle.dart';
import 'package:mdns/item.dart';
import 'package:provider/provider.dart';

class UIScreen extends StatelessWidget {
  const UIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Device'),
      ),
      body: Consumer<Handle>(
        builder: (context, handle, child) {
          return RefreshIndicator(
              child: ListView.builder(
                itemCount: handle.arrSpeaker.length,
                itemBuilder: (context, i) {
                  return Item(
                      speaker: Provider.of<Handle>(context, listen: false)
                          .arrSpeaker[i]);
                },
              ),
              onRefresh: () async {
                Provider.of<Handle>(context, listen: false)
                    .refreshLocal(context);
              });
        },
      ),
    );
  }
}
