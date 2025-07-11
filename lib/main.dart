import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/presentation/modules/notesModule/NotesScreen.dart';
import 'package:notes/shared/blocObserver/SimpleBlocObserver.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/styles/Styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = SimpleBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppCubit()..createDataBase(context)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Notes Flutter App',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const NotesScreen(),
      ),
    );
  }
}

