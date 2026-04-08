import 'package:flutter/material.dart';
import '../models/request_item.dart';
import '../utils/app_colors.dart';

class RequestCard extends StatelessWidget {
  final RequestItem request;
  final bool showActions;

  const RequestCard({
    super.key,
    required this.request,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.itemTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Sender: ${request.sender}'),
            Text('Location: ${request.location}'),
            Text(
              request.time,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (showActions) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}