import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FullPageLoader extends StatelessWidget {
  final Color backgroundColor;

  const FullPageLoader({
    Key? key,
    this.backgroundColor =
        const Color.fromRGBO(0, 0, 0, 0.3), // fond semi-transparent
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      // bloque les interactions avec les éléments en dessous
      absorbing: true,
      child: Center(
        child: Container(
          color: Colors.transparent,
          child: const Center(
            child: SpinKitThreeBounce(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
