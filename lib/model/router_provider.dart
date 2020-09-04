import 'package:flutter/material.dart';
import 'package:reply/router.dart';

class RouterProvider with ChangeNotifier {
  ReplyRoutePath _routePath;
  ReplyRoutePath get routePath => _routePath;

  set routePath(ReplyRoutePath route) {
    if (route != _routePath) {
      _routePath = route;
      notifyListeners();
    }
  }
}
