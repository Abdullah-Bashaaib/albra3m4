import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';

class QREntity {
  final String id;
  final String schoolId;
  final String schoolName;
  final String code;
  final DateTime? date;
  final int arrivalTime;
  final int departureTime;
  final String createdBy;

  QREntity({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.code,
    required this.date,
    required this.arrivalTime,
    required this.departureTime,
    required this.createdBy,
  });

  QREntity copyWith({
    String? id,
    String? schoolId,
    String? schoolName,
    String? code,
    DateTime? date,
    int? arrivalTime,
    int? departureTime,
    String? createdBy,
  }) {
    return QREntity(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      code: code ?? this.code,
      date: date ?? this.date,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
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
      arrivalTime: qr.arrivalTime,
      departureTime: qr.departureTime,
      createdBy: qr.createdBy,
    );
  }
}
