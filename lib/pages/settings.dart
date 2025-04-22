import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../managers/coach_marks/showcase_keys.dart';
import '../services/auth_service.dart';
import 'signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/security.dart';
import '../managers/coach_marks/showcase_provider.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';
import '../services/settings_service.dart';
import '../services/xp_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _profilePicUrlController =
      TextEditingController();

  bool isLoading = false;
  int currentXP = 0;
  int currentLevel = 0;
  String profilePicUrl = '';
  String? usernameError;

  final RegExp usernameRegex = RegExp(r"^[a-zA-Z0-9_]{3,20}$");

  @override
  void initState() {
    super.initState();
    _loadUserDetails();

    // Add post-frame callback to listen for XP updates after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final xpManager = Provider.of<XPService>(context, listen: false);
      xpManager.addListener(_updateXPAndLevel);
    });
  }

  void _updateXPAndLevel() {
    if (!mounted) return;
    final xpManager = Provider.of<XPService>(context, listen: false);
    setState(() {
      currentXP = xpManager.currentXP;
      currentLevel = xpManager.currentLevel;
    });
  }

  Future<void> _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    setState(() {
      _usernameController.text = doc['username'] ?? '';
    });

    final decrypted = await decryptUserDetails(user.uid);
    if (decrypted != null) {
      setState(() {
        _emailController.text = decrypted['email'] ?? '';
        _firstNameController.text = decrypted['firstname'] ?? '';
        _lastNameController.text = decrypted['lastname'] ?? '';
        profilePicUrl = decrypted['profilePic'] ?? '';
        _profilePicUrlController.text = profilePicUrl;
      });
    }

    // Get XP and level from XPManager
    final xpManager = Provider.of<XPService>(context, listen: false);
    setState(() {
      currentXP = xpManager.currentXP;
      currentLevel = xpManager.currentLevel;
    });
  }

  bool _validateUsernameFormat(String username) {
    if (username.isEmpty) {
      setState(() => usernameError = "Username cannot be empty");
      return false;
    }

    if (!usernameRegex.hasMatch(username)) {
      setState(() => usernameError =
          "3-20 characters, letters, numbers, and underscores only");
      return false;
    }

    setState(() => usernameError = null);
    return true;
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // If username hasn't changed, no need to check
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final currentUsername = doc.data()?['username'];
    if (username == currentUsername) return true;

    final isUsernameTaken = await _authService.isUsernameTaken(username);
    if (isUsernameTaken) {
      setState(() => usernameError = "Username is already taken");
      return false;
    }

    setState(() => usernameError = null);
    return true;
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final username = _usernameController.text.trim();
    if (!_validateUsernameFormat(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username format')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final isUsernameAvailable = await _checkUsernameAvailability(username);
      if (!isUsernameAvailable) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username is already taken')),
        );
        return;
      }

      await _authService.updateUserProfile(
        uid: user.uid,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        profilePic: _profilePicUrlController.text.trim(),
        username: username,
      );

      // No need to update settings in Firestore here, the provider handles it

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated')),
      );
    } catch (e) {
      print("❌ Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error updating profile: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _editProfilePicture() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Profile Picture URL"),
        content: TextField(
          controller: _profilePicUrlController,
          decoration: const InputDecoration(
            labelText: "Profile Picture URL",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                profilePicUrl = _profilePicUrlController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logoutUser();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Remove listener from XPManager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final xpManager = Provider.of<XPService>(context, listen: false);
        xpManager.removeListener(_updateXPAndLevel);
      }
    });

    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _profilePicUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsService>(context);

    return Scaffold(
      body: isLoading || settingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Showcase(
              key: ShowcaseKeys.settingsScreenKey,
              title: 'Settings & Preferences',
              description:
                  'Customize your app experience here! Update your profile, adjust learning preferences, and manage your account settings.',
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.0,
              ),
              descTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
              tooltipBackgroundColor: Colors.green.shade700,
              overlayColor: Colors.black,
              overlayOpacity: 0.7,
              tooltipPadding: const EdgeInsets.all(16.0),
              targetPadding: const EdgeInsets.all(8.0),
              targetShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              tooltipBorderRadius: BorderRadius.circular(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomAppBar(),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Section
                          _buildSectionHeader("Profile"),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Profile Picture
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: profilePicUrl
                                                  .isNotEmpty
                                              ? NetworkImage(profilePicUrl)
                                              : const AssetImage(
                                                      'assets/default_avatar.png')
                                                  as ImageProvider,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.deepPurple,
                                                size: 20),
                                            onPressed: _editProfilePicture,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Email (read-only)
                                  TextFormField(
                                    controller: _emailController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
                                    ),
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 16),

                                  // Username Field
                                  TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      errorText: usernameError,
                                      prefixIcon:
                                          const Icon(Icons.alternate_email),
                                      border: OutlineInputBorder(),
                                      helperText:
                                          'Your unique username for leaderboards',
                                    ),
                                    onChanged: (value) {
                                      if (usernameError != null) {
                                        setState(() => usernameError = null);
                                      }
                                      _validateUsernameFormat(value);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Name Fields
                                  TextField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      prefixIcon: Icon(Icons.person_outline),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Progress Section
                          _buildSectionHeader("Progress"),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildProgressItem(
                                    icon: Icons.star,
                                    iconColor: Colors.amber,
                                    label: "Level",
                                    value:
                                        "${Provider.of<XPService>(context).currentLevel}",
                                  ),
                                  const SizedBox(width: 20),
                                  _buildProgressItem(
                                    icon: Icons.flash_on,
                                    iconColor: Colors.orange,
                                    label: "XP",
                                    value:
                                        "${Provider.of<XPService>(context).currentXP}",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // App Preferences Section
                          _buildSectionHeader("App Preferences"),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                // Stay On Track Toggle
                                SwitchListTile(
                                  title: const Text("Stay On Track"),
                                  subtitle: const Text(
                                      "When on, you’ll follow topics in order. Turn off to explore freely."),
                                  value: settingsProvider.stayOnTrack,
                                  onChanged: (val) =>
                                      settingsProvider.updateStayOnTrack(val),
                                  activeColor: Colors.deepPurple,
                                ),
                                const Divider(height: 1),

                                // Font Size Slider
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Subtopic Font Size",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text("A",
                                              style: TextStyle(fontSize: 12)),
                                          Expanded(
                                            child: Slider(
                                              min: 10,
                                              max: 24,
                                              divisions: 7,
                                              label:
                                                  "${settingsProvider.fontSize.toInt()}",
                                              value: settingsProvider.fontSize,
                                              onChanged: (val) =>
                                                  settingsProvider
                                                      .updateFontSize(val),
                                              activeColor: Colors.deepPurple,
                                            ),
                                          ),
                                          const Text("A",
                                              style: TextStyle(fontSize: 24)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // App Tutorial
                                ListTile(
                                  leading: const Icon(Icons.help_outline,
                                      color: Colors.deepPurple),
                                  title: const Text('App Tutorial'),
                                  subtitle:
                                      const Text('Reset the app tutorial'),
                                  trailing: OutlinedButton(
                                    onPressed: () async {
                                      await Provider.of<ShowcaseService>(
                                              context,
                                              listen: false)
                                          .resetShowcase();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Tutorial reset! It will appear next time you open the app.'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Reset'),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Account Actions Section
                          _buildSectionHeader("Account Actions"),
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 30),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: const Text("Save Changes",
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Logout
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _showLogoutDialog,
                                      icon: const Icon(Icons.logout),
                                      label: const Text("Logout"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        side: const BorderSide(
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
