/// Datos de un conductor gestionados por la cooperativa.
class DriverEntity {
  final String id;
  final String fullName;
  final String email;
  final String? licenseNumber;
  final String? assignedBusId;
  final String? assignedBusPlate;
  final bool isActive;
  final DateTime createdAt;

  const DriverEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.licenseNumber,
    this.assignedBusId,
    this.assignedBusPlate,
    this.isActive = true,
    required this.createdAt,
  });

  DriverEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? licenseNumber,
    String? assignedBusId,
    String? assignedBusPlate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedBusPlate: assignedBusPlate ?? this.assignedBusPlate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
