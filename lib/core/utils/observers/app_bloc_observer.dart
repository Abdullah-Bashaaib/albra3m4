import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('🌀 Bloc تم إنشاؤه: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('📨 حدث في ${bloc.runtimeType}: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('🔄 تغيير في ${bloc.runtimeType}:');
    log('   من: ${change.currentState}');
    log('   إلى: ${change.nextState}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('🚀 انتقال في ${bloc.runtimeType}:');
    log('   حدث: ${transition.event}');
    log('   من: ${transition.currentState}');
    log('   إلى: ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('❌ خطأ في ${bloc.runtimeType}: $error');
    log('📍 StackTrace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('🔒 Bloc تم إغلاقه: ${bloc.runtimeType}');
  }
}
