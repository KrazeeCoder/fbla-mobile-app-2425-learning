import 'package:flutter/material.dart';
import '/auth_utility.dart';
import 'signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '/security.dart';
import '../coach_marks/showcase_provider.dart';
import 'package:fbla_mobile_2425_learning_app/widgets/custom_app_bar.dart';

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
  final TextEditingController _profilePicUrlController =
  TextEditingController();

  bool isLoading = false;
  bool stayOnTrack = false;
  double fontSize = 14;
  int currentXP = 0;
  int currentLevel = 0;
  String profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final settings = doc['settings'] ?? {};

    setState(() {
      currentLevel = doc['currentLevel'] ?? 0;
      currentXP = doc['currentXP'] ?? 0;
      stayOnTrack = settings['stayOnTrack'] ?? false;
      fontSize = (settings['fontSize'] ?? 14).toDouble();
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
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      await _authService.updateUserProfile(
        uid: user.uid,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        profilePic: _profilePicUrlController.text.trim(),
      );

      await _firestore.collection('users').doc(user.uid).update({
        'settings.stayOnTrack': stayOnTrack,
        'settings.fontSize': fontSize,
      });

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
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _profilePicUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(), // ✅ Add your custom app bar

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
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profilePicUrl.isNotEmpty
                            ? NetworkImage(profilePicUrl)
                            : const AssetImage(
                            'assets/default_avatar.png')
                        as ImageProvider,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.deepPurple),
                        onPressed: _editProfilePicture,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email (read-only)
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    style: TextStyle(color: Colors.grey.shade700),
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
                  const SizedBox(height: 20),

                  // XP & Level (Read-Only Display)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        label: Text("Level: $currentLevel"),
                        avatar: const Icon(Icons.star,
                            color: Colors.amber),
                      ),
                      Chip(
                        label: Text("XP: $currentXP"),
                        avatar: const Icon(Icons.flash_on,
                            color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stay On Track Toggle
                  SwitchListTile(
                    title: const Text("Stay On Track"),
                    value: stayOnTrack,
                    onChanged: (val) =>
                        setState(() => stayOnTrack = val),
                    activeColor: Colors.deepPurple,
                  ),
                  const SizedBox(height: 10),

                  // Font Size Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Font Size",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        min: 10,
                        max: 24,
                        divisions: 7,
                        label: fontSize.toStringAsFixed(0),
                        value: fontSize,
                        onChanged: (val) =>
                            setState(() => fontSize = val),
                        activeColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add a section for tutorials
                  ListTile(
                    title: const Text('App Tutorial'),
                    subtitle: const Text('Reset the app tutorial'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await Provider.of<ShowcaseProvider>(context,
                                listen: false)
                            .resetShowcase();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
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

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
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
                        side:
                        const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
