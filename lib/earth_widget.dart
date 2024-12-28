import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';


class EarthWidget extends StatelessWidget {
  const EarthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flutter3DViewer.obj(
        src: 'assets/tinker.obj',
        scale: 5,
        cameraX: 0,
        cameraY: 0,
        cameraZ: 10,

        onProgress: (double progressValue) {
          debugPrint('model loading progress : $progressValue');
        },
        onLoad: (String modelAddress) {
          debugPrint('model loaded : $modelAddress');
        },
        onError: (String error) {
          debugPrint('model failed to load : $error');
        },
      );
  }
}


