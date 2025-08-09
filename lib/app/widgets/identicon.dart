import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';

class IdenticonPainter extends CustomPainter {
  IdenticonPainter(
    this.input, {
    this.grid = 5,
    this.padding = 16.0,
    this.saturation = 0.65,
    this.lightness = 0.55,
  }) : assert(grid >= 3);

  final String input;
  final int grid;
  final double padding;
  final double saturation;
  final double lightness;

  @override
  void paint(Canvas canvas, Size size) {
    final bytes = _sha256(input);
    final rng = _Rng.fromBytes(bytes);

    final hue = (bytes[0] / 255.0) * 360.0;
    final fg = HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();

    final d = math.min(size.width, size.height);
    final origin = Offset((size.width - d) / 2, (size.height - d) / 2);

    final cell = (d - padding * 2) / grid;
    final start = Offset(origin.dx + padding, origin.dy + padding);

    final half = (grid / 2).ceil();
    final px = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false
      ..color = fg;

    for (int y = 0; y < grid; y++) {
      final row = <bool>[];
      for (int x = 0; x < half; x++) {
        final p = rng.next();
        final fill = p > 0.5 ? true : (p > 0.45);
        row.add(fill);
      }
      final right = List<bool>.from(row.take(grid - half).toList().reversed);
      final full = <bool>[...row, ...right];

      for (int x = 0; x < grid; x++) {
        if (!full[x]) {
          continue;
        }
        final rx = start.dx + x * cell;
        final ry = start.dy + y * cell;
        canvas.drawRect(Rect.fromLTWH(rx, ry, cell, cell), px);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IdenticonPainter old) {
    return input != old.input ||
        grid != old.grid ||
        padding != old.padding ||
        saturation != old.saturation ||
        lightness != old.lightness;
  }
}

List<int> _sha256(String input) =>
    crypto.sha256.convert(utf8.encode(input)).bytes;

class _Rng {
  _Rng(this._state);

  factory _Rng.fromBytes(List<int> bytes) {
    int seed = 0;
    for (int i = 0; i < 4; i++) {
      seed = (seed << 8) | (bytes[i % bytes.length] & 0xff);
    }
    if (seed == 0) seed = 0x9E3779B9;
    return _Rng(seed);
  }

  int _state;

  double next() {
    int x = _state;
    x ^= (x << 13) & 0xffffffff;
    x ^= (x >> 17);
    x ^= (x << 5) & 0xffffffff;
    _state = x & 0xffffffff;
    return (_state.toUnsigned(32) / 4294967296.0); // [0,1)
  }

  int nextInt(int max) => (next() * max).floor();
}

class Identicon extends StatelessWidget {
  const Identicon(
    this.input, {
    super.key,
    this.grid = 5,
    this.padding = 4.0,
  });

  final String input;
  final int grid;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IdenticonPainter(
        input,
        grid: grid,
        padding: padding,
      ),
    );
  }
}
