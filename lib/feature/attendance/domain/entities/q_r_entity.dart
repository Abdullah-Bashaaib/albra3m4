import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';

class QREntity {
  final String id;
  final String schoolId;
  final String schoolName;
  final String code;
  final DateTime? date;
  final int startTime;
  final int endTime;
  final String createdBy;

  QREntity({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.code,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
  });

  QREntity copyWith({
    String? id,
    String? schoolId,
    String? schoolName,
    String? code,
    DateTime? date,
    int? startTime,
    int? endTime,
    String? createdBy,
  }) {
    return QREntity(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
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
      schoolId: qr.schoolId,
      schoolName: qr.schoolName,
      code: qr.code,
      date: qr.date,
      startTime: qr.startTime,
      endTime: qr.endTime,
      createdBy: qr.createdBy,
    );
  }
}
