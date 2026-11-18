import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../api/api_exception.dart';
import '../models/hike.dart';
import '../models/hike_point.dart';
import '../models/paged.dart';
import '../services/hike_service.dart';
import '../utils/hike_format.dart';
import './location_controller.dart';

class HikeController extends ChangeNotifier {
  HikeController({
    required HikeService hikeService,
    required LocationController locationController,
  }) : _hike = hikeService,
       _location = locationController;

  static const int hikesPageSize = 10;

  final HikeService _hike;
  final LocationController _location;

  Hike? _activeHike;
  Hike? get activeHike => _activeHike;

  bool _isTransitioning = false;
  bool get isTransitioning => _isTransitioning;

  int _sentPointCount = 0;

  // Updates queued to be sent to the server, so they don't get sent out of order.
  Future<void> _updates = Future<void>.value();

  Future<Paged<Hike>> getRecentHikes() {
    return _hike.getHikes(size: 3, sortBy: 'createdAt', direction: 'desc');
  }

  Future<Paged<Hike>> getHikesPage(int page) {
    return _hike.getHikes(
      page: page,
      size: hikesPageSize,
      sortBy: 'createdAt',
      direction: 'desc',
    );
  }

  Future<Hike> getHike(int hikeId) => _hike.getHike(hikeId);

  Future<String?> startHike() {
    if (_activeHike != null) {
      return Future<String?>.value('A hike is already in progress.');
    }

    return _transitionHike(() async {
      final String? locationError = await _ensureTracking();

      if (locationError != null) return locationError;

      _activeHike = await _hike.startHike(name: formatName(DateTime.now()));
      _sentPointCount = 0;

      await _location.startRecording();

      return null;
    });
  }

  Future<String?> pauseHike() {
    final Hike? hike = _activeHike;

    if (hike == null) {
      return Future<String?>.value('There is no hike in progress.');
    }

    return _transitionHike(() async {
      await _pushUnsentPoints(hike.id);

      _activeHike = await _hike.pauseHike(hike.id);
      _location.pauseRecording();

      return null;
    });
  }

  Future<String?> resumeHike() {
    final Hike? hike = _activeHike;

    if (hike == null) {
      return Future<String?>.value('There is no hike in progress.');
    }

    return _transitionHike(() async {
      final String? locationError = await _ensureTracking();

      if (locationError != null) return locationError;

      _activeHike = await _hike.resumeHike(hike.id);
      await _location.resumeRecording();

      return null;
    });
  }

  Future<String?> completeHike() {
    final Hike? hike = _activeHike;

    if (hike == null) {
      return Future<String?>.value('There is no hike in progress.');
    }

    return _transitionHike(() async {
      await _pushUnsentPoints(hike.id);
      await _hike.completeHike(hike.id);

      _clearActiveHike();

      return null;
    });
  }

  Future<String?> _transitionHike(Future<String?> Function() change) async {
    if (_isTransitioning) return null;

    _isTransitioning = true;
    notifyListeners();

    try {
      return await change();
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _isTransitioning = false;
      notifyListeners();
    }
  }

  static List<HikePoint> buildPointList(List<List<Position>> stretches) {
    double elevation =
        stretches
            .expand((List<Position> stretch) => stretch)
            .where((Position p) => p.hasAltitude)
            .firstOrNull
            ?.altitude ??
        0;

    final List<HikePoint> points = <HikePoint>[];

    for (int i = 0; i < stretches.length; i++) {
      for (final Position p in stretches[i]) {
        if (p.hasAltitude) elevation = p.altitude;

        points.add(
          HikePoint(
            stretchIndex: i,
            latitude: p.latitude,
            longitude: p.longitude,
            elevation: elevation,
            savedAt: p.timestamp,
          ),
        );
      }
    }

    return points;
  }

  Future<void> _pushUnsentPoints(int hikeId) async {
    final List<HikePoint> points = buildPointList(_location.routeStretches);

    if (points.length <= _sentPointCount) return;

    final List<HikePoint> unsent = points.sublist(_sentPointCount);
    final int savedCount = await _hike.pushHikePoints(hikeId, unsent);

    _sentPointCount += savedCount.clamp(0, unsent.length);

    if (savedCount != unsent.length) {
      throw ApiException(
        'The server stored $savedCount of ${unsent.length} tracked points.',
      );
    }
  }

  void _clearActiveHike() {
    _activeHike = null;
    _sentPointCount = 0;
    _location.finishRecording();
  }

  Future<String?> _queueUpdate(int hikeId, {String? name, String? notes}) {
    final Future<String?> result = _updates.then((_) async {
      try {
        await _hike.updateHike(hikeId, name: name, notes: notes);

        return null;
      } on ApiException catch (e) {
        return e.message;
      }
    });

    _updates = result.then<void>((_) {}, onError: (Object _) {});

    return result;
  }

  Future<String?> updateName(Hike hike, String name) {
    return _queueUpdate(hike.id, name: name);
  }

  Future<String?> updateNotes(Hike hike, String notes) {
    return _queueUpdate(hike.id, notes: notes);
  }

  Future<String?> deleteHike(Hike hike) async {
    try {
      await _hike.deleteHike(hike.id);
    } on ApiException catch (e) {
      return e.message;
    }

    if (_activeHike?.id == hike.id) {
      _clearActiveHike();
      notifyListeners();
    }

    return null;
  }

  Future<String?> _ensureTracking() async {
    await _location.startTracking();

    if (_location.isTracking) return null;

    return _location.errorMessage;
  }
}
