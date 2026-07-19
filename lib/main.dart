import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';
import 'services/location_service.dart';
import 'services/price_alert_worker.dart';
import 'services/price_service.dart';
import 'widgets/theme_controller.dart';
// PriceAlertWorker is used via Provider; keep import for type safety

void main() {
  runApp(const SnapPriceApp());
}

class SnapPriceApp extends StatelessWidget {
  const SnapPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<LocationService>(create: (_) => LocationService()),
        ProxyProvider<LocationService, PriceService>(
          update: (_, loc, __) => PriceService(loc),
        ),
        ChangeNotifierProvider<HistoryService>(
          create: (_) => HistoryService()..load(),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (ctx) => ThemeController(ctx.read<AuthService>()),
        ),
        ProxyProvider<HistoryService, PriceAlertWorker>(
          update: (_, h, __) => PriceAlertWorker(h)..start(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'SnapPrice',
            debugShowCheckedModeBanner: false,
            themeMode: theme.mode,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            home: const _Bootstrap(),
          );
        },
      ),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool? _hasUser;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    // Detener el worker cuando la app se cierra
    try {
      context.read<PriceAlertWorker>().stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _check() async {
    final u = await context.read<AuthService>().currentUser();
    if (!mounted) return;
    setState(() => _hasUser = u != null);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasUser == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return _hasUser! ? const HomeScreen() : const RegisterScreen();
  }
}
