import 'dart:convert';
import 'dart:io';

class Adb {
  late String pathAdb;
  Adb(this.pathAdb);
  Future<ProcessResult> exec(
    List<String> commands, {
    String? deviceId,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    return Process.run(
      pathAdb,
      (deviceId is String && deviceId.isNotEmpty) ? ["-s", deviceId, ...commands] : commands,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stderrEncoding: stderrEncoding,
      stdoutEncoding: stdoutEncoding,
    );
  }

  getProp(String prop, {String? deviceId}) async {
    var res = await exec(['shell', 'getprop', prop], deviceId: deviceId);
    return res.stdout;
  }

  getModel(String? deviceId) async {
    var res = await exec(['shell', 'getprop', 'ro.product.model'], deviceId: deviceId);
    return res.stdout;
  }

  getBrand(String? deviceId) async {
    var res = await exec(['shell', 'getprop', 'ro.product.brand'], deviceId: deviceId);
    return res.stdout;
  }

  devices({
    String? deviceId,
  }) async {
    var result = await exec(["devices"], deviceId: deviceId);
    var res = LineSplitter.split(result.stdout);
    List<Map> devicesList = [];
    for (var value in res) {
      if (value.contains("List of devices attached")) {
        continue;
      }
      if (value.contains("device")) {
        var deviceLine = value.split("\t");
        if (deviceLine.isEmpty) {
          continue;
        }
        var device = deviceLine[0];
        var brand = await getProp("ro.product.brand", deviceId: device);
        var model = await getProp("ro.product.model", deviceId: device);
        devicesList.add({"device_id": device, "brand": brand, "model": model});
      }
    }
    return devicesList;
  }

  Future<List<String>> ls(
    String pathFolder, {
    String? deviceId,
  }) async {
    var result = await exec(["shell", "ls", "-F", pathFolder], deviceId: deviceId);
    var paths = result.stdout.toString().split("\n").toList();
    List<String> array = [];
    for (var i = 0; i < paths.length; i++) {
      // ignore: non_constant_identifier_names
      var loop_data = paths[i];
      if (loop_data.isNotEmpty) {
        if (loop_data.startsWith("/")) {
          array.add(loop_data);
        } else {
          array.add("/${loop_data.toString()}");
        }
      }
    }
    return array;
  }

  Future<Map<String, dynamic>> request(String method, {Map? parameters, String? deviceId}) async {
    parameters ??= {};
    Map<String, dynamic> jsonResult = {
      "ok": false,
      "result": {},
    };
    late bool isFoundMethod = false;
    if (RegExp(r"getProp", caseSensitive: false).hasMatch(method)) {
      var prop = await getProp(parameters["prop"], deviceId: deviceId);
      isFoundMethod = true;
      jsonResult["result"]["prop"] = prop;
    }
    if (isFoundMethod) {
      jsonResult["ok"] = true;
      return jsonResult;
    } else {
      return jsonResult;
    }
  }
}
