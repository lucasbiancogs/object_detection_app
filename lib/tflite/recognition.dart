import 'dart:math';

import 'package:flutter/material.dart';

class Recognition {
  const Recognition({
    @required this.id,
    @required this.label,
    @required this.score,
    this.location,
  });

  /// Index of the result
  final int id;

  /// Label of the result
  final String label;

  /// Confidence [0.0, 1.0]
  final double score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect location;

  /// Returns the bounding box rectangle corresponding to the
  /// displayed image on screen
  ///
  /// This is the actual location where the rectangle is rendered on the screen
  Rect renderLocation(double ratio, Size size) {
    final transLeft = max(0.1, location.left * ratio);
    final transTop = max(0.1, location.top * ratio);
    final transWidth = min(location.width * ratio, size.width);
    final transHeight = min(location.height * ratio, size.height);

    final transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);

    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}
