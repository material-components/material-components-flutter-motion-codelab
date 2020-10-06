import 'package:flutter/widgets.dart';

// Prefer to use TransitionBuilderPage once it lands in stable.
class CustomTransitionPageBuilder extends Page {
  final Widget screen;

  const CustomTransitionPageBuilder({this.screen});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) {
          return screen;
        });
  }
}
