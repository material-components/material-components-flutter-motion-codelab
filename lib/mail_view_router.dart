import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'inbox.dart';
import 'model/email_store.dart';

class MailViewRouterDelegate extends RouterDelegate<void>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  MailViewRouterDelegate({this.drawerController});

  final AnimationController drawerController;

  @override
  Widget build(BuildContext context) {
    bool _handlePopPage(Route<dynamic> route, dynamic result) {
      return false;
    }

    return Selector<EmailStore, String>(
      selector: (context, emailStore) => emailStore.currentlySelectedInbox,
      builder: (context, currentlySelectedInbox, child) {
        return Navigator(
          key: navigatorKey,
          onPopPage: _handlePopPage,
          pages: [
            FadeThroughTransitionPageWrapper(
              child: InboxPage(destination: currentlySelectedInbox),
              transitionKey: ValueKey(currentlySelectedInbox),
            ),
          ],
        );
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => mobileMailNavKey;

  @override
  Future<bool> popRoute() {
    var emailStore =
        Provider.of<EmailStore>(navigatorKey.currentContext, listen: false);
    bool onCompose = emailStore.onCompose;

    bool onMailView = emailStore.onMailView;

    if (!(onMailView || onCompose)) {
      if (emailStore.bottomDrawerVisible) {
        drawerController.reverse();
        return SynchronousFuture<bool>(true);
      }

      if (emailStore.currentlySelectedInbox != 'Inbox') {
        emailStore.currentlySelectedInbox = 'Inbox';
        return SynchronousFuture<bool>(true);
      }
      return SynchronousFuture<bool>(false);
    }

    if (onCompose) {
      return SynchronousFuture<bool>(false);
    }

    if (navigatorKey.currentState.canPop()) {
      navigatorKey.currentState.pop();
      Provider.of<EmailStore>(navigatorKey.currentContext, listen: false)
          .currentlySelectedEmailId = -1;
      return SynchronousFuture<bool>(true);
    }

    return SynchronousFuture<bool>(false);
  }

  @override
  Future<void> setNewRoutePath(void configuration) {
    // should never be called
    throw UnimplementedError();
  }
}

class FadeThroughTransitionPageWrapper extends TransitionBuilderPage {
  FadeThroughTransitionPageWrapper(
      {@required this.child, @required this.transitionKey})
      : assert(child != null),
        assert(transitionKey != null),
        super(
          key: transitionKey,
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeThroughTransition(
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );

  final Widget child;
  final ValueKey transitionKey;
}
