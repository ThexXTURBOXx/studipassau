import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:studipassau/bloc/cubits/files_cubit.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/files/widgets/course.dart';
import 'package:studipassau/pages/files/widgets/file.dart';
import 'package:studipassau/pages/files/widgets/folder.dart';

const routeFiles = '/files';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<StatefulWidget> createState() => _FilesPagePageState();
}

class _FilesPagePageState extends State<FilesPage>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _refreshIndicatorKey.currentState?.show(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).filesTitle),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.of(context).refresh,
              onPressed: () => _refreshIndicatorKey.currentState?.show(),
            ),
          ],
        ),
        drawer: const StudiPassauDrawer(DrawerItem.files),
        body: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, stateL) => BlocConsumer<FilesCubit, FilesState>(
            listener: showErrorMessage,
            builder: (context, state) => WillPopScope(
              onWillPop: () async {
                final ret = state.goUp();
                if (!ret) {
                  await refresh(
                    context,
                    stateL: stateL,
                    state: state,
                  );
                }
                return ret;
              },
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => refresh(
                  context,
                  stateL: stateL,
                  state: state,
                ),
                child: state.folderState == FolderState.home
                    ? ListView(
                        children: state.courses
                            .map(
                              (c) => CourseWidget(
                                course: c,
                                onTap: () => loadCourse(c),
                              ),
                            )
                            .toList(growable: false),
                      )
                    : ListView(
                        children: <StatelessWidget>[] +
                            state.folders
                                .map(
                                  (f) => FolderWidget(
                                    folder: f,
                                    onTap: () => loadFolder(f),
                                  ),
                                )
                                .toList(growable: false) +
                            state.files
                                .map(
                                  (f) => FileWidget(
                                    file: f,
                                    onTap: () async {
                                      final pd =
                                          ProgressDialog(context: context);
                                      pd.show(
                                        max: 100,
                                        msg: S.of(context).downloading,
                                      );
                                      await downloadFile(
                                        f,
                                        onProgress: (perc) =>
                                            pd.update(value: perc.round()),
                                        onDone: OpenFilex.open,
                                      );
                                    },
                                  ),
                                )
                                .toList(growable: false),
                      ),
              ),
            ),
          ),
        ),
      );

  Future<String> downloadFile(
    File file, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) async =>
      context.read<FilesCubit>().downloadFile(
            file,
            onProgress: onProgress,
            onError: onError,
            onDone: onDone,
          );

  Future<void> loadCourse(Course course) async {
    await context.read<FilesCubit>().loadCourseTopFolder(course);
  }

  Future<void> loadFolder(Folder folder) async {
    await context.read<FilesCubit>().loadFolder(folder);
  }

  Future<void> refresh(
    BuildContext context, {
    LoginState? stateL,
    FilesState? state,
  }) async {
    await context.read<FilesCubit>().refresh(
          userId: stateL?.userId,
          course: state?.currentCourse,
          folder: state?.currentFolder,
        );
  }
}
