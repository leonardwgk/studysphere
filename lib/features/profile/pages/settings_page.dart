import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studysphere_app/features/profile/providers/settings_provider.dart';
import 'package:studysphere_app/features/study_tracker/services/notification_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

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
            Navigator.pop(context);
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
              const Text(
                'General',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSettingsGroup([
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.blue,
                  title: 'Notifications',
                  onTap: () => _showNotificationSettings(context),
                ),
                _buildSettingsItem(
                  icon: Icons.star_outline,
                  iconColor: Colors.amber,
                  title: 'Rate Us',
                  onTap: () => _showRateUsDialog(context),
                ),
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  iconColor: Colors.teal,
                  title: 'Help & Support',
                  showDivider: false,
                  onTap: () => _showHelpPage(context),
                ),
              ]),

              const SizedBox(height: 25),

              // --- LEGAL SECTION ---
              const Text(
                'Legal',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSettingsGroup([
                _buildSettingsItem(
                  icon: Icons.description_outlined,
                  iconColor: Colors.indigo,
                  title: 'Terms of Service',
                  onTap: () => _showLegalPage(
                    context,
                    'Terms of Service',
                    _termsOfServiceText,
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.purple,
                  title: 'Privacy Policy',
                  onTap: () => _showLegalPage(
                    context,
                    'Privacy Policy',
                    _privacyPolicyText,
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  iconColor: Colors.blue,
                  title: 'About StudySphere',
                  showDivider: false,
                  onTap: () => _showAboutPage(context),
                ),
              ]),

              const SizedBox(height: 25),

              // --- ACCOUNT SECTION ---
              const Text(
                'Account',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSettingsGroup([
                Consumer<SettingsProvider>(
                  builder: (context, viewModel, child) {
                    return _buildSettingsItem(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Logout',
                      showDivider: false,
                      onTap: () => viewModel.logout(context),
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // --- NOTIFICATION SETTINGS ---
  void _showNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _NotificationSettingsPage(),
      ),
    );
  }

  // --- RATE US ---
  void _showRateUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enjoying StudySphere?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 60),
            SizedBox(height: 12),
            Text(
              'If you enjoy using StudySphere, we\'d love to hear your feedback! '
              'Your rating helps us improve and reach more students.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your support! ❤️'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  // --- HELP PAGE ---
  void _showHelpPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _HelpPage()),
    );
  }

  // --- LEGAL PAGE ---
  void _showLegalPage(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LegalPage(title: title, content: content),
      ),
    );
  }

  // --- ABOUT PAGE ---
  void _showAboutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AboutPage()),
    );
  }

  // Widget untuk mengelompokkan item settings dalam container rounded abu-abu
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
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
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 15),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 55,
              endIndent: 15,
              color: Colors.black12,
            ),
        ],
      ),
    );
  }

  // --- LEGAL TEXT CONSTANTS ---
  static const String _termsOfServiceText = '''
Terms of Service

Last updated: February 2026

1. Acceptance of Terms
By accessing or using StudySphere, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.

2. Description of Service
StudySphere is a study productivity and social learning application that provides Pomodoro-based study timers, study session tracking, social sharing of study sessions, and calendar-based study planning.

3. User Accounts
You must create an account to use StudySphere. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

4. Acceptable Use
You agree not to:
• Use the service for any unlawful purpose
• Upload content that is offensive, harmful, or violates the rights of others
• Attempt to interfere with or disrupt the service
• Impersonate another person or entity

5. User Content
You retain ownership of the content you post. By sharing study sessions and posts, you grant StudySphere a non-exclusive license to display that content within the application.

6. Privacy
Your use of StudySphere is also governed by our Privacy Policy. Please review it to understand how we collect and use your information.

7. Modifications
We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.

8. Disclaimer
StudySphere is provided "as is" without warranties of any kind. We do not guarantee uninterrupted or error-free service.

9. Contact
If you have questions about these terms, please contact us through the Help & Support section in the app.
''';

  static const String _privacyPolicyText = '''
Privacy Policy

Last updated: February 2026

1. Information We Collect
• Account information: email address and display name
• Study data: session durations, subjects, and study patterns
• Posts: images and text you choose to share
• Device information: device type and OS version for app compatibility

2. How We Use Your Information
• To provide and improve the StudySphere service
• To display your study progress and shared sessions
• To connect you with other learners in the community
• To send study-related notifications (with your permission)

3. Data Storage
Your data is stored securely using Firebase services by Google. Study sessions and account data are stored in Cloud Firestore, and images are stored in Firebase Storage.

4. Data Sharing
We do not sell or share your personal information with third parties. Your study sessions are only visible to your connections within the app as per your sharing preferences.

5. Notifications
StudySphere may send local notifications for study timer alerts. You can control notification permissions in your device settings or within the app.

6. Data Retention
Your data is retained as long as your account is active. You can request deletion of your account and associated data at any time.

7. Children's Privacy
StudySphere is designed for educational purposes but is not specifically directed at children under 13. We do not knowingly collect information from children under 13.

8. Changes to Privacy Policy
We may update this Privacy Policy from time to time. We will notify users of significant changes through the app.

9. Contact
For privacy-related inquiries, please reach out through the Help & Support section in the app.
''';
}

