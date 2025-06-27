import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  ready,
  delivered,
}

class OrderTrackingWidget extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTrackingWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "تتبع الطلب",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStep("قيد التجهيز", OrderStatus.pending),
          _buildDivider(),
          _buildStep("جاهز للتوصيل", OrderStatus.ready),
          _buildDivider(),
          _buildStep("تم التوصيل", OrderStatus.delivered),
        ],
      ),
    );
  }

  Widget _buildStep(String title, OrderStatus stepStatus) {
    bool isCompleted = stepStatus.index <= currentStatus.index;
    IconData icon = isCompleted ? Icons.check_circle : Icons.hourglass_empty;

    Color? iconColor;
    if (stepStatus == OrderStatus.pending && isCompleted) {
      iconColor = Colors.orange;
    } else if (stepStatus == OrderStatus.ready && isCompleted)
      iconColor = Colors.blue;
    else if (stepStatus == OrderStatus.delivered && isCompleted)
      iconColor = Colors.green;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? iconColor! : Colors.grey),
            color: isCompleted ? iconColor?.withOpacity(0.2) : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isCompleted ? iconColor : Colors.grey,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 24,
        child: VerticalDivider(
          thickness: 2,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}