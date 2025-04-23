import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notify/core/di/providers.dart';
import 'package:notify/presentation/screens/notification_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final notificationViewModel = ref.read(notificationViewModelProvider.notifier);

    final topicController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify - Demo Thông Báo Đẩy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý đăng ký thông báo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Form đăng ký topic
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Nhập tên topic',
                border: OutlineInputBorder(),
                hintText: 'Ví dụ: news, updates, events',
              ),
            ),
            const SizedBox(height: 16),

            // Nút đăng ký và hủy đăng ký
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (topicController.text.isNotEmpty) {
                        notificationViewModel.subscribeTopic(topicController.text);
                        topicController.clear();
                      }
                    },
                    child: const Text('Đăng ký topic'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (topicController.text.isNotEmpty) {
                        notificationViewModel.unsubscribeTopic(topicController.text);
                        topicController.clear();
                      }
                    },
                    child: const Text('Hủy đăng ký topic'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Danh sách các topic đã đăng ký
            const Text(
              'Các topic đã đăng ký:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (notificationState.subscribedTopics.isEmpty)
              const Text('Chưa đăng ký topic nào')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: notificationState.subscribedTopics.length,
                  itemBuilder: (context, index) {
                    final topic = notificationState.subscribedTopics[index];
                    return ListTile(
                      title: Text(topic),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => notificationViewModel.unsubscribeTopic(topic),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        },
        tooltip: 'Xem thông báo',
        child: const Icon(Icons.notifications),
      ),
    );
  }
}