import 'package:flutter/widgets.dart';

// Prefer to use TransitionBuilderPage once it lands in stable.
class CustomTransitionPageBuilder extends Page {
  final Widget screen;
  final ValueKey transitionKey;

  const CustomTransitionPageBuilder(
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
