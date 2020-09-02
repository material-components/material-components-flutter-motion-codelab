import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/email_store.dart';

enum AnimationSpeedSetting { normal, slow, slower, slowest }

extension AnimationSpeedSettingExtension on AnimationSpeedSetting {
  double get value {
    switch (this) {
      case AnimationSpeedSetting.normal:
        return 1.0;
        break;
      case AnimationSpeedSetting.slow:
        return 5.0;
        break;
      case AnimationSpeedSetting.slower:
        return 10.0;
        break;
      case AnimationSpeedSetting.slowest:
        return 15.0;
        break;
    }
    return null;
  }
}

extension ThemeModeExtension on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.system:
        return 'System';
        break;
      case ThemeMode.light:
        return 'Light';
        break;
      case ThemeMode.dark:
        return 'Dark';
        break;
    }
    return null;
  }
}

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet();

  @override
  _SettingsBottomSheetState createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  AnimationSpeedSetting _animationSpeedSetting;
  ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = Provider.of<EmailStore>(context, listen: false).themeMode;
    _animationSpeedSetting =
        Provider.of<EmailStore>(context, listen: false).animationSpeed;
  }

  @override
  Widget build(BuildContext context) {
    var radius = Radius.circular(12);
    final modalBorder = BorderRadius.only(
      topRight: radius,
      topLeft: radius,
    );

    return StatefulBuilder(builder: (context, state) {
      void setTheme(ThemeMode theme) {
        state(() {
          _themeMode = theme;
        });
        Provider.of<EmailStore>(context, listen: false).themeMode = theme;
      }

      void setAnimationSpeed(AnimationSpeedSetting animationSpeed) {
        state(() {
          _animationSpeedSetting = animationSpeed;
        });
        Provider.of<EmailStore>(context, listen: false).animationSpeed =
            animationSpeed;
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).navigationRailTheme.backgroundColor,
          borderRadius: modalBorder,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: Text('Theme'),
                children: [
                  for (var themeMode in ThemeMode.values)
                    RadioListTile(
                      title: Text(themeMode.name),
                      value: themeMode,
                      groupValue: _themeMode,
                      onChanged: setTheme,
                    ),
                ],
              ),
              ExpansionTile(
                title: Text('Animation Speed'),
                children: [
                  for (var animationSpeed in AnimationSpeedSetting.values)
                    RadioListTile(
                      title: Text('${animationSpeed.value.toInt()}x'),
                      value: animationSpeed,
                      groupValue: _animationSpeedSetting,
                      onChanged: setAnimationSpeed,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
