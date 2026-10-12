import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/mapbox_config.dart';
import '../../controllers/location_controller.dart';
import '../../widgets/error_notice.dart';
import 'map_settings.dart';
import 'widgets/map_compass.dart';
import 'widgets/recenter_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final LocationController _location;
  MapboxMap? _map;

  ViewportState _viewport = const IdleViewportState();

  bool _isCentered = true;
  bool _needsFix = true;

  // Heading represents the direction of the device.
  double? _heading;
  // Bearing represents the direction of the map.
  double _bearing = 0;

  @override
  void initState() {
    super.initState();

    _location = context.read<LocationController>()
      ..addListener(_onLocationChanged);

    final geo.Position? position = _location.currentPosition;

    if (position != null) {
      _viewport = MapSettings.idleViewportAt(position);
      _needsFix = false;
    }
  }

  @override
  void dispose() {
    _location.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    final geo.Position? position = _location.currentPosition;
    if (position == null) return;

    _needsFix = false;

    final bool isHeadingReliable =
        position.heading >= 0 && position.speed >= 0.5;
    final double heading = isHeadingReliable ? position.heading : 0;

    if (heading == _heading && !_needsFix) return;

    setState(() {
      _heading = heading;
      if (_needsFix) _viewport = MapSettings.idleViewportAt(position);
    });
  }

  void _onMapCreated(MapboxMap map) {
    _map = map;
    MapSettings.apply(map, pixelRatio: MediaQuery.of(context).devicePixelRatio);
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    final MapboxMap? map = _map;
    if (map != null) MapSettings.showOutdoorsOnly(map.style);
  }

  void _onCameraChanged(CameraChangedEventData data) {
    final double bearing = data.cameraState.bearing;
    if (bearing != _bearing) setState(() => _bearing = bearing);
  }

  void _onScroll(MapContentGestureContext _) {
    _needsFix = false;
    if (_isCentered) setState(() => _isCentered = false);
  }

  void _recenter() {
    final MapboxMap? map = _map;
    final geo.Position? position = _location.currentPosition;

    if (position == null || map == null) return;

    setState(() => _isCentered = true);

    map.easeTo(
      MapSettings.idleCameraAt(position),
      MapAnimationOptions(duration: Duration(milliseconds: 600).inMilliseconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!MapboxConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ErrorNotice(
            icon: Icons.map_rounded,
            message: 'The map is unavailable right now.',
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          MapWidget(
            styleUri: MapSettings.styleUri,
            viewport: _viewport,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
            onScrollListener: _onScroll,
            onCameraChangeListener: _onCameraChanged,
          ),
          SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: MapSettings.edgeInset,
                  top: MapSettings.backButtonTop,
                  child: IconButton.filledTonal(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  left: MapSettings.edgeInset,
                  bottom: MapSettings.controlsBottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RecenterButton(
                        visible: !_isCentered,
                        onPressed: _recenter,
                        size: MapSettings.controlSize,
                      ),
                      const SizedBox(height: MapSettings.controlSpacing),
                      MapCompass(
                        heading: _heading,
                        bearing: _bearing,
                        size: MapSettings.controlSize,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
