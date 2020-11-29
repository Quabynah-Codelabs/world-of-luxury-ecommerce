import 'package:json_annotation/json_annotation.dart' as j;
import 'package:meta/meta.dart';

part 'messaging.g.dart';

@j.JsonSerializable()
@immutable
class NotificationPayload {
  final dynamic data;
  @j.JsonKey(name: "payload_type")
  final PayloadType payloadType;

  NotificationPayload(this.data, this.payloadType);

  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  factory NotificationPayload.empty() =>
      NotificationPayload(null, PayloadType.BOOKING);
}

/// For payload types of a notification
enum PayloadType { BOOKING, CONVERSATION, TOKEN_UPDATE }

/// Base messaging service
abstract class MessagingService {
  void showNotification({
    @required String title,
    @required String body,
    String channel,
    dynamic payload,
  });

  Future<bool> getNotificationPermissions();
}
