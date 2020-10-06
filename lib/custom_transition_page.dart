import 'package:flutter/widgets.dart';

// TODO: Prefer to use TransitionBuilderPage once it lands in stable.
// https://github.com/material-components/material-components-flutter-motion-codelab/issues/32

class CustomTransitionPage extends Page {
  final Widget screen;
  final ValueKey transitionKey;

  const CustomTransitionPage(
      {@required this.screen, @required this.transitionKey})
      : assert(screen != null),
        assert(transitionKey != null),
        super(key: transitionKey);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) {
          return screen;
        });
  }
}
