import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// مراقب عام لجميع الـ Cubits/Blocs في التطبيق.
///
/// يُسجَّل مرة واحدة في main() قبل runApp():
/// ```dart
/// Bloc.observer = AppBlocObserver();
/// ```
///
/// يطبع في الـ console:
/// - إنشاء/إغلاق كل Cubit/Bloc
/// - كل تغيّر في الحالة (من → إلى)
/// - أي خطأ يحدث داخل أي Cubit/Bloc، مع الـ StackTrace
///
/// لا يطبع شيئاً في وضع الإصدار (Release) — فقط أثناء التطوير (Debug/Profile).
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _log('🟢 تم إنشاء', bloc);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _log(
      '🔄 انتقال',
      bloc,
      details:
          'من: ${transition.currentState.runtimeType}\n'
          '   إلى: ${transition.nextState.runtimeType}\n'
          '   الحدث: ${transition.event.runtimeType}',
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log(
      '🔄 تغيّرت الحالة',
      bloc,
      details:
          'من: ${change.currentState.runtimeType}\n'
          '   إلى: ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log('🔴 خطأ', bloc, details: error.toString());
    if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: '${bloc.runtimeType}');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _log('⚪ تم إغلاق', bloc);
  }

  void _log(String action, BlocBase<dynamic> bloc, {String? details}) {
    if (!kDebugMode) return;

    final buffer = StringBuffer('[${bloc.runtimeType}] $action');

    if (details != null) {
      buffer.write('\n   $details');
    }

    log(buffer.toString());
  }
}
