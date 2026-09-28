import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../api/api_exception.dart';
import '../models/hike.dart';
import '../models/hike_point.dart';
import '../services/hike_service.dart';
import './location_controller.dart';

class HikeController extends ChangeNotifier {
  HikeController({required HikeService hikeService}) : _hike = hikeService;

  final HikeService _hike;

  List<Hike> _hikes = <Hike>[];
  List<Hike> get hikes => _hikes;

  bool _isLoading = false;
  String? _errorMessage;
  Hike? _activeHike;

  String _activeHikeName = '';
  String get activeHikeName => _activeHikeName;
  String? _activeHikeNotes;
  String? get activeHikeNotes => _activeHikeNotes;

  // Updates queued to be sent to the server, so they don't get sent out of order.
  Future<void> _updates = Future<void>.value();

  double get totalDistanceMiles =>
      _hikes.fold<double>(0, (double sum, Hike h) => sum + h.distanceMiles);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHikes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hikes = await _hike.getHikes();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> startHike() async {
    try {
      final Hike hike = await _hike.createHike(name: buildName(DateTime.now()));

      _activeHike = hike;
      _activeHikeName = hike.name;
      _activeHikeNotes = hike.notes;
    } on ApiException catch (e) {
      return e.message;
    }

    loadHikes();
    return null;
  }

  Future<String?> updateActiveHike({
    required String name,
    String? notes,
    required HikeStatus status,
  }) {
    final Hike? hike = _activeHike;

    if (hike == null) {
      return Future<String?>.value('There is no hike in progress.');
    }

    _activeHikeName = name;
    _activeHikeNotes = notes;

    return _queueUpdate(hike.id, name: name, notes: notes, status: status);
  }

  Future<String?> finishHike(
    RecordedHike recording, {
    required String name,
    String? notes,
  }) async {
    final Hike? hike = _activeHike;

    if (hike == null) return 'There is no hike in progress to save.';
    _activeHike = null;

    String? pointsError;

    try {
      List<HikePoint> hikePoints = buildPointList(recording.route);
      await _hike.pushHikePoints(hike.id, hikePoints);
    } on ApiException catch (e) {
      pointsError = e.message;
    }

    final String? updateError = await _queueUpdate(
      hike.id,
      name: name,
      notes: notes,
      status: HikeStatus.completed,
      distanceMiles: recording.distanceMiles,
      duration: recording.duration,
    );

    loadHikes();

    return pointsError ?? updateError;
  }

  Future<String?> _queueUpdate(
    int hikeId, {
    String? name,
    String? notes,
    HikeStatus? status,
    double? distanceMiles,
    Duration? duration,
  }) {
    final Future<String?> result = _updates.then((_) async {
      try {
        await _hike.updateHike(
          hikeId,
          name: name,
          notes: notes,
          status: status,
          distanceMiles: distanceMiles,
          duration: duration,
        );

        return null;
      } on ApiException catch (e) {
        return e.message;
      }
    });

    _updates = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<String?> deleteHike(Hike hike) async {
    try {
      await _hike.deleteHike(hike.id);
    } on ApiException catch (e) {
      return e.message;
    }

    _hikes = _hikes.where((Hike h) => h.id != hike.id).toList();

    if (_activeHike?.id == hike.id) _activeHike = null;

    notifyListeners();
    return null;
  }

  Future<String?> updateNotes(Hike hike, String notes) async {
    if (_activeHike?.id == hike.id) {
      _activeHikeNotes = notes.isEmpty ? null : notes;
    }

    final String? error = await _queueUpdate(hike.id, notes: notes);

    if (error == null) loadHikes();

    return error;
  }

  static List<HikePoint> buildPointList(List<Position> route) {
    double elevation =
        route.where((Position p) => p.hasAltitude).firstOrNull?.altitude ?? 0;

    final List<HikePoint> points = <HikePoint>[];

    for (final Position p in route) {
      if (p.hasAltitude) elevation = p.altitude;

      points.add(
        HikePoint(
          latitude: p.latitude,
          longitude: p.longitude,
          elevation: elevation,
          savedAt: p.timestamp,
        ),
      );
    }

    return points;
  }

  static String buildName(DateTime startedAt) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final int hour = startedAt.hour;

    final String partOfDay = switch (hour) {
      >= 5 && < 12 => 'Morning',
      >= 12 && < 17 => 'Afternoon',
      >= 17 && < 21 => 'Evening',
      _ => 'Night',
    };

    return '$partOfDay hike · ${months[startedAt.month - 1]} ${startedAt.day}';
  }
}
