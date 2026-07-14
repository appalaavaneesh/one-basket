import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:one_basket/main.dart';
import 'package:one_basket/services/auth_service.dart';
import 'package:one_basket/services/database_service.dart';
import 'package:one_basket/services/cart_provider.dart';

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => MockAuthService()),
          Provider<DatabaseService>(create: (_) => MockDatabaseService()),
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ],
        child: const MyApp(isFirebaseMode: false),
      ),
    );
  });
}
