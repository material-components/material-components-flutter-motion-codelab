import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'inbox.dart';
import 'model/email_store.dart';

class MailViewRouterDelegate extends RouterDelegate<void>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  MailViewRouterDelegate({required this.drawerController});

  final AnimationController drawerController;

  @override
  Widget build(BuildContext context) {
    bool handlePopPage(Route<dynamic> route, dynamic result) {
      return false;
    }

    return Selector<EmailStore, String>(
      selector: (context, emailStore) => emailStore.currentlySelectedInbox,
      builder: (context, currentlySelectedInbox, child) {
        return Navigator(
          key: navigatorKey,
          onPopPage: handlePopPage,
          pages: [
            FadeThroughTransitionPageWrapper(
              mailbox: InboxPage(destination: currentlySelectedInbox),
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
        Provider.of<EmailStore>(navigatorKey.currentContext!, listen: false);
    bool onCompose = emailStore.onCompose;

    bool onMailView = emailStore.onMailView;

    // Handles the back button press when we are on the HomePage. When the
    // drawer is visible reverse the drawer and do nothing else. If the drawer
    // is not visible then we check if we are on the main mailbox. If we are on
    // main mailbox then our app will close, if not then it will set the
    // mailbox to the main mailbox.
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

    // Handles the back button when on the [ComposePage].
    if (onCompose) {
      return SynchronousFuture<bool>(false);
    }

    // Handles the back button when the bottom drawer is visible on the
    // MailView. Dismisses the drawer on back button press.
    if (emailStore.bottomDrawerVisible && onMailView) {
      drawerController.reverse();
      return SynchronousFuture<bool>(true);
    }

    // Handles the back button press when on the MailView. If there is a route
    // to pop then pop it, and reset the currentlySelectedEmailId to -1
    // to notify listeners that we are no longer on the MailView.
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
      Provider.of<EmailStore>(navigatorKey.currentContext!, listen: false)
          .currentlySelectedEmailId = -1;
      return SynchronousFuture<bool>(true);
    }

    return SynchronousFuture<bool>(false);
  }

  @override
  Future<void> setNewRoutePath(void configuration) {
    // This function will never be called.
    throw UnimplementedError();
  }
}

class FadeThroughTransitionPageWrapper extends Page {
  const FadeThroughTransitionPageWrapper({
    required this.mailbox,
    required this.transitionKey,
  }) : super(key: transitionKey);

  final Widget mailbox;
  final ValueKey transitionKey;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return mailbox;
        });
  }
}
