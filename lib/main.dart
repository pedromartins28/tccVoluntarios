import 'package:voluntario/util/route_generator.dart';
import 'package:voluntario/util/state_widget.dart';
import 'package:voluntario/util/map_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:voluntario/ui/theme.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapState>(
      create: (_) => MapState(),
      child: MaterialApp(
        title: 'Coronapp2',
        //Theme was built in ui/theme.dart
        theme: buildTheme(),
        //Remove scroll glow
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child,
          );
        },
        //Remove debug banner
        debugShowCheckedModeBanner: false,
        //Define app routes
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

void main() {
  StateWidget stateWidget = StateWidget(
    child: MyApp(),
  );
  runApp(stateWidget);
}
