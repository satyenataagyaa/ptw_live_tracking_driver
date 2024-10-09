import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ptw_live_tracking_driver/advanced/app.dart';
import 'package:ptw_live_tracking_driver/app.dart';
import 'package:ptw_live_tracking_driver/config/transistor_auth.dart';
import 'package:ptw_live_tracking_driver/location/app.dart';
import 'package:ptw_live_tracking_driver/models/ModelProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amplifyconfiguration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();

  SharedPreferences.getInstance().then((SharedPreferences prefs) {
    String? appName = prefs.getString("app");

    // Sanitize old-style registration system that only required username.
    // If we find a valid username but null orgname, reverse them.
    String? orgname = prefs.getString("orgname");
    String? username = prefs.getString("username");

    if (orgname == null && username != null) {
      prefs.setString("orgname", username);
      prefs.remove("username");
    }
    switch (appName) {
      case GeolocationApp.NAME:
        runApp(const GeolocationApp());
        break;
      case LocationApp.NAME:
        runApp(const LocationApp());
        break;
      default:
        // Default app.  Renders the application selector home page.
        runApp(const HomeApp());
    }
  });
  TransistorAuth.registerErrorHandler();
}

Future<void> _configureAmplify() async {
  try {
    // Create the API plugin
    //
    final api = AmplifyAPI(
      options: APIPluginOptions(modelProvider: ModelProvider.instance),
    );

    // Create the Auth plugin.
    // final auth = AmplifyAuthCognito();

    // Add the plugins
    // await Amplify.addPlugins([api, auth]);
    await Amplify.addPlugins([api]);
    await Amplify.configure(amplifyconfig);

    safePrint('Successfully configured');
  } on AmplifyAlreadyConfiguredException {
    safePrint(
        'Tried to reconfigure Amplify; this can occur when your app restarts on Android.');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}
