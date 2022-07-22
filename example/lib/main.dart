import 'package:flutter/material.dart';
import 'package:smarthphone_tool/smarthphone_tool.dart';

// This is the type used by the popup menu below.
enum Menu { itemOne, itemTwo, itemThree, itemFour }

void main(List<String> args) {
  return runApp(MaterialApp(
    home: AndroidPage(),
  ));
}

class SelectDevice extends StatefulWidget {
  SelectDevice({Key? key}) : super(key: key);

  @override
  State<SelectDevice> createState() => _SelectDeviceState();
}

class _SelectDeviceState extends State<SelectDevice> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AndroidPage extends StatefulWidget {
  AndroidPage({Key? key}) : super(key: key);

  @override
  State<AndroidPage> createState() => _AndroidPageState();
}

class _AndroidPageState extends State<AndroidPage> {
  Adb adb = Adb("adb");
  late String device_id = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          deviceList(),
        ],
      ),
    );
  }

  deviceList() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: PopupMenuButton(
        child: Text("Device"),
        onSelected: (item) {},
        itemBuilder: (BuildContext context) {
          List devices = adb.devicesSync();
          return devices.map((res) {
            late String model = "unknown";
            late String deviceId = "unknown";
            late String brand = "unknown";
            if (res["device_id"] is String && (res["device_id"] as String).isNotEmpty) {
              deviceId = res["device_id"];
            }
            if (res["brand"] is String && (res["brand"] as String).isNotEmpty) {
              brand = res["brand"];
            }
            if (res["model"] is String && (res["model"] as String).isNotEmpty) {
              model = res["model"];
            }
            return PopupMenuItem(
              child: Text(model),
              onTap: () {
                setState(() {
                  device_id = deviceId;
                });
              },
            );
          }).toList();
        },
      ),
    );
  }
}
