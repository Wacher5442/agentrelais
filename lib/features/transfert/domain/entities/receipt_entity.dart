import 'package:equatable/equatable.dart';

class ReceiptEntity extends Equatable {
  final String imagePath;
  final String receiptNumber;

  const ReceiptEntity({required this.imagePath, required this.receiptNumber});

  Map<String, dynamic> toMap() {
    return {'imagePath': imagePath, 'receiptNumber': receiptNumber};
  }

  factory ReceiptEntity.fromMap(Map<String, dynamic> map) {
    return ReceiptEntity(
      imagePath: map['imagePath'] as String,
      receiptNumber: map['receiptNumber'] as String,
    );
  }

  @override
  List<Object?> get props => [imagePath, receiptNumber];
}
