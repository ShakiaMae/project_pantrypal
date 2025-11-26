import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black45,  // semi-transparent dark overlay
            child: Center(
              child: Image.asset(
                'assets/chef_hat_spinner.gif',
                width: 100,
                height: 100,
              ),
            ),
          ),
      ],
    );
  }
}
