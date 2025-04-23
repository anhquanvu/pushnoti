import 'package:notify/core/services/notification_service.dart';

class NotificationUseCase {
  final NotificationService _notificationService;

  NotificationUseCase(this._notificationService);

  // Đăng ký theo dõi một topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  // Hủy đăng ký theo dõi một topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }
}