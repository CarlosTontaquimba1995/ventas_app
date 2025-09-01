import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Usuario',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'usuario@ejemplo.com',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.edit,
              title: 'Editar Perfil',
              onTap: () {
                // TODO: Implement edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Editar perfil estará disponible pronto!')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.history,
              title: 'Historial de Pedidos',
              onTap: () {
                // TODO: Implement order history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡El historial de pedidos estará disponible pronto!')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.location_on,
              title: 'Direcciones Guardadas',
              onTap: () {
                // TODO: Implement saved addresses
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Las direcciones guardadas estarán disponibles pronto!')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.credit_card,
              title: 'Métodos de Pago',
              onTap: () {
                // TODO: Implement payment methods
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Los métodos de pago estarán disponibles pronto!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
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
      ),
    );
  }
}
