// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:async';

import 'home_view.dart';
import 'main_menu_button.dart';

class GeolocationApp extends StatefulWidget {
  static const String NAME = 'advanced';

  const GeolocationApp({super.key});

  @override
  State<GeolocationApp> createState() => _GeolocationAppState();
}

class _GeolocationAppState extends State<GeolocationApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(secondary: Colors.black),
          brightness: Brightness.light,
          hintColor: Colors.black12,
          primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
                bodyColor: Colors.black,
              )),
      home: const Scaffold(
        body: HomeView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: MainMenuButton(),
      ),
    );
  }
}
