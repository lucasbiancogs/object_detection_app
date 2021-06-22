import 'package:flutter/foundation.dart';

/// Bundles different elapsed times
class Stats {
  Stats({
    @required this.inferenceTime,
    @required this.preProcessingTime,
    @required this.totalPredictTime,
  });

  /// Total time taken in the isolate where the inference runs
  int totalElapsedTime;

  /// [totalPredicTime] + communication overhead time
  /// between main isolate and another isolate
  final int totalPredictTime;

  /// Time for which the inference runs
  final int inferenceTime;

  /// Time taken to pre-process the image
  final int preProcessingTime;

  @override
  String toString() {
    return 'Stats{totalPredictTime: $totalPredictTime, totalElapsedTime: $totalElapsedTime, inferenceTime: $inferenceTime, preProcessingTime: $preProcessingTime}';
  }
}
