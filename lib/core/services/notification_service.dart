import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Channel ID cho Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Thông Báo Quan Trọng',
    description: 'Kênh này được sử dụng cho các thông báo quan trọng',
    importance: Importance.high,
  );

  Future<void> init() async {
    // Yêu cầu quyền thông báo
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Trạng thái quyền thông báo: ${settings.authorizationStatus}');

    // Lấy token thiết bị (quan trọng để gửi thông báo đến thiết bị cụ thể)
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Lưu token vào storage hoặc gửi lên server của bạn

    // Khởi tạo Local notifications cho Android
    await _setupLocalNotifications();

    // Xử lý khi nhận thông báo trong khi ứng dụng đang chạy
    _setupForegroundNotificationHandling();

    // Xử lý khi người dùng bấm vào thông báo
    _setupNotificationTapHandling();
  }

  Future<void> _setupLocalNotifications() async {
    // Cấu hình cho Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình cho iOS
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Khởi tạo cấu hình
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Khởi tạo plugin
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi người dùng bấm vào thông báo local
        print('Đã nhấn vào thông báo local: ${response.payload}');
      },
    );

    // Tạo channel trên Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _setupForegroundNotificationHandling() {
    // Xử lý thông báo khi app đang chạy
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Đã nhận thông báo trong foreground: ${message.notification?.title}');

      // Hiển thị thông báo local nếu có nội dung thông báo
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  void _setupNotificationTapHandling() {
    // Xử lý khi app được mở từ terminated state bởi thông báo
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App mở từ thông báo: ${message.notification?.title}');
        // Điều hướng tới màn hình phù hợp dựa trên dữ liệu của thông báo
      }
    });

    // Xử lý khi bấm vào thông báo khi app đang chạy background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App từ background được mở bởi thông báo: ${message.notification?.title}');
      // Điều hướng tới màn hình phù hợp dựa trên dữ liệu của thông báo
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Chỉ hiển thị notification trên Android nếu có thông tin
    if (notification != null && android != null && !kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon ?? 'launch_background',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Phương thức đăng ký theo dõi topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Phương thức hủy đăng ký theo dõi topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}