// --- NOTIFICATION SETTINGS PAGE ---
class _NotificationSettingsPage extends StatefulWidget {
  const _NotificationSettingsPage();

  @override
  State<_NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<_NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final ns = NotificationService();
    await ns.initialize();
    if (mounted) {
      setState(() {
        _notificationsEnabled = ns.enabled;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: Colors.blue, size: 26),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Study Timer Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Switch(
                          value: _loading ? true : _notificationsEnabled,
                          onChanged: _loading
                              ? null
                              : (val) async {
                                  setState(() => _notificationsEnabled = val);
                                  final ns = NotificationService();
                                  await ns.setEnabled(val);
                                  if (val) {
                                    await ns.requestPermission();
                                  }
                                },
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'When enabled, you will receive notifications showing your '
                'study timer progress with pause/resume controls. '
                'Notifications appear when you start a Pomodoro session.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'If notifications are not appearing, make sure you have granted '
                'notification permissions in your device settings.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELP PAGE ---
class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How does the Pomodoro timer work?',
              'The Pomodoro technique breaks study time into focused intervals '
                  '(typically 25 minutes) separated by short breaks (5 minutes). '
                  'After 4 focus sessions, you get a longer break (15 minutes). '
                  'You can customize these durations in the timer settings.',
            ),
            _buildFaqItem(
              'How do I share my study sessions?',
              'After completing a Pomodoro session, tap "Finish" and you will be '
                  'taken to the Share Session page. You can add a title, description, '
                  'photo, and select the subject category before posting.',
            ),
            _buildFaqItem(
              'Why am I not receiving notifications?',
              'Make sure notification permissions are enabled for StudySphere '
                  'in your device settings. On Android 13+, you need to explicitly '
                  'grant notification permission when prompted. You can also check '
                  'Settings > Notifications in the app.',
            ),
            _buildFaqItem(
              'How do I change my profile?',
              'Go to the "You" tab and tap "Edit Profile" to update your '
                  'display name, bio, and profile picture.',
            ),
            _buildFaqItem(
              'Can I use StudySphere offline?',
              'The Pomodoro timer works offline, but sharing sessions and '
                  'viewing the social feed requires an internet connection.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Need More Help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.email_outlined,
                      color: Colors.blue, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any questions or issues, feel free to reach '
                    'out to our support team.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'support@studysphere.app',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// --- LEGAL PAGE ---
class _LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const _LegalPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          content,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// --- ABOUT PAGE ---
class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.blue,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'StudySphere',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Focus Deeply. Connect Socially. Grow Daily.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About the App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'StudySphere is a study productivity app designed to help '
                    'students focus better using the Pomodoro technique, track '
                    'their study progress, and connect with fellow learners.\n\n'
                    'Built with Flutter, Firebase, and a passion for education.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                      Icons.timer, 'Pomodoro Timer with customizable durations'),
                  _buildFeatureItem(
                      Icons.bar_chart, 'Study session tracking & statistics'),
                  _buildFeatureItem(
                      Icons.people, 'Social feed to share study sessions'),
                  _buildFeatureItem(
                      Icons.calendar_month, 'Calendar for study planning'),
                  _buildFeatureItem(
                      Icons.notifications, 'Smart study notifications'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© 2026 StudySphere. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
