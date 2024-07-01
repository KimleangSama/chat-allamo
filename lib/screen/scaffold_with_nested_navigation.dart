import 'dart:io';

import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  final EdgeInsetsGeometry appNavBarPadding = Platform.isAndroid
      ? const EdgeInsets.only(
          top: 6.0,
          left: 12.0,
          right: 12.0,
          bottom: 4.0,
        )
      : const EdgeInsets.only(
          top: 6.0,
          left: 12.0,
          right: 12.0,
          bottom: 28.0,
        );

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<SharedPreferences>();
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: appNavBarPadding,
        child: GNav(
          gap: 8,
          haptic: isHapticFeedback(prefs),
          color: textColor,
          activeColor: textColor,
          iconSize: 24,
          tabBackgroundColor: Colors.grey.shade50.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          duration: const Duration(milliseconds: 300),
          tabs: const [
            GButton(
              icon: FluentIcons.home_20_regular,
              text: 'Chat',
            ),
            GButton(
              icon: FluentIcons.heart_20_regular,
              text: 'Favorites',
            ),
            GButton(
              icon: FluentIcons.apps_20_regular,
              text: 'Models',
            ),
            GButton(
              icon: FluentIcons.info_20_regular,
              text: 'Info',
            )
          ],
          onTabChange: _goBranch,
        ),
      ),
    );
  }
}
