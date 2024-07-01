import 'package:chat_allamo/theme/constant.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPreferenceScreen extends StatefulWidget {
  const SettingPreferenceScreen({super.key});

  @override
  State<SettingPreferenceScreen> createState() =>
      _SettingPreferenceScreenState();
}

class _SettingPreferenceScreenState extends State<SettingPreferenceScreen> {
  late bool hapticFeedback; // it is just used for UI state only

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<SharedPreferences>();
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: textColor,
            )),
        backgroundColor: appBarColor,
      ),
      body: SettingsList(
        darkTheme: const SettingsThemeData(settingsListBackground: scaffoldColor),
        sections: [
          SettingsSection(
            title: const Text('DATA'),
            tiles: [
              SettingsTile(
                title: const Text('Dev'),
                trailing: const Text(
                  "kimleang.rscher@gmail.com",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                leading: const Icon(FluentIcons.mail_20_regular),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.navigation(
                title: const Text('Data Controls'),
                leading: const Icon(FluentIcons.database_20_regular),
                onPressed: (BuildContext context) {
                  context.push('/settings/data_controls');
                },
              ),
              SettingsTile.navigation(
                title: const Text('Configurations',
                    style: TextStyle(color: Colors.amber)),
                leading: const Icon(FluentIcons.settings_20_regular),
                onPressed: (BuildContext context) {
                  context.push('/settings/configurations');
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('APP'),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    hapticFeedback = value;
                    prefs.setBool('hapticFeedback', value);
                  });
                },
                initialValue: prefs.getBool('hapticFeedback') ?? true,
                title: const Text('Haptic Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
