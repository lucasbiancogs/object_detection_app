import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../tflite/classifier.dart';
import 'imageUtils.dart';

class IsolateUtils {
  static const String DEBUG_NAME = "InferenceIsolate";

  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    await Isolate.spawn<SendPort>(
      _entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void _entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      /// TODO alterate this to an listener
      if (isolateData != null) {
        final Classifier classifier = Classifier(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
          labels: isolateData.labels,
        );

        imageLib.Image image =
            ImageUtils.convertCameraImage(isolateData.cameraImage);

        if (Platform.isAndroid) {
          image = imageLib.copyRotate(image, 90);
        }

        Inference prediction = classifier.predict(image);

        isolateData.responsePort.send(prediction);
      }
    }
  }
}

/// Bundles data to pass beetween Isolate
class IsolateData {
  final CameraImage cameraImage;
  final int interpreterAddress;
  final List<String> labels;
  SendPort responsePort;

  IsolateData({
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  });
}
