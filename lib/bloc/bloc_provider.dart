import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/files_cubit.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/cubits/mensa_cubit.dart';
import 'package:studipassau/bloc/cubits/schedule_cubit.dart';
import 'package:studipassau/bloc/repos/files_repo.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/repos/schedule_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';

class StudiPassauBlocProvider extends StatelessWidget {
  final Widget child;

  const StudiPassauBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<StorageRepo>(
            create: (context) => StorageRepo(),
          ),
          RepositoryProvider<ScheduleRepo>(
            create: (context) => ScheduleRepo(),
          ),
          RepositoryProvider<MensaRepo>(
            create: (context) => MensaRepo(),
          ),
          RepositoryProvider<FilesRepo>(
            create: (context) => FilesRepo(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LoginCubit>(
              create: (context) => LoginCubit(context.read<StorageRepo>()),
            ),
            BlocProvider<ScheduleCubit>(
              create: (context) => ScheduleCubit(
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
                context.read<FilesRepo>(),
              ),
            ),
          ],
          child: child,
        ),
      );
}
