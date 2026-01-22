import 'dart:typed_data';
import 'package:flutter/material.dart';

class PickImageWidget extends StatelessWidget {
  const PickImageWidget({
    super.key,
    required this.pickedImageBytes,
    required this.onTap,
  });

  final Uint8List? pickedImageBytes;
  final VoidCallback onTap;

  static const double _radius = 18.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: pickedImageBytes == null
                ? Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_outline,
                      size: 50,
                      color: Colors.grey,
                    ),
                  )
                : Image.memory(
                    pickedImageBytes!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        /// Camera button
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add_a_photo, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
