import 'package:flutter/material.dart';
import 'package:object_detection_app/utils/cameraSingletonUtils.dart';

import '../../tflite/recognition.dart';

class BoundingBoxes extends StatelessWidget {
  const BoundingBoxes(this.results);

  final List<Recognition> results;

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return Container(child: Text('No results'));
    }
    return Stack(
      children: results.map((result) {
        final Color color = Colors.primaries[
            (result.label.length + result.label.codeUnitAt(0) + result.id) %
                Colors.primaries.length];

        final Rect rect = result.renderLocation(
            CameraSingleton.ratio, CameraSingleton.screenSize);

        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: Container(
            width: rect.width,
            height: rect.height,
            decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(2))),
            child: Align(
              alignment: Alignment.topLeft,
              child: FittedBox(
                child: Container(
                  color: color,
                  child: Text(
                      '${result.label} ${result.score.toStringAsFixed(2)}'),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
