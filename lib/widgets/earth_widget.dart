import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';


class EarthWidget extends StatelessWidget {
  const EarthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flutter3DViewer(
      activeGestureInterceptor: true,
      progressBarColor: Colors.orange,
      // You can disable viewer touch response by setting 'enableTouch' to 'false'
      enableTouch: true,
      // This callBack will return the loading progress value between 0 and 1.0
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


