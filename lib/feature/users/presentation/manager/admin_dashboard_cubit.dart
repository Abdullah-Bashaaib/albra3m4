import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit() : super(const AdminDashboardState());

  void selectSection(AdminSection section) {
    if (state.selectedSection == section) return;
    emit(state.copyWith(selectedSection: section));
  }
}
