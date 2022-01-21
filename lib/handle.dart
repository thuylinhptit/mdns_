import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mdns/main.dart';
import 'package:multicast_dns/multicast_dns.dart';

class Handle with ChangeNotifier {
  List<SrvResourceRecord> arrSpeaker = [];
  List<int> arrTimeDelay = [];
  List<String> arrIP = [];
  List<String> arrDeviceId = [];

  Future<void> handle() async {
    final MDnsClient client = Platform.isAndroid == true
        ? MDnsClient(rawDatagramSocketFactory: (dynamic host, int port,
            {bool? reuseAddress, bool? reusePort, int? ttl}) {
            return RawDatagramSocket.bind(host, port,
                reuseAddress: true, reusePort: false, ttl: ttl!);
          })
        : MDnsClient();

    await client.start();
    var startTime = DateTime.now().millisecondsSinceEpoch;
    var timeDelay = 0;
    String srv2 = '';
    await for (final PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName))) {
        await client
            .lookup<TxtResourceRecord>(ResourceRecordQuery.text(ptr.domainName))
            .forEach((i) {
          if (i.text.contains('model=Model')) {
            var endTime = DateTime.now().millisecondsSinceEpoch;
            timeDelay = endTime - startTime;
            arrTimeDelay.add(timeDelay);
            arrSpeaker.add(srv);
            var str = i.text;
            var start = "\n";
            var end = "\n";
            var startIndex = str.indexOf(start);
            var endIndex = str.indexOf(end, startIndex + start.length);
            print(str
                .substring(startIndex + start.length, endIndex)
                .substring("deviceid=".length));
            arrDeviceId.add(str
                .substring(startIndex + start.length, endIndex)
                .substring("deviceid=".length));
            srv2 = srv.target;
          }
        });
        await for (final IPAddressResourceRecord ip
            in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target))) {
          if (srv.target == srv2) {
            arrIP.add(ip.address.address);
          }
        }
      }
    }
    client.stop();
    notifyListeners();
    print('Done.');
  }
}
