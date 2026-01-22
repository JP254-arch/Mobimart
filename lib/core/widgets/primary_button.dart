import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


class PrimaryButton extends StatelessWidget {
final String text;
final VoidCallback onPressed;


const PrimaryButton({super.key, required this.text, required this.onPressed});


@override
Widget build(BuildContext context) {
return ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
onPressed: onPressed,
child: Text(text),
);
}
}