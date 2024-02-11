import 'package:keyboard/enums.dart';

class MessageModel {
  final MessageOrderType orderType;
  final String? message;

  const MessageModel({required this.orderType, this.message});

  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType.toString().split('.').last, // Enum'ı string'e dönüştürme
      'message': message,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    MessageOrderType orderType = MessageOrderType.values.firstWhere(
          (e) => e.toString() == 'MessageOrderType.${json['orderType']}',
      orElse: () => throw ArgumentError('Invalid order type'),
    );

    return MessageModel(
      orderType: orderType,
      message: json['message'],
    );
  }
}
