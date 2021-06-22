import 'dart:async';

import 'package:flutter/material.dart';

import '../tflite/classifier.dart';
import 'widgets/cameraView.dart';
import 'widgets/boundingBoxes.dart';
import 'widgets/statsSheet.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  StreamController<Inference> _streamController;

  @override
  void initState() {
    _streamController = StreamController<Inference>.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Object Detection')),
      body: Container(
        height: double.infinity,
        child: CameraView(
          streamController: _streamController,
          child: StreamBuilder<Inference>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              final inference = snapshot.data;

              return Stack(
                fit: StackFit.expand,
                children: [
                  BoundingBoxes(inference?.recognitions),
                  StatsSheet(inference?.stats),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.9),
//                 borderRadius: BorderRadius.only(
//                   topLeft: BOTTOM_SHEET_RADIUS,
//                   topRight: BOTTOM_SHEET_RADIUS,
//                 ),
//               ),
//               child: Center(
//                 child: StreamBuilder<Inference>(
//                   stream: _streamController.stream,
//                   builder: (context, snapshot) {
//                     final inference = snapshot.data;

//                     return StatsSheet(inference?.stats);
//                   },
//                 ),
//               ),
//             ),