import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notify/core/services/notification_service.dart';
import 'package:notify/domain/usecases/notification_use_case.dart';
import 'package:notify/presentation/viewmodels/notification_view_model.dart';

// Service Providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// UseCase Providers
final notificationUseCaseProvider = Provider<NotificationUseCase>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationUseCase(notificationService);
});

// ViewModel Providers
final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final notificationUseCase = ref.watch(notificationUseCaseProvider);
  return NotificationViewModel(notificationUseCase);
});