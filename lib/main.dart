import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/cart_provider.dart';
import 'views/auth/login_view.dart';
import 'views/home/portal_view.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseMode = false;
  AuthService authService;
  DatabaseService dbService;

  try {
    // Attempt to initialize Firebase using our options.
    // If the project keys are placeholder/invalid or Firebase fails to connect,
    // we catch the exception and fall back to local Mock services.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Quick runtime test: if apiKey is our placeholder, we deliberately run mock services
    if (DefaultFirebaseOptions.currentPlatform.apiKey.contains('placeholder')) {
      throw Exception('Placeholder keys detected. Running in Demo Mode.');
    }

    authService = FirebaseAuthService();
    dbService = FirebaseDatabaseService();
    isFirebaseMode = true;
    print('Aura E-Commerce: Connected to Live Firebase');

    // Initialize Firebase Messaging
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      
      // Request permissions
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Set foreground options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Subscribe to topic
      await messaging.subscribeToTopic('all_users');
      print('Aura E-Commerce: FCM Messaging Initialized and Subscribed to topic "all_users"');
    } catch (fcmError) {
      print('Aura E-Commerce: FCM Messaging initialization failed: $fcmError');
    }

    // Run catalog migration to sync INR prices and new products to Firestore
    try {
      final prefs = await SharedPreferences.getInstance();
      const targetVersion = 3;
      final currentVersion = prefs.getInt('firestore_products_version') ?? 0;
      if (currentVersion < targetVersion) {
        print('Aura E-Commerce: Migrating Firestore products to Version $targetVersion...');
        final firestore = FirebaseFirestore.instance;
        for (var p in AppConstants.mockProducts) {
          await firestore.collection('products').doc(p.id).set(p.toMap());
        }
        await prefs.setInt('firestore_products_version', targetVersion);
        print('Aura E-Commerce: Firestore products migrated successfully.');
      }
    } catch (migError) {
      print('Aura E-Commerce: Product migration failed: $migError');
    }
  } catch (e) {
    print('Aura E-Commerce: Firebase init failed/skipped ($e). Falling back to Demo Mode.');
    authService = MockAuthService();
    dbService = MockDatabaseService();
    isFirebaseMode = false;
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => authService),
        Provider<DatabaseService>(create: (_) => dbService),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
      ],
      child: MyApp(isFirebaseMode: isFirebaseMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirebaseMode;

  const MyApp({
    Key? key,
    required this.isFirebaseMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.user,
      builder: (context, snapshot) {
        // Wait for session loads
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final user = snapshot.data;

        return MaterialApp(
          title: 'One Basket',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Automatic Light/Dark Mode
          debugShowCheckedModeBanner: false,
          home: user != null 
              ? PortalView(isFirebaseMode: isFirebaseMode)
              : LoginView(isFirebaseMode: isFirebaseMode),
        );
      },
    );
  }
}
