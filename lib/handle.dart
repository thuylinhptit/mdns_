import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mdns/main.dart';
import 'package:mdns/speaker.dart';
import 'package:multicast_dns/multicast_dns.dart';

class Handle with ChangeNotifier {
  List<Speaker> arrSpeaker = [];
  var startTime = DateTime.now().millisecondsSinceEpoch;
  var timeDelay = 0;

  Future<void> handle() async {
    arrSpeaker.clear();
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
          if (i.text.contains('model=Model')) {
            var endTime = DateTime.now().millisecondsSinceEpoch;
            timeDelay = endTime - startTime;
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
              arrSpeaker.add(
                  Speaker(srv.name, ip.address.address, deviceId, timeDelay));
            }
          }
        });
      }
    }
    client.stop();
    notifyListeners();
  }

  Future<void> refreshLocal(BuildContext context) async {
    arrSpeaker.clear();
    notifyListeners();
    handle();
  }
}
