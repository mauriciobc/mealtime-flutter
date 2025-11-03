import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';

class ProfileInfoSection extends StatelessWidget {
  final Profile profile;

  const ProfileInfoSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              'Username',
              profile.username != null ? '@${profile.username}' : '-',
              Icons.alternate_email,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'E-mail',
              profile.email ?? '-',
              Icons.email,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Data de cadastro',
              profile.createdAt != null
                  ? dateFormat.format(profile.createdAt!)
                  : '-',
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Fuso horário',
              profile.timezone ?? '-',
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

