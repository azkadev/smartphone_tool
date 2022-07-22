import 'package:smarthphone_tool/smarthphone_tool.dart';

void main(List<String> arguments) async {
  Adb adb = Adb("adb");
  var result = await adb.devices();
  print(result);
}
