import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reply/home.dart';
import 'package:reply/search_page.dart';

import 'model/router_provider.dart';

const String _homePageLocation = '/reply/home';
const String _searchPageLocation = '/reply/search';

class ReplyRouterDelegate extends RouterDelegate<ReplyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ReplyRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  RouterProvider replyState;

  ReplyRouterDelegate({@required this.replyState})
      : assert(replyState != null),
        navigatorKey = GlobalObjectKey<NavigatorState>(replyState) {
    replyState.addListener(() {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    replyState.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  ReplyRoutePath get currentConfiguration =>
      replyState.routePath; //appState.routePath

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouterProvider>.value(value: replyState),
      ],
      child: Selector<RouterProvider, ReplyRoutePath>(
        selector: (context, routerProvider) => routerProvider.routePath,
        builder: (context, routePath, child) {
          return Navigator(
            key: navigatorKey,
            onPopPage: _handlePopPage,
            pages: [
              SharedAxisTransitionPageWrapper(
                transitionKey: ValueKey('home'),
                child: const HomePage(),
              ),
              if (routePath is ReplySearchPath)
                SharedAxisTransitionPageWrapper(
                  transitionKey: ValueKey('search'),
                  child: const SearchPage(),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    // _handlePopPage should not be called on the home page because the
    // PopNavigatorRouterDelegateMixin will bubble up the pop to the
    // SystemNavigator if there is only one route in the navigator.
    assert(route.willHandlePopInternally ||
        replyState.routePath is ReplySearchPath);

    final bool success = route.didPop(result);
    if (success) replyState.routePath = const ReplyHomePath();
    return success;
  }

  @override
  Future<void> setNewRoutePath(ReplyRoutePath configuration) {
    assert(configuration != null);
    replyState.routePath = configuration;
    return SynchronousFuture<void>(null);
  }
}

@immutable
abstract class ReplyRoutePath {
  const ReplyRoutePath();
}

class ReplyHomePath extends ReplyRoutePath {
  const ReplyHomePath();
}

class ReplySearchPath extends ReplyRoutePath {
  const ReplySearchPath();
}

class SharedAxisTransitionPageWrapper extends TransitionBuilderPage {
  SharedAxisTransitionPageWrapper(
      {@required this.child, @required this.transitionKey})
      : assert(child != null),
        assert(transitionKey != null),
        super(
          key: transitionKey,
          pageBuilder: (context, animation, secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: Theme.of(context).cardColor,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );

  final Widget child;
  final ValueKey transitionKey;
}

class ReplyRouteInformationParser
    extends RouteInformationParser<ReplyRoutePath> {
  @override
  Future<ReplyRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final url = Uri.parse(routeInformation.location);

    if (url.path == _searchPageLocation) {
      return SynchronousFuture<ReplySearchPath>(const ReplySearchPath());
    }

    return SynchronousFuture<ReplyHomePath>(const ReplyHomePath());
  }

  @override
  RouteInformation restoreRouteInformation(ReplyRoutePath configuration) {
    if (configuration is ReplyHomePath) {
      return RouteInformation(location: _homePageLocation);
    }
    if (configuration is ReplySearchPath) {
      return RouteInformation(location: _searchPageLocation);
    }
    return null;
  }
}
