import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryPurple,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://i.pravatar.cc/300?img=12',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aarav Mehta',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'aarav.mehta@example.com',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Trip reminders (demo — not wired)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
