import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notify/core/di/providers.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final notificationViewModel = ref.read(notificationViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => notificationViewModel.clearNotifications(),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: notificationState.notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có thông báo nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: notificationState.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationState.notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(notification),
              subtitle: const Text('Nhấn để xem chi tiết'),
              onTap: () {
                // Hiển thị chi tiết thông báo
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Chi tiết thông báo'),
                    content: Text(notification),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      // Thêm nút để mô phỏng việc nhận thông báo mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          notificationViewModel.addNotification(
              'Thông báo demo #${notificationState.notifications.length + 1} - ${DateTime.now().toString().substring(0, 16)}');
        },
        tooltip: 'Thêm thông báo test',
        child: const Icon(Icons.add),
      ),
    );
  }
}