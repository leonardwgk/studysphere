import 'package:flutter/material.dart';
import 'package:studysphere_app/features/auth/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GENERAL SECTION ---
              // const Text(
              //   'General',
              //   style: TextStyle(color: Colors.grey, fontSize: 14),
              // ),
              // const SizedBox(height: 10),
              // _buildSettingsGroup([
              //   _buildSettingsItem(
              //     icon: Icons.security,
              //     iconColor: Colors.blue,
              //     title: 'Privacy',
              //     onTap: () {},
              //   ),
              //   _buildSettingsItem(
              //     icon: Icons.notifications,
              //     iconColor: Colors.blue,
              //     title: 'Notifications',
              //     onTap: () {},
              //   ),
              //   _buildSettingsItem(
              //     icon: Icons.language,
              //     iconColor: Colors.blue,
              //     title: 'Language',
              //     onTap: () {},
              //   ),
              //   _buildSettingsItem(
              //     icon: Icons.star,
              //     iconColor: Colors.blue,
              //     title: 'Rate Us',
              //     onTap: () {},
              //   ),
              //   _buildSettingsItem(
              //     icon: Icons.error_outline,
              //     iconColor: Colors.blue,
              //     title: 'Terms and Policies',
              //     onTap: () {},
              //   ),
              //   _buildSettingsItem(
              //     icon: Icons.help_outline,
              //     iconColor: Colors.blue,
              //     title: 'Help',
              //     showDivider: false, // Item terakhir tidak perlu garis pembatas
              //     onTap: () {},
              //   ),
              // ]),

              // const SizedBox(height: 25),

              // --- ACCOUNT SECTION ---
              const Text(
                'Account',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSettingsGroup([
                // _buildSettingsItem(
                //   icon: Icons.delete,
                //   iconColor: Colors.blue, // Sesuai gambar (icon biru)
                //   title: 'Delete account',
                //   onTap: () {
                //     // Aksi hapus akun
                //   },
                // ),
                _buildSettingsItem(
                  icon: Icons.logout, // Icon logout panah keluar
                  iconColor: Colors.blue,
                  title: 'Logout',
                  showDivider: false,
                  onTap: () async {
                    // Panggil fungsi logout dan kembali ke login
                    final authService = AuthService();
                    await authService.signOut();
                    // Biasanya auth stream akan otomatis mengarahkan ke login page
                    // Tapi kita juga bisa pop semua route
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk mengelompokkan item settings dalam container rounded abu-abu
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Warna background group
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Widget untuk satu baris item settings
  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                // Icon di kiri
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 15),
                
                // Teks Judul
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                // Panah kanan
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
          // Garis pembatas (Divider) kecuali item terakhir
          if (showDivider)
            const Divider(height: 1, indent: 55, endIndent: 15, color: Colors.black12),
        ],
      ),
    );
  }
}