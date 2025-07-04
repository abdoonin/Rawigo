import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  Future<void> checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        isAdmin = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    final role = doc.data()?['role'];

    setState(() {
      isAdmin = role == 'admin';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("إدارة الطلبات"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          

        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!isAdmin) {
      return  Scaffold(
        appBar: AppBar(
          title: Text("إدارة الطلبات"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(child: Text("🚫  هذه الصفحة خاصة فقط لادارة الطلبات من المطاعم")),
      );
    }

    // باقي كود الصفحة يبقى نفسه
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الطلبات"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("orders").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ أثناء تحميل الطلبات"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد طلبات حالياً"));
          }

          final orders = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final data = order.data() as Map<String, dynamic>? ?? {};
              final totalPrice = data["totalPrice"] ?? 0;
              final currentStatus = data["status"] ?? "قيد التجهيز";

              final validStatus = StatusDropdown.statuses.contains(currentStatus)
                  ? currentStatus
                  : StatusDropdown.statuses.first;

              return OrderCard(
                orderId: orderId,
                totalPrice: totalPrice,
                currentStatus: validStatus,
                name: data["name"] ?? "طلب بدون اسم",
                imageUrl: data["imageUrl"] ?? "",
              );
            },
          );
        },
      ),
    );
  }
}


class OrderCard extends StatelessWidget {
  final String orderId;
  final dynamic totalPrice;
  final String currentStatus;
  final String name;
  final String imageUrl;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.currentStatus,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      shadowColor: Colors.deepPurple.withOpacity(0.18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xffe9e4f0), Color(0xfff7f8fa)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1.2, color: Colors.deepPurple),
            Row(
             

              children: [
                const Icon(
                  Icons.receipt_long,
                  color: Colors.deepPurple,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "رقم الطلب: $orderId",

                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 22),
                const SizedBox(width: 6),
                Text(
                  "المجموع: $totalPrice دينار",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            StatusDropdown(orderId: orderId, currentStatus: currentStatus),
          ],
        ),
      ),
    );
  }
}

class StatusDropdown extends StatefulWidget {
  final String orderId;
  final String currentStatus;

  const StatusDropdown({
    super.key,
    required this.orderId,
    required this.currentStatus,
  });

  static const List<String> statuses = [
    "قيد التجهيز",
    "جاهز للتوصيل",
    "تم التوصيل",
  ];

  @override
  State<StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown> {
  late String selectedStatus;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = StatusDropdown.statuses.contains(widget.currentStatus)
        ? widget.currentStatus
        : StatusDropdown.statuses.first;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderId)
          .update({"status": newStatus});
      if (!mounted) return;
      setState(() => selectedStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("تم تحديث حالة الطلب"),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("فشل تحديث حالة الطلب"),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "قيد التجهيز":
        return Colors.orange[700]!;
      case "جاهز للتوصيل":
        return Colors.blue[700]!;
      case "تم التوصيل":
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "قيد التجهيز":
        return Icons.hourglass_top;
      case "جاهز للتوصيل":
        return Icons.delivery_dining;
      case "تم التوصيل":
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isUpdating,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _statusColor(selectedStatus).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusColor(selectedStatus).withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStatus,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: _statusColor(selectedStatus),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _statusColor(selectedStatus),
                    fontWeight: FontWeight.w600,
                  ),
                  items: StatusDropdown.statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            _statusIcon(status),
                            color: _statusColor(status),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(status),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != selectedStatus) {
                      _updateStatus(newStatus);
                    }
                  },
                ),
              ),
            ),
          ),
          if (isUpdating)
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
        ],
      ),
    );
  }
}
