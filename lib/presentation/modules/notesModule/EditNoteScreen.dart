import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/utils/Helpers.dart';

class EditNoteScreen extends StatefulWidget {

  final Map note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  final ScrollController scrollController = ScrollController();

  GlobalKey globalKey = GlobalKey();

  // Future<File> generatePdfInBackground({
  //   required String title,
  //   required String content,
  //   required List<dynamic> imagePaths,
  //   required bool isArabicTitle,
  //   required bool isArabicContent,
  // }) async {
  //
  //   final fontData1 = await rootBundle.load('assets/fonts/VarelaRound-Regular.ttf');
  //   final fontData2 = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
  //
  //   final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  //   final Completer<File> completer = Completer();
  //
  //   await compute(generateDoc, [title, content, imagePaths,
  //     rootIsolateToken, fontData1, fontData2,
  //     isArabicTitle, isArabicContent]).then((value) {
  //      completer.complete(value);
  //      }).catchError((error) {
  //      completer.completeError(error);
  //    });
  //
  //   return completer.future;
  // }


  @override
  void initState() {
    super.initState();
    titleController.addListener(() {setState(() {});});
    contentController.addListener(() {setState(() {});});
    titleController.text = widget.note['title'];
    contentController.text = widget.note['content'];
    // Future.delayed(const Duration(milliseconds: 300)).then((value) {
    //   if(!mounted) return;
    //   AppCubit.get(context).detectLangText(true, titleController.text);
    //   AppCubit.get(context).detectLangText(false, contentController.text);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    titleController.removeListener(() {setState(() {});});
    contentController.removeListener(() {setState(() {});});
    scrollController.dispose();
  }

    @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);

    final bool isDarkTheme = themeData.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessGetImageAppState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 700)).then((value) {
              scrollToBottom(scrollController);
            });
          });
        }

        if(state is ErrorGetImageAppState) {

          if(state.error == 'error-size') {

            cubit.clearAllImages();
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(
                      context: context,
                      title: 'Image is bigger than 10MB',
                      isDarkTheme: isDarkTheme,
                      duration: 1000,
                      bgColor: redColor,
                  ));
              }
            });

          } else {

            cubit.clearAllImages();
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(
                      context: context,
                      title: 'Error, please try again!',
                      isDarkTheme: isDarkTheme,
                      duration: 1000,
                      bgColor: redColor,
                  ));
              }
            });
          }

        }


        if(state is SuccessDeleteImageNoteFromDataBaseAppState) {
          cubit.getImageNoteFromDataBase(widget.note['id'], cubit.dataBase);
        }


        if(state is SuccessUpdateImageNoteFromDataBaseAppState ||
            state is SuccessAddImageNoteIntoDataBaseAppState) {
          cubit.clearAllImages();
        }

      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          onPopInvokedWithResult: (v, _) {
            editNote(cubit);
          },
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if(details.primaryVelocity! > 0) {
                focusNode1.unfocus();
                focusNode2.unfocus();
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              appBar: defaultAppBar(
                onPress: () {
                  focusNode1.unfocus();
                  focusNode2.unfocus();
                  Navigator.pop(context);
                },
                title: 'Edit Note',
                actions: [
                  if(titleController.text.isNotEmpty &&
                      titleController.text.trim().isNotEmpty &&
                      (cubit.dataImg.length + cubit.imagePaths.length) < 5)
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        onPressed: () {
                          focusNode1.unfocus();
                          focusNode2.unfocus();
                          showOptions(isDarkTheme, context);
                        },
                        icon: Icon(
                          EvaIcons.imageOutline,
                          color: isDarkTheme ? anotherDarkPrimaryColor : lightPrimaryColor,
                          size: 30.0,
                        ),
                        enableFeedback: true,
                        tooltip: 'Add Image',
                      ),
                    ),
                  8.0.hrSpace,
                ],
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                clipBehavior: Clip.antiAlias,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        defaultTextFormField(
                            controller: titleController,
                            focusNode: focusNode1,
                            hintText: 'Title',
                            onPress: () {
                              FocusScope.of(context).requestFocus(focusNode2);
                            },
                        ),
                       20.0.vrSpace,
                        defaultTextFormField(
                          controller: contentController,
                          focusNode: focusNode2,
                          hintText: 'Content',
                          isTitle: false,
                        ),
                       40.0.vrSpace,
                        if(cubit.dataImg.isNotEmpty || cubit.imagePaths.isNotEmpty)
                          FadeIn(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '${cubit.dataImg.length + cubit.imagePaths.length} / 5',
                              style: const TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        12.0.vrSpace,
                        if(cubit.dataImg.isNotEmpty)
                          ZoomIn(
                            duration: Duration(milliseconds: 500),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              clipBehavior: Clip.antiAlias,
                              padding: const EdgeInsets.all(10.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1 / 0.9,
                                mainAxisSpacing: 30.0,
                              ),
                              itemBuilder: (context, index) => buildItemImageNote(cubit.dataImg[index]['id'],
                                  globalKey, cubit.dataImg[index]['image'], isDarkTheme, context),
                              itemCount: cubit.dataImg.length,
                            ),
                          ),
                        16.0.vrSpace,
                        if(cubit.imagePaths.isNotEmpty) ...[
                          if(cubit.dataImg.isNotEmpty) ...[
                            FadeIn(
                              duration: const Duration(milliseconds: 200),
                              child: const Text(
                                'New images',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            FadeIn(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDarkTheme ? Colors.white : Colors.black,
                              ),
                            ),
                            12.0.vrSpace,
                          ],
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.1), // from bottom slightly
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        )),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: GridView.builder(
                              key: ValueKey<int>(cubit.imagePaths.length),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              clipBehavior: Clip.antiAlias,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1 / 0.85,
                              ),
                              itemBuilder: (context, index) => buildItemImagePicked(
                                  cubit, cubit.imagePaths[index], index, isDarkTheme, context),
                              itemCount: cubit.imagePaths.length,
                            ),
                          ),
                        ],
                      ],
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

  void editNote(AppCubit cubit) {
      if((titleController.text.isNotEmpty &&
          titleController.text != widget.note['title'])
          || (contentController.text != widget.note['content'])
          || (cubit.imagePaths.isNotEmpty)) {
        cubit.updateIntoDataBase(
            id: widget.note['id'],
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            date: DateFormat('dd MMM yyyy').format(DateTime.timestamp()).toString(),
            dateTime: DateTime.timestamp().toString(),
            isEmptyNote:((titleController.text == '' || titleController.text.trim().isEmpty)
                && (contentController.text == '' || contentController.text.trim().isEmpty) ) ? true : false,
        );
      }
    }

}
