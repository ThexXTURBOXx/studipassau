import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/courses_cubit.dart';
import 'package:studipassau/bloc/cubits/files_cubit.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/cubits/mensa_cubit.dart';
import 'package:studipassau/bloc/cubits/news_cubit.dart';
import 'package:studipassau/bloc/cubits/schedule_cubit.dart';
import 'package:studipassau/bloc/cubits/semesters_cubit.dart';
import 'package:studipassau/bloc/repos/courses_repo.dart';
import 'package:studipassau/bloc/repos/files_repo.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/repos/news_repo.dart';
import 'package:studipassau/bloc/repos/schedule_repo.dart';
import 'package:studipassau/bloc/repos/semesters_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';

class StudiPassauBlocProvider extends StatelessWidget {
  const StudiPassauBlocProvider({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<StorageRepo>(create: (context) => StorageRepo()),
      RepositoryProvider<ScheduleRepo>(create: (context) => ScheduleRepo()),
      RepositoryProvider<MensaRepo>(create: (context) => MensaRepo()),
      RepositoryProvider<FilesRepo>(create: (context) => FilesRepo()),
      RepositoryProvider<NewsRepo>(create: (context) => NewsRepo()),
      RepositoryProvider<CoursesRepo>(create: (context) => CoursesRepo()),
      RepositoryProvider<SemestersRepo>(create: (context) => SemestersRepo()),
    ],
    // We need two BlocProvider layers.
    // The top one are "shared" Cubits.
    // The bottom one are "local" Cubits that may depend on shared ones.
    child: MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(context.read<StorageRepo>()),
        ),
        BlocProvider<CoursesCubit>(
          create: (context) => CoursesCubit(
            context.read<StorageRepo>(),
            context.read<CoursesRepo>(),
          ),
        ),
        BlocProvider<SemestersCubit>(
          create: (context) => SemestersCubit(
            context.read<StorageRepo>(),
            context.read<SemestersRepo>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ScheduleCubit>(
            create: (context) => ScheduleCubit(
              context.read<CoursesCubit>(),
              context.read<StorageRepo>(),
              context.read<ScheduleRepo>(),
            ),
          ),
          BlocProvider<MensaCubit>(
            create: (context) => MensaCubit(
              context.read<StorageRepo>(),
              context.read<MensaRepo>(),
            ),
          ),
          BlocProvider<FilesCubit>(
            create: (context) => FilesCubit(
              context.read<CoursesCubit>(),
              context.read<SemestersCubit>(),
              context.read<FilesRepo>(),
            ),
          ),
          BlocProvider<NewsCubit>(
            create: (context) => NewsCubit(
              context.read<CoursesCubit>(),
              context.read<StorageRepo>(),
              context.read<NewsRepo>(),
            ),
          ),
        ],
        child: child,
      ),
    ),
  );
}
