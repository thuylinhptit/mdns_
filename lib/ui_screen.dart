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
                itemCount: handle.arrCache.length + 1,
                itemBuilder: (context, i) {
                  if (i == handle.arrCache.length) {
                    return handle.isLoading == true
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container();
                  } else {
                    return Item(
                        speaker: Provider.of<Handle>(context, listen: false)
                            .arrCache[i]);
                  }
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
