import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/hikey_theme.dart';

class MapCompass extends StatefulWidget {
  const MapCompass({
    super.key,
    required this.heading,
    required this.bearing,
    required this.size,
  });

  final double? heading;
  final double bearing;
  final double size;

  @override
  State<MapCompass> createState() => _MapCompassState();
}

class _MapCompassState extends State<MapCompass> {
  static const Duration _turnDuration = Duration(milliseconds: 300);
  static const Duration _fadeDuration = Duration(milliseconds: 200);
  static const Color _northColor = Color(0xFFC62828);

  late double _dialTurns = _dialTarget;
  late double _needleTurns = _needleTarget;

  double get _dialTarget => -widget.bearing / 360;
  double get _needleTarget => ((widget.heading ?? 0) - widget.bearing) / 360;

  @override
  void didUpdateWidget(MapCompass old) {
    super.didUpdateWidget(old);

    _dialTurns = _shortestTo(_dialTurns, _dialTarget);
    _needleTurns = _shortestTo(_needleTurns, _needleTarget);
  }

  static double _shortestTo(double current, double target) =>
      current + (target - current + 0.5) % 1 - 0.5;

  @override
  Widget build(BuildContext context) {
    final bool hasHeading = widget.heading != null;

    return Tooltip(
      message: hasHeading ? 'Direction' : 'Direction unavailable',
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedRotation(
              turns: _dialTurns,
              duration: _turnDuration,
              curve: Curves.easeOut,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const CustomPaint(painter: _CompassPainter()),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: widget.size * 0.06),
                      child: Text(
                        'N',
                        style: TextStyle(
                          color: _northColor,
                          fontSize: widget.size * 0.22,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: hasHeading ? 1 : 0.3,
              duration: _fadeDuration,
              child: AnimatedRotation(
                turns: _needleTurns,
                duration: _turnDuration,
                curve: Curves.easeOut,
                child: Icon(
                  Icons.navigation_rounded,
                  size: widget.size * 0.45,
                  color: HikeyTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double outer = size.shortestSide / 2 - 3;

    final Paint tick = Paint()
      ..color = Colors.grey.shade500
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < 8; i++) {
      final bool cardinal = i.isEven;
      final double angle = i * math.pi / 4;
      final Offset direction = Offset(math.sin(angle), -math.cos(angle));

      tick.strokeWidth = cardinal ? 1.5 : 1;
      canvas.drawLine(
        center + direction * (outer - (cardinal ? 4 : 2)),
        center + direction * outer,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_CompassPainter old) => false;
}
