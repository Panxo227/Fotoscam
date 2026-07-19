import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_controller.dart';
import 'register_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeController>();
    final user = t.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.username),
              subtitle: Text(user.email),
            ),
            const Divider(),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: t.mode,
            onChanged: (m) => t.setMode(m!),
            title: const Text('Claro'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: t.mode,
            onChanged: (m) => t.setMode(m!),
            title: const Text('Oscuro'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: t.mode,
            onChanged: (m) => t.setMode(m!),
            title: const Text('Seguir sistema'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Color principal',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppTheme.presets.entries.map((e) {
                final selected = t.seed?.value == e.value.value;
                return ChoiceChip(
                  label: Text(e.key),
                  selected: selected,
                  selectedColor: e.value.withOpacity(0.3),
                  onSelected: (_) => t.setSeedColor(e.value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthService>().logout();
              await context.read<ThemeController>().load();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
