import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class EarthWidget extends StatefulWidget {
  const EarthWidget({super.key});

  @override
  _EarthWidgetState createState() => _EarthWidgetState();
}

class _EarthWidgetState extends State<EarthWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset('assets/earths/4.svg'), // Replace with your SVG
    );
  }
}




/*

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

 */


