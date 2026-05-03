import 'package:flutter/material.dart';

import '../models/request_item.dart';

class RequestCard extends StatelessWidget {
  final RequestItem request;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const RequestCard({
    super.key,
    required this.request,
    this.showActions = true,
    this.onAccept,
    this.onDecline,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.itemTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'From: ${request.senderName}',
              style: const TextStyle(fontSize: 14),
            ),

            if (request.senderEmail.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                request.senderEmail,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.location.isEmpty
                        ? 'No location'
                        : request.location,
                  ),
                ),
              ],
            ),

            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.message,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  request.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            if (showActions && request.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}