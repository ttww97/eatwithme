// https://stackoverflow.com/questions/50196913/how-to-change-navigation-animation-using-flutter

import 'package:flutter/material.dart';

class RouteFromBottom extends PageRouteBuilder {
  final Widget widget;
  RouteFromBottom({this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        });
}
