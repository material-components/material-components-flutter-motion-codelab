import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/email_store.dart';

enum SlowMotionSpeedSetting { normal, slow, slower, slowest }

extension AnimationSpeedSettingExtension on SlowMotionSpeedSetting {
  double get value {
    switch (this) {
      case SlowMotionSpeedSetting.normal:
        return 1.0;
      case SlowMotionSpeedSetting.slow:
        return 5.0;
      case SlowMotionSpeedSetting.slower:
        return 10.0;
      case SlowMotionSpeedSetting.slowest:
        return 15.0;
    }
  }
}

extension ThemeModeExtension on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({Key? key}) : super(key: key);

  @override
  SettingsBottomSheetState createState() => SettingsBottomSheetState();
}

class SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late SlowMotionSpeedSetting _slowMotionSpeedSetting;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = Provider.of<EmailStore>(context, listen: false).themeMode;
    _slowMotionSpeedSetting =
        Provider.of<EmailStore>(context, listen: false).slowMotionSpeed;
  }

  @override
  Widget build(BuildContext context) {
    var radius = const Radius.circular(12);
    final modalBorder = BorderRadius.only(
      topRight: radius,
      topLeft: radius,
    );

    return StatefulBuilder(builder: (context, state) {
      void setTheme(ThemeMode? theme) {
        state(() {
          _themeMode = theme!;
        });
        Provider.of<EmailStore>(context, listen: false).themeMode = theme!;
      }

      void setSlowMotionSpeed(SlowMotionSpeedSetting? slowMotionSpeed) {
        state(() {
          _slowMotionSpeedSetting = slowMotionSpeed!;
        });
        Provider.of<EmailStore>(context, listen: false).slowMotionSpeed =
            slowMotionSpeed!;
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: modalBorder,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: const Text('Theme'),
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
                title: const Text('Slow Motion'),
                children: [
                  for (var animationSpeed in SlowMotionSpeedSetting.values)
                    RadioListTile(
                      title: Text('${animationSpeed.value.toInt()}x'),
                      value: animationSpeed,
                      groupValue: _slowMotionSpeedSetting,
                      onChanged: setSlowMotionSpeed,
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
