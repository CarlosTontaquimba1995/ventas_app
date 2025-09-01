import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'Español';
  final List<String> _languages = ['Inglés', 'Español', 'Francés'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferencias',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!), 
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Activar Notificaciones',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Modo Oscuro',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _darkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _darkMode = value;
                        // TODO: Implement theme change
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El tema se aplicará después de reiniciar')),
                        );
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Idioma',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        }
                      },
                      items: _languages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Soporte',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSupportOption(
                    context,
                    icon: Icons.help_outline,
                    title: 'Centro de Ayuda',
                    onTap: () {
                      // TODO: Implement help center
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Centro de ayuda disponible pronto!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSupportOption(
                    context,
                    icon: Icons.mail_outline,
                    title: 'Contáctanos',
                    onTap: () {
                      // TODO: Implement contact us
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Contáctanos disponible pronto!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSupportOption(
                    context,
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Ventas Pro',
                        applicationVersion: '1.0.0',
                        children: [
                          const Text('Una aplicación de pedidos al por mayor para negocios'),
                          const SizedBox(height: 8),
                          Text('© 2023 Ventas Pro', style: GoogleFonts.poppins()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
