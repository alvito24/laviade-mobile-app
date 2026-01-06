import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'order_history_screen.dart';
import 'edit_profile_screen.dart';
import 'address_list_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFIL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user?.profilePhotoUrl != null
                            ? NetworkImage(user!.profilePhotoUrl!)
                            : null,
                        child: user?.profilePhotoUrl == null
                            ? Text(
                                user?.initials ?? 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  // Phone (if available)
                  if (user?.phone != null && user!.phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.phone!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profil',
              subtitle: 'Ubah nama, telepon, dan lainnya',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan Saya',
              subtitle: 'Lihat riwayat pesanan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              subtitle: 'Produk yang kamu simpan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const WishlistScreen()),
                );
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Alamat Saya',
              subtitle: 'Kelola alamat pengiriman',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AddressListScreen(),
                  ),
                );
              },
            ),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {},
            ),

            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'LAVIADE',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 LAVIADE Fashion',
                );
              },
            ),

            const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

            // Logout
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Keluar',
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar?'),
                    content: const Text('Kamu yakin ingin keluar dari akun?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('BATAL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          authService.logout();
                        },
                        child: const Text(
                          'KELUAR',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
