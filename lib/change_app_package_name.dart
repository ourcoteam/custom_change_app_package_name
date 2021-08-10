library change_app_package_name;

import 'dart:convert';
import 'dart:io';

import './android_rename_steps.dart';

class ChangeAppPackageName {
  static Future<void> start(List<String> arguments) async {
    final file = File('custom_change_app_package_name.json').readAsStringSync();
    final json = jsonDecode(file);

    final androidId = json['android_id'];
    final iosId = json['ios_id'];
    final iosVersion = json['ios_version'];

    if (safe(androidId)) {
      await AndroidRenameSteps(androidId).process();
    }

    //ios
    final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
    String pbxproj = pbxprojFile.readAsStringSync();

    if (safe(iosId)) {
      pbxproj = pbxproj.replaceAll(RegExp('PRODUCT_BUNDLE_IDENTIFIER.*'), 'PRODUCT_BUNDLE_IDENTIFIER = $iosId;');
    }
    if (safe(iosVersion)) {
      pbxproj = pbxproj.replaceAll(RegExp('MARKETING_VERSION.*'), 'MARKETING_VERSION = $iosVersion;');
    }
    if (safe(iosId) || safe(iosVersion)) {
      pbxprojFile.writeAsStringSync(pbxproj);
    }
    print('All Done\n${jsonEncode(json)}');
  }
}

bool safe(dynamic string) => string != null && string is String && string.isNotEmpty;
