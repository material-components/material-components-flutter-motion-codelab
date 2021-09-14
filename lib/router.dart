import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reply/custom_transition_page.dart';
import 'package:reply/home.dart';
import 'package:reply/search_page.dart';

import 'model/router_provider.dart';

const String _homePageLocation = '/reply/home';
const String _searchPageLocation = '/reply/search';

class ReplyRouterDelegate extends RouterDelegate<ReplyRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ReplyRoutePath> {
  ReplyRouterDelegate({required this.replyState})
      : navigatorKey = GlobalObjectKey<NavigatorState>(replyState) {
    replyState.addListener(() {
      notifyListeners();
    });
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  RouterProvider replyState;

  @override
  void dispose() {
    replyState.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  ReplyRoutePath get currentConfiguration => replyState.routePath;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouterProvider>.value(value: replyState),
      ],
      child: Selector<RouterProvider, ReplyRoutePath?>(
        selector: (context, routerProvider) => routerProvider.routePath,
        builder: (context, routePath, child) {
          return Navigator(
            key: navigatorKey,
            onPopPage: _handlePopPage,
            pages: [
              // TODO: Add Shared Z-Axis transition from search icon to search view page (Motion)
              const CustomTransitionPage(
                transitionKey: ValueKey('Home'),
                screen: HomePage(),
              ),
              if (routePath is ReplySearchPath)
                const CustomTransitionPage(
                  transitionKey: ValueKey('Search'),
                  screen: SearchPage(),
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

    final bool didPop = route.didPop(result);
    if (didPop) replyState.routePath = const ReplyHomePath();
    return didPop;
  }

  @override
  Future<void> setNewRoutePath(ReplyRoutePath configuration) {
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

// TODO: Add Shared Z-Axis transition from search icon to search view page (Motion)

class ReplyRouteInformationParser
    extends RouteInformationParser<ReplyRoutePath> {
  @override
  Future<ReplyRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final url = Uri.parse(routeInformation.location!);

    if (url.path == _searchPageLocation) {
      return SynchronousFuture<ReplySearchPath>(const ReplySearchPath());
    }

    return SynchronousFuture<ReplyHomePath>(const ReplyHomePath());
  }

  @override
  RouteInformation? restoreRouteInformation(ReplyRoutePath configuration) {
    if (configuration is ReplyHomePath) {
      return const RouteInformation(location: _homePageLocation);
    }
    if (configuration is ReplySearchPath) {
      return const RouteInformation(location: _searchPageLocation);
    }
    return null;
  }
}
