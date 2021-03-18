import 'package:voluntario/ui/pages/form.dart';
import 'package:voluntario/ui/pages/infos.dart';
import 'package:voluntario/ui/pages/main/about.dart';
import 'package:voluntario/ui/pages/change_pass.dart';
import 'package:voluntario/ui/pages/main/finished_requests.dart';
import 'package:voluntario/ui/pages/show_photo.dart';
import 'package:voluntario/ui/pages/main/user_info.dart';
import 'package:voluntario/ui/pages/sign_in.dart';
import 'package:voluntario/util/fade_route.dart';
import 'package:voluntario/ui/pages/main/home.dart';
import 'package:voluntario/ui/pages/chat.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: RouteSettings(
            name: '/',
          ),
          builder: (_) => HomePage(),
        );
      case '/signin':
        return FadeRoute(
          settings: RouteSettings(
            name: '/signin',
          ),
          page: SignInPage(),
        );
      case '/finished_requests':
        return FadeRoute(
          settings: RouteSettings(
            name: '/finished_requests',
          ),
          page: RequestHistoryPage(),
        );
      case '/chat':
        if (args is Map) {
          return FadeRoute(
            settings: RouteSettings(name: '/chat', arguments: args['donorId']),
            page: ChatPage(request: args),
          );
        }
        return _errorRoute();
      case '/form':
        if (args is Map) {
          return FadeRoute(
            settings: RouteSettings(name: '/form', arguments: args['donorId']),
            page: FormPage(request: args),
          );
        }
        return _errorRoute();
      case '/infos':
        if (args is Map) {
          return FadeRoute(
            settings: RouteSettings(name: '/infos', arguments: args['donorId']),
            page: InfosPage(request: args),
          );
        }
        return _errorRoute();
      case '/user_information':
        return FadeRoute(
          page: UserInfoPage(),
          settings: RouteSettings(
            name: '/user_information',
          ),
        );
      case '/show_photo':
        if (args is Map)
          return FadeRoute(
            settings: RouteSettings(
              name: '/show_photo',
            ),
            page: ShowPhotoPage(args),
          );
        return _errorRoute();
      case '/about':
        return FadeRoute(
          settings: RouteSettings(
            name: '/about',
          ),
          page: AboutPage(),
        );
      case '/change_pass':
        return FadeRoute(
          settings: RouteSettings(
            name: '/change_pass',
          ),
          page: ChangePasswordPage(),
        );
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return FadeRoute(
      settings: RouteSettings(
        name: '/error',
      ),
      page: Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      ),
    );
  }
}
