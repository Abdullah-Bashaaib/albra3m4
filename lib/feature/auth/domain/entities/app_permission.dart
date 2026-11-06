import 'dart:convert';

/// Additional responsibilities available to teachers. No "none" value is needed:
/// an empty list means the teacher has no internal department assignment.
enum AppPermission {
  manageMedia,
  manageTechnical,
  manageFinance,
  manageActivities,
}

extension AppPermissionLabel on AppPermission {
  String get arabicLabel => switch (this) {
    AppPermission.manageMedia => 'الإعلام',
    AppPermission.manageTechnical => 'الإدارة الفنية',
    AppPermission.manageFinance => 'المالية',
    AppPermission.manageActivities => 'الأنشطة',
  };
}

/// Defensive parser for old accounts, malformed cache values and future keys.
abstract final class AppPermissionCodec {
  static List<AppPermission> fromList(Object? raw) {
    if (raw is! List) return const [];
    final known = <AppPermission>{};
    for (final value in raw) {
      if (value is! String) continue;
      for (final permission in AppPermission.values) {
        if (permission.name == value) known.add(permission);
      }
    }
    return List.unmodifiable(known);
  }

  static String toJson(List<AppPermission> permissions) =>
      jsonEncode(permissions.map((permission) => permission.name).toList());

  static List<AppPermission> fromJson(Object? raw) {
    if (raw is! String) return const [];
    try {
      return fromList(jsonDecode(raw));
    } on FormatException {
      return const [];
    }
  }
}
