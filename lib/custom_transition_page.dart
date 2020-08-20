import 'package:flutter/widgets.dart';

class CustomTransitionPage extends Page {
  final Widget screen;
  final ValueKey transitionKey;

  const CustomTransitionPage(
      {required this.screen, required this.transitionKey})
      : super(key: transitionKey);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) {
          return screen;
        });
  }
}
