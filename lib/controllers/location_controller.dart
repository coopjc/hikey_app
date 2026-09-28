import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

enum LocationTrackingStatus {
  idle,
  tracking,
  permissionDenied,
  serviceDisabled,
  error,
}

class RecordedHike {
  const RecordedHike({
    required this.route,
    required this.distanceMiles,
    required this.duration,
  });

  final List<Position> route;
  final double distanceMiles;

  final Duration duration;
}

class LocationController extends ChangeNotifier {
  LocationController({LocationService? locationService})
    : _location = locationService ?? const LocationService();

  final LocationService _location;

  LocationTrackingStatus _status = LocationTrackingStatus.idle;
  LocationTrackingStatus get status => _status;
  bool get isTracking => _status == LocationTrackingStatus.tracking;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  StreamSubscription<Position>? _positionSubscription;

  bool _isRecording = false;
  bool _isPaused = false;
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isHikeInProgress => _isRecording || _isPaused;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<List<Position>> _stretches = <List<Position>>[];

  List<List<Position>> get routeStretches => <List<Position>>[
    for (final List<Position> stretch in _stretches)
      List<Position>.unmodifiable(stretch),
  ];

  List<Position> get route => List<Position>.unmodifiable(
    _stretches.expand<Position>((List<Position> stretch) => stretch),
  );

  double _distanceMeters = 0;
  Duration _elapsedBeforeStretch = Duration.zero;
  DateTime? _stretchStartedAt;

  double get distanceMiles => _distanceMeters / 1609.344;

  Duration get elapsed {
    final DateTime? startedAt = _stretchStartedAt;
    if (startedAt == null) return _elapsedBeforeStretch;
    return _elapsedBeforeStretch + DateTime.now().difference(startedAt);
  }

  Future<void> startTracking() async {
    if (isTracking) return;

    _errorMessage = null;

    if (!await _location.isServiceEnabled()) {
      _errorMessage = 'Turn on location services to track your hike.';
      _setStatus(LocationTrackingStatus.serviceDisabled);
      return;
    }

    final bool granted = await _location.ensureBackgroundPermission();

    if (!granted) {
      _errorMessage = 'Hikey needs location access to track your hike.';
      _setStatus(LocationTrackingStatus.permissionDenied);
      return;
    }

    await _positionSubscription?.cancel();

    _positionSubscription = _location.trackLocation().listen(
      _onPosition,
      onError: _onError,
      cancelOnError: false,
    );

    _setStatus(LocationTrackingStatus.tracking);
  }

  Future<void> startRecording() async {
    if (isHikeInProgress || !await _ensureTracking()) return;
    _beginStretch();
  }

  void pauseRecording() {
    if (!_isRecording) return;

    _endStretch();
    _isPaused = true;

    notifyListeners();
  }

  Future<void> resumeRecording() async {
    if (!_isPaused || !await _ensureTracking()) return;

    _beginStretch();
  }

  RecordedHike finishRecording() {
    final RecordedHike recordedHike = RecordedHike(
      route: route,
      distanceMiles: distanceMiles,
      duration: elapsed,
    );

    if (!isHikeInProgress) return recordedHike;

    _isRecording = false;
    _isPaused = false;

    _stretches.clear();
    _distanceMeters = 0;
    _elapsedBeforeStretch = Duration.zero;
    _stretchStartedAt = null;

    notifyListeners();

    return recordedHike;
  }

  Future<bool> _ensureTracking() async {
    if (!isTracking) await startTracking();
    return isTracking;
  }

  void _beginStretch() {
    _stretches.add(<Position>[]);
    _stretchStartedAt = DateTime.now();

    _isRecording = true;
    _isPaused = false;

    final Position? current = _currentPosition;
    if (current != null) _recordPoint(current);

    notifyListeners();
  }

  void _recordPoint(Position currentPosition) {
    final Position? lastPosition = _stretches.lastOrNull?.lastOrNull;

    if (lastPosition != null) {
      _distanceMeters += Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );
    }

    _stretches.last.add(currentPosition);
  }

  void _endStretch() {
    _elapsedBeforeStretch = elapsed;
    _stretchStartedAt = null;
    _isRecording = false;
  }

  void _onPosition(Position position) {
    if (_isRecording) _recordPoint(position);
    _currentPosition = position;
    notifyListeners();
  }

  void _onError(Object error) {
    _errorMessage = 'Failed to track location. Please try again later.';
    _setStatus(LocationTrackingStatus.error);
  }

  void _setStatus(LocationTrackingStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
