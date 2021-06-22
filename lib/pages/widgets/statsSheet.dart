import 'package:flutter/material.dart';

import '../../utils/cameraSingletonUtils.dart';
import '../../tflite/stats.dart';

class StatsSheet extends StatelessWidget {
  const StatsSheet(this._stats);

  final Stats _stats;

  @override
  Widget build(BuildContext context) {
    return _stats != null
        ? Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StatsRow('Inference time:', '${_stats.inferenceTime} ms'),
                StatsRow(
                    'Total prediction time:', '${_stats.totalElapsedTime} ms'),
                StatsRow(
                    'Pre-processing time:', '${_stats.preProcessingTime} ms'),
                StatsRow('Frame',
                    '${CameraSingleton.inputImageSize?.width} X ${CameraSingleton.inputImageSize?.height}'),
              ],
            ),
          )
        : Container(
            child: Text('No results'),
          );
  }
}

class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            right,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
