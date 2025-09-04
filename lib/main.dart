import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize auth service
    final authService = AuthService();
    
    // Check if user is already logged in
    final isLoggedIn = await authService.isLoggedIn();
    
    runApp(
      MultiProvider(
        providers: [
          // Cart Service Provider
          ChangeNotifierProvider(
            create: (_) => CartService()..loadCart(),
          ),
          // Auth Service Provider
          Provider<AuthService>.value(value: authService),
        ],
        child: WholesaleApp(isLoggedIn: isLoggedIn),
      ),
    );
  } catch (e) {
    // If there's any error during initialization, show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
    rethrow;
  }
}

class WholesaleApp extends StatefulWidget {
  final bool isLoggedIn;
  
  const WholesaleApp({super.key, required this.isLoggedIn});

  @override
  State<WholesaleApp> createState() => _WholesaleAppState();
}

class _WholesaleAppState extends State<WholesaleApp> {
  @override
  void initState() {
    super.initState();
    debugPrint('App started. User is ${widget.isLoggedIn ? 'logged in' : 'not logged in'}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deposito Peguche',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      locale: const Locale('es', 'ES'),
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: widget.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order-confirmation') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderNumber: args['orderNumber'],
              estimatedDelivery: args['estimatedDelivery'],
              totalAmount: args['totalAmount'],
            ),
          );
        }
        return null;
      },
    );
  }
}
