// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smarthphone_tool/smarthphone_tool.dart';

// This is the type used by the popup menu below.
enum Menu { itemOne, itemTwo, itemThree, itemFour }

void main(List<String> args) {
  return runApp(const MaterialApp(
    home: AndroidPage(),
  ));
}

class SelectDevice extends StatefulWidget {
  const SelectDevice({Key? key}) : super(key: key);

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
  const AndroidPage({Key? key}) : super(key: key);

  @override
  State<AndroidPage> createState() => _AndroidPageState();
}

class _AndroidPageState extends State<AndroidPage> {
  Adb adb = Adb("adb");
  late String device_id = "";
  late String pathFolder = "/";
  late String backPathFolder = "/";
  late List<String> currentPathFolder = [backPathFolder];
  late int currentIndexPath = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              deviceList(),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPathFolder = [];
                  });
                },
                child: const Text("alow"),
              ),
            ],
          ),
          Expanded(
            child: ConstrainedBox(constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width), child: lsList()),
          )
        ],
      ),
    );
  }

  lsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  
                  if (currentIndexPath - 1 < 0) {
                    return;
                  }
                  setState(() {
                    currentIndexPath--;
                  });
                },
                child: const Icon(
                  Icons.arrow_back,
                ),
              ),
              InkWell(
                onTap: () {
                  if (currentIndexPath + 1 >= currentPathFolder.length) {
                    return;
                  }
                  setState(() {
                    currentIndexPath++;
                  });
                },
                child: const RotatedBox(
                  quarterTurns: 2,
                  child: Icon(Icons.arrow_back),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {});
                },
                child: const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: adb.ls(currentPathFolder[currentIndexPath], deviceId: device_id),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  late List<String> folders = (snapshot.data as List<String>);
                  if (currentPathFolder.isEmpty) {}
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      var value = folders[index];
                      late IconData icon = Icons.insert_drive_file;
                      late String name = value;
                      if (name.startsWith("/")) {
                        name = name.substring(1);
                      }
                      if (value.endsWith("/")) {
                        icon = Icons.folder;
                        name = name.substring(0, name.length - 1);
                      } else if (value.endsWith("@")) {
                        icon = Icons.attach_file;
                        name = name.substring(0, name.length - 1);
                      } else if (value.endsWith("*")) {
                        name = name.substring(0, name.length - 1);
                      }

                      value = value.replaceAll(RegExp(r"@$", caseSensitive: false), "/");
                      return ListTile(
                        leading: Icon(icon),
                        title: Text(name),
                        onTap: () {
                          if (currentPathFolder.isEmpty) {
                            currentPathFolder.add(value);
                          } else {
                            currentPathFolder.add("${currentPathFolder[currentPathFolder.length - 1]}$value");
                          }
                          setState(() {
                            currentIndexPath++;
                          });
                        },
                      );
                    },
                  );
                }
                if (snapshot.hasError) {
                  if (kDebugMode) {
                    print(snapshot.error);
                  }
                }
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }

  deviceList() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: PopupMenuButton(
        child: const Text("Device"),
        onSelected: (item) {},
        itemBuilder: (BuildContext context) {
          List devices = adb.devicesSync();
          return devices.map((res) {
            late String model = "unknown";
            late String deviceId = "unknown";
            if (res["device_id"] is String && (res["device_id"] as String).isNotEmpty) {
              deviceId = res["device_id"];
            }
            if (res["brand"] is String && (res["brand"] as String).isNotEmpty) {
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
