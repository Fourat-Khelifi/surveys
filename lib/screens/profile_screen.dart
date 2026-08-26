import 'package:flutter/material.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/constants/motion.dart';
import 'package:surveys/core/models/user_profile.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/services/survey_service.dart';
import 'package:surveys/shared/widgets/app_bar.dart';
import 'package:surveys/shared/widgets/button.dart';
import 'package:surveys/shared/widgets/text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final SurveyService _surveyService = SurveyService();

  UserProfile? _profile;
  int _points = 0;
  int _completed = 0;

  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      // Started together, awaited separately, so the name still shows if the
      // survey read fails and vice versa.
      final profileRequest = _authService.fetchProfile();
      final completedRequest = _surveyService.fetchCompletedSurveys();

      final profile = await profileRequest;
      final completed = await completedRequest;

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _completed = completed.length;
        _points = SurveyService.pointsFrom(completed);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _authService.signOut();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editName() async {
    final profile = _profile;
    if (profile == null) return;

    final controller = TextEditingController(text: profile.fullName ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.authCard,
        title: const Text('Your name'),
        content: AppTextField(
          hint: 'Full name',
          controller: controller,
          showCounter: false,
          maxLength: 80,
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (saved == null || !mounted) return;

    try {
      final updated = await _authService.updateFullName(saved);
      if (!mounted) return;
      setState(() => _profile = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadFailed && _profile == null
              ? _buildError()
              : _buildProfile(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Couldn't load your profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your connection and try again.',
            style: TextStyle(fontSize: 14, color: AppColors.textSubtle),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(text: 'Try again', onPressed: _load),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final profile = _profile!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.black,
            child: Text(
              profile.initials,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          // Crossfades when the name changes, so a rename lands rather than
          // snapping.
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.quick),
            child: Text(
              profile.displayName,
              key: ValueKey(profile.displayName),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: Text(
            profile.email,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ),

        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(child: _buildStat('$_points', 'Points earned')),
            const SizedBox(width: 12),
            Expanded(child: _buildStat('$_completed', 'Surveys completed')),
          ],
        ),

        const SizedBox(height: 28),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),

        _buildInfoRow(
          Icons.person_outline,
          'Name',
          profile.fullName ?? 'Not set yet',
          onTap: _editName,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.email_outlined, 'Email', profile.email),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: _isSigningOut ? 'Signing out...' : 'Sign Out',
            type: ButtonType.outlined,
            onPressed: _isSigningOut ? null : _signOut,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSubtle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}
