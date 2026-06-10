import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// App settings screen with toggleable preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationAlways = false;
  bool _surgeAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive ride updates and offers'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Background Location'),
            subtitle: const Text('Allow location access while app is closed'),
            value: _locationAlways,
            onChanged: (v) => setState(() => _locationAlways = v),
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Surge Price Alerts'),
            subtitle: const Text('Notify when surge pricing drops'),
            value: _surgeAlerts,
            onChanged: (v) => setState(() => _surgeAlerts = v),
            activeThumbColor: AppColors.primary,
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('App Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Source Code'),
            subtitle: const Text('github.com/IndieHub25/Price-Pilot'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licenses'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
              );
            },
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            title: const Text(
              'Clear Search History',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
