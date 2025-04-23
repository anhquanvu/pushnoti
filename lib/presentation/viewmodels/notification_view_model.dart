import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notify/domain/usecases/notification_use_case.dart';

// State của notification
class NotificationState {
  final bool isSubscribed;
  final List<String> subscribedTopics;
  final List<String> notifications;

  NotificationState({
    this.isSubscribed = false,
    this.subscribedTopics = const [],
    this.notifications = const [],
  });

  NotificationState copyWith({
    bool? isSubscribed,
    List<String>? subscribedTopics,
    List<String>? notifications,
  }) {
    return NotificationState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationUseCase _notificationUseCase;

  NotificationViewModel(this._notificationUseCase) : super(NotificationState());

  // Đăng ký theo dõi một topic
  Future<void> subscribeTopic(String topic) async {
    try {
      await _notificationUseCase.subscribeToTopic(topic);

      // Cập nhật state
      final updatedTopics = [...state.subscribedTopics, topic];
      state = state.copyWith(
        isSubscribed: true,
        subscribedTopics: updatedTopics,
      );

      debugPrint('Đã đăng ký topic: $topic');
    } catch (e) {
      debugPrint('Lỗi khi đăng ký topic: $e');
    }
  }

  // Hủy đăng ký theo dõi một topic
  Future<void> unsubscribeTopic(String topic) async {
    try {
      await _notificationUseCase.unsubscribeFromTopic(topic);

      // Cập nhật state
      final updatedTopics = state.subscribedTopics.where((t) => t != topic).toList();
      state = state.copyWith(
        isSubscribed: updatedTopics.isNotEmpty,
        subscribedTopics: updatedTopics,
      );

      debugPrint('Đã hủy đăng ký topic: $topic');
    } catch (e) {
      debugPrint('Lỗi khi hủy đăng ký topic: $e');
    }
  }

  // Thêm thông báo mới vào danh sách
  void addNotification(String message) {
    final updatedNotifications = [...state.notifications, message];
    state = state.copyWith(notifications: updatedNotifications);
  }

  // Xóa tất cả thông báo
  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }
}