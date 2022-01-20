import 'package:flutter/material.dart';
import 'package:mdns/speaker.dart';

class Item extends StatelessWidget {
  final Speaker speaker;

  const Item({Key? key, required this.speaker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            speaker.name,
            style: const TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Text(
                "IP: ",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const Spacer(),
              Text(
                speaker.ip,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Text(
                "MAC: ",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const Spacer(),
              Text(
                speaker.deviceId,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Text(
                "Time delay: ",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const Spacer(),
              Text(
                speaker.time.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
