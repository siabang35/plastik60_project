import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderTimeline extends StatelessWidget {
  final String status;

  const OrderTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Updated steps to match the status values in the Order class
    final steps = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    // Handle case when status is not found in steps
    final currentStepIndex =
        steps.contains(status.toLowerCase())
            ? steps.indexOf(status.toLowerCase())
            : 0;

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          if (steps[i] != 'cancelled' || status.toLowerCase() == 'cancelled')
            _buildTimelineTile(
              context,
              title: _getStepTitle(steps[i]),
              subtitle: _getStepSubtitle(steps[i]),
              isFirst: i == 0,
              isLast: i == steps.length - 1 || steps[i] == 'cancelled',
              isPast: i < currentStepIndex,
              isActive: i == currentStepIndex,
              isCancelled: steps[i] == 'cancelled',
            ),
      ],
    );
  }

  Widget _buildTimelineTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required bool isPast,
    required bool isActive,
    bool isCancelled = false,
  }) {
    final isDone = isPast || isActive;
    final Color activeColor = isCancelled ? Colors.red : Colors.green;

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.2,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        height: 30,
        indicator: Container(
          decoration: BoxDecoration(
            color: isDone ? activeColor : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isDone
                      ? (isCancelled
                          ? Colors.red.shade700
                          : Colors.green.shade700)
                      : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Icon(
            _getStepIcon(isPast, isActive, isCancelled),
            color: isDone ? Colors.white : Colors.grey.shade500,
            size: 16,
          ),
        ),
      ),
      beforeLineStyle: LineStyle(
        color: isPast ? activeColor : Colors.grey.shade300,
        thickness: 2,
      ),
      afterLineStyle: LineStyle(
        color: isActive ? activeColor : Colors.grey.shade300,
        thickness: 2,
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isDone
                        ? (isCancelled ? Colors.red : Colors.black)
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDone
                        ? (isCancelled ? Colors.red.shade700 : Colors.black54)
                        : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(bool isPast, bool isActive, bool isCancelled) {
    if (isCancelled) {
      return Icons.cancel;
    } else if (isPast) {
      return Icons.check;
    } else if (isActive) {
      return Icons.sync;
    } else {
      return Icons.circle;
    }
  }

  String _getStepTitle(String step) {
    switch (step) {
      case 'pending':
        return 'Order Placed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return step.substring(0, 1).toUpperCase() + step.substring(1);
    }
  }

  String _getStepSubtitle(String step) {
    switch (step) {
      case 'pending':
        return 'Your order has been placed';
      case 'processing':
        return 'Your order is being processed';
      case 'shipped':
        return 'Your order has been shipped';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }
}
