import 'dart:ui';

/// Singleton to record size related data
class CameraSingleton {
  static Size screenSize;
  static Size inputImageSize;
  static Size get actualPreviewSize =>
      Size(screenSize.width, screenSize.width * ratio);

  static double get ratio => screenSize.width / inputImageSize.height;
}
