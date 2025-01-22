import 'package:flutter/material.dart';

class AdditionalInformationItem extends StatelessWidget {
  final IconData icon;
  final String info;
  final String amount;
  const AdditionalInformationItem({
    super.key,
    required this.icon,
    required this.info,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 6),
        Text(info),
        const SizedBox(height: 5),
        Text(amount),
      ],
    );
  }
}
