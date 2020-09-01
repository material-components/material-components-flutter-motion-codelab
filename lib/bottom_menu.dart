import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class BottomSheetMenu extends StatefulWidget {
  const BottomSheetMenu();

  @override
  _BottomSheetMenuState createState() => _BottomSheetMenuState();
}

class _BottomSheetMenuState extends State<BottomSheetMenu> {
  AnimationSpeedSetting _animationSpeedSetting;
  ThemeMode _theme;

  @override
  void initState() {
    super.initState();
    _theme = Provider.of<EmailStore>(context, listen: false).themeMode;
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
          _theme = theme;
        });
        Provider.of<EmailStore>(context, listen: false).themeMode = theme;
      }

      void setAnimationSpeed(AnimationSpeedSetting animationSpeed) {
        state(() {
          _animationSpeedSetting = animationSpeed;
        });
        Provider.of<EmailStore>(context, listen: false).animationSpeed =
            animationSpeed;
        timeDilation = animationSpeed.value;
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
                  for (var theme in ThemeMode.values)
                    RadioListTile(
                      title: Text(theme.name),
                      value: theme,
                      groupValue: _theme,
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
