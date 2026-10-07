import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/technician_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_main_layout.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedRole = prefs.getString('user_role');
  final savedName = prefs.getString('user_name');
  final savedPhone = prefs.getString('user_phone') ?? '';
  final savedEmail = prefs.getString('user_email');
  final savedToken = prefs.getString('auth_token');

  User? restoredUser;
  if (savedRole != null && savedName != null) {
    restoredUser = User(
      id: prefs.getInt('user_id') ?? 0,
      name: savedName,
      phone: savedPhone,
      email: savedEmail,
      role: savedRole,
      address: prefs.getString('user_address'),
      token: savedToken,
    );
    if (savedToken != null) {
      ApiService.authToken = savedToken;
    }
  }

  runApp(InstafixCustomerApp(restoredUser: restoredUser));
}

class InstafixCustomerApp extends StatelessWidget {
  final User? restoredUser;
  const InstafixCustomerApp({super.key, this.restoredUser});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(initialUser: restoredUser)),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Instafix – Doorstep Repair',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authProvider.isAuthenticated &&
                    authProvider.currentUser?.isCustomer == true
                ? const CustomerMainLayout()
                : const LoginScreen(lockedRole: 'customer'),
          );
        },
      ),
    );
  }
}
