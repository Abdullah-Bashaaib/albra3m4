import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/pages/attendance_q_r_view.dart';
import 'package:albra3m4/feature/attendance/presentation/pages/teacher_scanning_q_r.dart';
import 'package:albra3m4/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Injection.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AttendanceCubit>(create: (_) => sl<AttendanceCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: const TeacherScanningQR(),
        ),
      ),
    );
  }
}
