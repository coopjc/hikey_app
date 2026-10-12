import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../theme/hikey_theme.dart';

class MapSettings {
  const MapSettings._();

  // Constants for UI layout and map settings

  static const Color _puckColor = HikeyTheme.primaryGreen;
  static const String _poiLayer = 'poi-label';
  static const String _outdoorPoiClass = 'park_like';
  static const String styleUri = MapboxStyles.OUTDOORS;

  static const double edgeInset = 12;
  static const double controlSize = 44;
  static const double controlSpacing = 4;

  static const double _ornamentInset = 8;
  static const double _scaleBarHeight = 32;
  static const double _logoHeight = 24;

  static const double backButtonTop = _ornamentInset + _scaleBarHeight + 4;
  static const double controlsBottom = _ornamentInset + _logoHeight + 8;

  static Point _pointAt(geo.Position position) =>
      Point(coordinates: Position(position.longitude, position.latitude));

  static ViewportState idleViewportAt(geo.Position position) =>
      CameraViewportState(
        center: _pointAt(position),
        zoom: 15,
        bearing: 0,
        pitch: 0,
      );

  static CameraOptions idleCameraAt(geo.Position position) =>
      CameraOptions(center: _pointAt(position), zoom: 15, bearing: 0, pitch: 0);

  static Future<void> apply(MapboxMap map, {required double pixelRatio}) async {
    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: false,
        showAccuracyRing: true,
        accuracyRingColor: _puckColor.withValues(alpha: 0.15).toARGB32(),
        accuracyRingBorderColor: _puckColor.withValues(alpha: 0.3).toARGB32(),
        puckBearingEnabled: false,
        locationPuck: LocationPuck(
          locationPuck2D: LocationPuck2D(topImage: await _drawPuck(pixelRatio)),
        ),
      ),
    );

    await map.scaleBar.updateSettings(
      ScaleBarSettings(
        position: OrnamentPosition.TOP_LEFT,
        marginLeft: edgeInset,
        marginTop: _ornamentInset,
        isMetricUnits: false,
      ),
    );

    await map.logo.updateSettings(
      LogoSettings(
        position: OrnamentPosition.BOTTOM_LEFT,
        marginLeft: edgeInset,
        marginBottom: _ornamentInset,
      ),
    );

    await map.compass.updateSettings(CompassSettings(enabled: false));
  }

  static Future<void> showOutdoorsOnly(StyleManager style) async {
    if (!await style.styleLayerExists(_poiLayer)) return;

    final Object? filter = (await style.getStyleLayerProperty(
      _poiLayer,
      'filter',
    )).value;
    final List<Object> outdoorOnly = <Object>[
      '==',
      <Object>['get', 'class'],
      _outdoorPoiClass,
    ];

    await style.setStyleLayerProperty(
      _poiLayer,
      'filter',
      filter == null ? outdoorOnly : <Object>['all', filter, outdoorOnly],
    );
  }

  static Future<Uint8List> _drawPuck(double pixelRatio) async {
    const double size = 28;
    const double radius = 10;
    const Offset center = Offset(size / 2, size / 2);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..scale(pixelRatio)
      ..drawCircle(
        center.translate(0, 1),
        radius,
        Paint()
          ..color = Colors.black26
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..drawCircle(center, radius, Paint()..color = Colors.white)
      ..drawCircle(center, radius - 3, Paint()..color = _puckColor);

    final int pixels = (size * pixelRatio).round();
    final ui.Image image = await recorder.endRecording().toImage(
      pixels,
      pixels,
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();

    return bytes!.buffer.asUint8List();
  }
}
