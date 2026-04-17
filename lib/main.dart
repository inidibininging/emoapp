import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/services/service_locator.dart';
import 'package:emoapp/services/pin_authentication_service.dart';
import 'package:emoapp/widgets/dashboard.dart';
import 'package:emoapp/widgets/auth/pin_login_screen.dart';
import 'package:emoapp/widgets/auth/pin_setup_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocatorRegistrar().register();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // const defaultTextStyle = TextStyle(color: primaryColor);
    final themeData = ThemeData(
      primarySwatch: getMaterialColor(primaryColor),
      secondaryHeaderColor: secondaryColor,
      primaryColorDark: primaryDarkenedColor,
      brightness: secondaryColor.computeLuminance() > 0.5
          ? Brightness.light
          : Brightness.dark,
      // backgroundColor: Colors.black,
      scaffoldBackgroundColor: gradientColor,
      // textTheme: TextTheme(),
      // IconButtonTheme: IconButtonThemeData(
      //   style: ButtonStyle(
      //     backgroundColor: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return secondaryColor;
      //       }
      //       return secondaryColor;
      //     }),
      //     textStyle: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return defaultTextStyle;
      //       }
      //       return defaultTextStyle;
      //     }),
      //     overlayColor: MaterialStateProperty.resolveWith((states) {
      //       // If the button is pressed, return green, otherwise blue
      //       if (states.contains(MaterialState.pressed)) {
      //         return secondaryVariant1Color;
      //       }
      //       return secondaryColor;
      //     }),
      //   ),
      // ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        splashColor: secondaryColor,
        hoverColor: secondaryColor,
        backgroundColor: secondaryColor,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: secondaryColor),
      fontFamily: 'Swansea',
      fontFamilyFallback: const ['Swansea'],
    );

    return MaterialApp(
      title: 'EMO APP',
      theme: themeData,
      home: const MyHomePage(title: 'EMO APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PinAuthenticationService _pinService;
  bool _isAuthenticated = false;
  bool _isPinSet = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _pinService = GetIt.instance.get<PinAuthenticationService>();

    // Skip PIN authentication on web platform
    if (kIsWeb) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    final isPinSet = await _pinService.isPinSet();
    setState(() {
      _isPinSet = isPinSet;
      _isLoading = false;
      // If no PIN is set, we'll show the setup screen
      // If PIN is set, we'll show the login screen
      if (!isPinSet) {
        _isAuthenticated = false;
      }
    });
  }

  void _onSetupComplete() {
    setState(() {
      _isPinSet = true;
      _isAuthenticated = true;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Skip authentication on web platform
    if (kIsWeb) {
      return const Dashboard();
    }

    // Show PIN setup if no PIN is set
    if (!_isPinSet) {
      return PinSetupScreen(onSetupComplete: _onSetupComplete);
    }

    // Show PIN login if not authenticated
    if (!_isAuthenticated) {
      return PinLoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    // Show dashboard if authenticated
    return const Dashboard();
  }
}
