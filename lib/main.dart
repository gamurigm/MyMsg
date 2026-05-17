import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:my_msg/data/datasources/chat_remote_data_source.dart';
import 'package:my_msg/data/repositories/chat_repository_impl.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';
import 'package:my_msg/domain/usecases/get_messages_stream.dart';
import 'package:my_msg/domain/usecases/send_message.dart';
import 'package:my_msg/presentation/bloc/chat/chat_bloc.dart';
import 'package:my_msg/presentation/pages/connection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/presentation/pages/chat_page.dart';

final sl = GetIt.instance;

void setupLocator() {
  // Data Sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(
      wsUrl: 'ws://127.0.0.1:8081',
      restUrl: 'http://127.0.0.1:8081',
    ),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMessagesStream(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  // Blocs
  sl.registerFactory(
    () => ChatBloc(
      getMessagesStream: sl(),
      sendMessage: sl(),
      repository: sl(),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  final prefs = await SharedPreferences.getInstance();
  final savedIp = prefs.getString('saved_ip');
  final savedUsername = prefs.getString('saved_username');

  Widget initialPage = const ConnectionPage();

  if (savedIp != null && savedUsername != null) {
    // Restaurar conexión automáticamente
    final ds = sl<ChatRemoteDataSource>();
    ds.updateUrls(savedIp);
    ds.connect(savedUsername);

    initialPage = ChatPage(
      chat: const Chat(id: 'global', name: 'MyMsg Chat'),
      currentUsername: savedUsername,
    );
  }

  runApp(MyMsgApp(initialPage: initialPage));
}

class MyMsgApp extends StatelessWidget {
  final Widget initialPage;
  const MyMsgApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyMsg',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF00E5FF), // Neon Cyan / Celeste
          scaffoldBackgroundColor: const Color(0xFF0A0E14), // Very dark background for contrast
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFF00B8D4),
            surface: Color(0xFF121820),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121820),
            foregroundColor: Color(0xFF00E5FF),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: initialPage,
      ),
    );
  }
}
