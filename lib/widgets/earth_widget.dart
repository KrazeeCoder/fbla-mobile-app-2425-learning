import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';


class EarthWidget extends StatelessWidget {
  const EarthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flutter3DViewer(
      activeGestureInterceptor: true,
      progressBarColor: Colors.orange,
      enableTouch: true,
      onProgress: (double progressValue) {
        debugPrint('model loading progress : $progressValue');
      },
      onLoad: (String modelAddress) {
        debugPrint('model loaded : $modelAddress');
      },
      onError: (String error) {
        debugPrint('model failed to load : $error');
      },
      src: 'assets/earth_basic_test.glb',
    );
  }
}


