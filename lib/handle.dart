import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mdns/main.dart';
import 'package:mdns/speaker.dart';
import 'package:multicast_dns/multicast_dns.dart';

class Handle with ChangeNotifier {
  List<Speaker> arrSpeaker = [];
  List<Speaker> arrCache = [];
  bool isLoading = false;

  handle() async {
    arrSpeaker.clear();
    var startTime = DateTime.now().millisecondsSinceEpoch;
    var timeDelay = 0;
    final MDnsClient client = Platform.isAndroid == true
        ? MDnsClient(rawDatagramSocketFactory: (dynamic host, int port,
            {bool? reuseAddress, bool? reusePort, int? ttl}) {
            return RawDatagramSocket.bind(host, port,
                reuseAddress: true, reusePort: false, ttl: ttl!);
          })
        : MDnsClient();
    await client.start();
    await for (final PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName))) {
        await client
            .lookup<TxtResourceRecord>(ResourceRecordQuery.text(ptr.domainName))
            .forEach((i) async {
          if (i.text.contains('model=Model') ||
              (i.text.contains('model=LM-MA3') &&
                  i.text.contains('manufacturer=LUMI'))) {
            var str = i.text;
            var start = "\n";
            var end = "\n";
            var startIndex = str.indexOf(start);
            var endIndex = str.indexOf(end, startIndex + start.length);
            var deviceId = str
                .substring(startIndex + start.length, endIndex)
                .substring("deviceid=".length);
            await for (final IPAddressResourceRecord ip
                in client.lookup<IPAddressResourceRecord>(
                    ResourceRecordQuery.addressIPv4(srv.target))) {
              var endTime = DateTime.now().millisecondsSinceEpoch;
              timeDelay = endTime - startTime;
              //print(timeDelay);
              if (arrSpeaker
                      .where((element) => element.ip == ip.address.address)
                      .isEmpty &&
                  arrSpeaker
                      .where((element) => element.name == srv.name)
                      .isEmpty) {
                //print(srv.name);
                arrSpeaker.add(
                    Speaker(srv.name, ip.address.address, deviceId, timeDelay));
                notifyListeners();
              }
              if (arrCache
                      .where((element) => element.ip == ip.address.address)
                      .isEmpty &&
                  arrCache
                      .where((element) => element.name == srv.name)
                      .isEmpty) {
                print(srv.name);
                arrCache.add(
                    Speaker(srv.name, ip.address.address, deviceId, timeDelay));
                notifyListeners();
              }
            }
          }
        });
      }
    }
    for (int x = 0; x < arrSpeaker.length; x++) {
      print(arrSpeaker[x].ip);
    }
    for (int x = 0; x < arrSpeaker.length; x++) {
      if (arrCache.isEmpty ||
          arrCache.where((element) => element.ip == arrSpeaker[x].ip).isEmpty) {
        arrCache.add(arrSpeaker[x]);
      }
    }
    for (int y = 0; y < arrCache.length; y++) {
      if (arrSpeaker.isNotEmpty &&
          arrSpeaker.where((element) => element.ip == arrCache[y].ip).isEmpty) {
        arrCache.remove(arrCache[y]);
      }
      if (arrSpeaker.isEmpty) {
        arrCache.remove(arrCache[y]);
      }
    }
    if (arrSpeaker.length < arrCache.length) {
      arrCache = arrSpeaker;
      notifyListeners();
    }
    client.stop();
    isLoading = false;
    notifyListeners();
    print('DONE');
  }

  Future<void> refreshLocal(BuildContext context) async {
    isLoading = true;
    handle();
    notifyListeners();
  }
}
