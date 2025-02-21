import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool isWideScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await _refreshIndicatorKey.currentState?.show(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isWideScreen', isWideScreen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).filesTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: S.of(context).refresh,
          onPressed:
              () async => await _refreshIndicatorKey.currentState?.show(),
        ),
      ],
    ),
    drawer: const StudiPassauDrawer(DrawerItem.files),
    body: BlocBuilder<LoginCubit, LoginState>(
      builder:
          (context, stateL) => BlocConsumer<FilesCubit, FilesState>(
            listener: showErrorMessage,
            builder: (context, state) {
              isWideScreen =
                  MediaQuery.of(context).size.width > wideScreenWidth;
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) async {
                  if (didPop) {
                    return;
                  }
                  final wasHome = state.goUp();
                  if (wasHome) {
                    await SystemNavigator.pop();
                  } else {
                    await refresh(context, stateL: stateL, state: state);
                  }
                },
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh:
                      () async =>
                          refresh(context, stateL: stateL, state: state),
                  child:
                      state.folderState == FolderState.home
                          ? ListView(
                            children: state.courses
                                .map(
                                  (c) => CourseWidget(
                                    course: c,
                                    onTap: () async {
                                      await loadCourse(c);
                                    },
                                  ),
                                )
                                .sortedByCompare(
                                  (f) => f.sortKey,
                                  compareNatural,
                                )
                                .toList(growable: false),
                          )
                          : ListView(
                            children:
                                <Widget>[
                                  FolderWidget(
                                    folder: Folder.goUp(),
                                    onTap: () async {
                                      state.goUp();
                                      await refresh(
                                        context,
                                        stateL: stateL,
                                        state: state,
                                      );
                                    },
                                  ),
                                ] +
                                state.folders
                                    .map(
                                      (f) => FolderWidget(
                                        folder: f,
                                        onTap: () async {
                                          await loadFolder(f);
                                        },
                                      ),
                                    )
                                    .sortedByCompare(
                                      (f) => f.sortKey,
                                      compareNatural,
                                    )
                                    .toList(growable: false) +
                                state.files
                                    .map(
                                      (f) => FileWidget(
                                        file: f,
                                        onTap: () async {
                                          final theme = Theme.of(context);
                                          final pd = ProgressDialog(
                                            context: context,
                                          );
                                          unawaited(
                                            pd.show(
                                              msg: S.of(context).downloading,
                                              backgroundColor:
                                                  theme
                                                      .dialogTheme
                                                      .backgroundColor ??
                                                  Colors.white,
                                            ),
                                          );
                                          await downloadFile(
                                            f,
                                            onProgress:
                                                (perc) => pd.update(
                                                  value: perc.round(),
                                                ),
                                            onDone: OpenFilex.open,
                                          );
                                        },
                                        showDownloads: isWideScreen,
                                      ),
                                    )
                                    .sortedByCompare(
                                      (f) => f.sortKey,
                                      compareNatural,
                                    )
                                    .toList(growable: false),
                          ),
                ),
              );
            },
          ),
    ),
  );

  Future<String> downloadFile(
    File file, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) async => context.read<FilesCubit>().downloadFile(
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
