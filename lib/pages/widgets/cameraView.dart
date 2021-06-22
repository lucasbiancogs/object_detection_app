import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../tflite/classifier.dart';
import '../../utils/isolateUtils.dart';
import '../../utils/cameraSingletonUtils.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  const CameraView({
    @required this.streamController,
    this.child,
  });

  final StreamController<Inference> streamController;

  final Widget child;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  Sink get _sink => widget.streamController.sink;

  Future<void> _future;

  CameraController _controller;

  /// True when inference is ongoing
  bool _predicting;

  Classifier _classifier;

  IsolateUtils _isolateUtils;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(
            _controller,
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _initStateAsync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Initialize camera
    await _initializeCamera();

    // Spawn a new isolate
    _isolateUtils = IsolateUtils();
    await _isolateUtils.start();

    // Create an instance of classifier to load model and labels
    _classifier = Classifier();

    _predicting = false;
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );

    _controller.initialize().then((_) async {
      /// Start stream of image passed to [onLatestImageAvailable] callback
      await _controller.startImageStream(_onLatestImageAvailable);

      /// inputImageSize is the previewSize of each image frame captured by the controller
      ///
      /// 325x288 on iOS and 240p (320x240) on Android with ResolutionPreset.low
      CameraSingleton.inputImageSize = _controller.value.previewSize;

      /// The display width of image on screen is
      /// same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraSingleton.screenSize = screenSize;
    });
  }

  void _onLatestImageAvailable(CameraImage cameraImage) async {
    if (_classifier?.interpreter != null && _classifier?.labels != null) {
      // If previous inference is not completed then return
      if (_predicting) return;

      _predicting = true;

      final uiThreadInferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      final isolateData = IsolateData(
        cameraImage: cameraImage,
        interpreterAddress: _classifier.interpreter.address,
        labels: _classifier.labels,
      );

      final Inference inferenceResult = await _inference(isolateData);

      final uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadInferenceTimeStart;

      inferenceResult.stats.totalElapsedTime = uiThreadInferenceElapsedTime;

      _sink.add(inferenceResult);

      _predicting = false;
    }
  }

  /// Runs inference in another isolate
  Future<Inference> _inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    _isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    final Inference results = await responsePort.first;

    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        _controller.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!_controller.value.isStreamingImages) {
          await _controller.startImageStream(_onLatestImageAvailable);
        }
        break;
      default:
    }
  }
}
