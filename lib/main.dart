import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'providers/goals_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/phrases_provider.dart';
import 'providers/notes_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/mirror_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/settings_screen.dart';
import 'config/theme.dart';
import 'models/custom_phrase.dart';
import 'models/personal_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar zona horaria
  tz.initializeTimeZones();
  
  // Obtener offset de la zona horaria del dispositivo
  final localTime = DateTime.now();
  final localOffset = localTime.timeZoneOffset;
  
  // Buscar la ubicación TZ que mejor coincida con el offset
  // Para Colombia es America/Bogota (UTC-5)
  String timeZoneName = 'America/Bogota'; // Por defecto Colombia
  
  // Si el offset es diferente, intentar encontrar la zona correcta
  if (localOffset.inHours == -5) {
    timeZoneName = 'America/Bogota'; // Colombia, Perú, Ecuador
  } else if (localOffset.inHours == -6) {
    timeZoneName = 'America/Mexico_City'; // México central
  } else if (localOffset.inHours == -4) {
    timeZoneName = 'America/Santiago'; // Chile, Venezuela
  } else if (localOffset.inHours == -3) {
    timeZoneName = 'America/Sao_Paulo'; // Brasil
  }
  
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  
  print('🌍 Zona horaria configurada: $timeZoneName');
  print('⏰ Offset del dispositivo: ${localOffset.inHours} horas');
  print('🕐 Hora del sistema: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}');
  print('🕐 Hora TZ local: ${tz.TZDateTime.now(tz.local).hour}:${tz.TZDateTime.now(tz.local).minute.toString().padLeft(2, '0')}');
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores de Hive
  Hive.registerAdapter(CustomPhraseAdapter());
  Hive.registerAdapter(PersonalNoteAdapter());
  
  await Hive.openBox('goals');
  await Hive.openBox('notes');
  await Hive.openBox('checkins');
  await Hive.openBox('settings');
  
  // Inicializar notificaciones
  await NotificationService().initialize();
  
  // Orientación vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PhrasesProvider()..init()),
        ChangeNotifierProvider(create: (_) => NotesProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Responsibility Mirror',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const MirrorScreen(),
    const CheckInScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Espejo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
