import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';

Future<void> main() async {
  const String name = '_airplay._tcp.local';
  final MDnsClient client = MDnsClient();
  //  final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
  //      (dynamic host, int port, {bool?reuseAddress, bool? reusePort, int? ttl}) {
  //    return RawDatagramSocket.bind(host, port, reuseAddress: true, reusePort: false, ttl: ttl! );
  //  });
  await client.start();
  String srv2='';
  await for (final PtrResourceRecord ptr in client
      .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
    await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName))) {
      final String bundleId = ptr.domainName;
      print('DEVICE: '
          '${srv.target}:${srv.port} for "$bundleId".');
      await client
          .lookup<TxtResourceRecord>(ResourceRecordQuery.text(ptr.domainName))
          .forEach((i) {
        if (i.text.contains('model=Model')) {
          print(i.text);
          srv2 = srv.target;
        }
      });
      await for (final IPAddressResourceRecord ip
      in client.lookup<IPAddressResourceRecord>(
          ResourceRecordQuery.addressIPv4(srv.target))) {
        if( srv.target == srv2 ){
          print(ip.address);
        }

      }
    }
  }
  client.stop();

  print('Done.');
}
