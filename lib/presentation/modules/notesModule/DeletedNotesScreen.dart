import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';
import 'package:notes/shared/utils/Extensions.dart';

class DeletedNotesScreen extends StatefulWidget {
  const DeletedNotesScreen({super.key});

  @override
  State<DeletedNotesScreen> createState() => _DeletedNotesScreenState();
}

class _DeletedNotesScreenState extends State<DeletedNotesScreen> {

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = theme.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessRestoreFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notesDeleted.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
                context: context,
                title: 'Note Restored',
                isDarkTheme: isDarkTheme,
            ));
        }

        if(state is SuccessRestoreAllNotesFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'All Notes Restored',
              isDarkTheme: isDarkTheme,
            ));

        }

        if(state is SuccessDeleteFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notesDeleted.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'Note Deleted',
              isDarkTheme: isDarkTheme,
            ));

        }

        if(state is SuccessDeleteAllNotesFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'All Notes Deleted',
              isDarkTheme: isDarkTheme,
            ));
        }
      },
      builder: (context , state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: (cubit.isSelected) ? false : true,
          onPopInvokedWithResult: (v, _) {
            if(cubit.isSelected) {
              cubit.cancelAll(isDeleted: true);
            }
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                Navigator.pop(context);
              },
              title: 'Recycle Bin',
              actions: [
                if(cubit.isSelected && cubit.selectNotesDeleted.
                values.any((element) => (element == true))) ...[
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).restoreAllNotesFromRecycleBin(
                            selectNotesDel: cubit.selectNotesDeleted, context: context);
                      },
                      icon: Icon(
                        Icons.restore_rounded,
                        color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                        size: 30.0,
                      ),
                      tooltip: 'Restore',
                    ),
                  ),
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).deleteAllNotesFromDataBase(selectNotesDel: cubit.selectNotesDeleted);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: redColor,
                        size: 30.0,
                      ),
                      tooltip: 'Remove',
                    ),
                  ),
                ],
                8.0.hrSpace,
              ],
            ),
            body: ConditionalBuilder(
              condition: cubit.notesDeleted.isNotEmpty,
              builder: (context) => ListView.separated(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context , index) => buildItemNoteDeleted(cubit.notesDeleted[index], cubit.selectNotesDeleted,
                    isDarkTheme, context),
                separatorBuilder: (context , index) => 8.0.vrSpace,
                itemCount: cubit.notesDeleted.length,
              ),
              fallback: (context) => Center(
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'No notes in recycle bin',
                    style: TextStyle(
                      fontSize: 19.0,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
