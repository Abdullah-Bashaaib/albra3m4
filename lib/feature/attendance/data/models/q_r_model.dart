import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';

class QRModel extends QREntity {
  QRModel({
    required super.id,
    required super.code,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.createdBy,
  });

  factory QRModel.fromJson(Map<String, dynamic> json) {
    return QRModel(
      id: json['id'],
      code: json['code'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'created_by': createdBy,
    };
  }

  factory QRModel.fromEntity(QREntity qr) {
    return QRModel(
      id: qr.id,
      code: qr.code,
      date: qr.date,
      startTime: qr.startTime,
      endTime: qr.endTime,
      createdBy: qr.createdBy,
    );
  }
}
