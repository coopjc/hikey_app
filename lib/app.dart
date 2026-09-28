import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'config/api_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/hike_controller.dart';
import 'controllers/location_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/hike_service.dart';
import 'services/location_service.dart';
import 'services/token_storage.dart';
import 'theme/hikey_theme.dart';

class HikeyApp extends StatefulWidget {
  const HikeyApp({super.key});

  @override
  State<HikeyApp> createState() => _HikeyAppState();
}

class _HikeyAppState extends State<HikeyApp> {
  late final TokenStorage _tokenStorage;

  late final ApiClient _apiClient;

  late final AuthService _authService;
  late final AuthController _authController;

  late final HikeService _hikeService;
  late final HikeController _hikeController;

  late final LocationService _locationService;
  late final LocationController _locationController;

  @override
  void initState() {
    super.initState();

    _tokenStorage = TokenStorage();

    _apiClient = ApiClient(tokenStorage: _tokenStorage);

    _authService = AuthService(
      apiClient: _apiClient,
      tokenStorage: _tokenStorage,
    );

    _authController = AuthController(authService: _authService);
    _hikeService = HikeService(apiClient: _apiClient);
    _hikeController = HikeController(hikeService: _hikeService);
    _locationService = const LocationService();
    _locationController = LocationController(locationService: _locationService);

    _apiClient.onUnauthorized = () {
      if (_authController.isAuthenticated) _authController.logout();
    };

    _authController.loadSession();

    _locationController.startTracking();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _hikeController.dispose();
    _authController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),

        Provider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<AuthController>.value(value: _authController),

        Provider<HikeService>.value(value: _hikeService),
        ChangeNotifierProvider<HikeController>.value(value: _hikeController),

        Provider<LocationService>.value(value: _locationService),
        ChangeNotifierProvider<LocationController>.value(
          value: _locationController,
        ),
      ],
      child: MaterialApp(
        title: 'Hikey',
        debugShowCheckedModeBanner: false,
        theme: HikeyTheme.light(),
        darkTheme: HikeyTheme.dark(),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    if (!ApiConfig.isConfigured) {
      return const SplashScreen(
        errorMessage: 'There was an error connecting to the server.',
      );
    }

    final AuthStatus status = context.select<AuthController, AuthStatus>(
      (AuthController auth) => auth.status,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (status) {
        AuthStatus.unknown => const SplashScreen(),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
