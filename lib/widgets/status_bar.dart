import 'package:flutter/material.dart';
import '../theme.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('9:41',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Icon(Icons.signal_cellular_alt,
                  color: Colors.white, size: 14),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white60),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
