import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';

class QREntity {
  final String id;
  final String code;
  final String date;
  final String startTime;
  final String endTime;
  final String createdBy;

  QREntity({
    required this.id,
    required this.code,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
  });

  QREntity copyWith({
    String? id,
    String? code,
    String? date,
    String? startTime,
    String? endTime,
    String? createdBy,
  }) {
    return QREntity(
      id: id ?? this.id,
      code: code ?? this.code,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory QREntity.fromModel(QRModel qr) {
    return QREntity(
      id: qr.id,
      code: qr.code,
      date: qr.date,
      startTime: qr.startTime,
      endTime: qr.endTime,
      createdBy: qr.createdBy,
    );
  }
}
