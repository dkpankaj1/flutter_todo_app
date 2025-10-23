// lib/widgets/loading_widget.dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? text;
  const LoadingWidget({super.key, this.text});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        if (text != null) const SizedBox(height: 8),
        if (text != null) Text(text!)
      ]));
}
