import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'config/mapbox_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (MapboxConfig.isConfigured) {
    MapboxOptions.setAccessToken(MapboxConfig.token);
  }

  runApp(const HikeyApp());
}
