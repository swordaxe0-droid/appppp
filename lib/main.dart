import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

String _buildPrivateRoomId(String a, String b) {
  return (a.compareTo(b) < 0) ? '${a}_$b' : '${b}_$a';
}

// Theme Data
class AppThemes {
  static final Map<String, ThemeData> themes = {
    'Indigo': _createTheme(const Color(0xFF6366F1), 'Indigo'),
    'Purple': _createTheme(const Color(0xFF9333EA), 'Purple'),
    'Pink': _createTheme(const Color(0xFFEC4899), 'Pink'),
    'Red': _createTheme(const Color(0xFFEF4444), 'Red'),
    'Orange': _createTheme(const Color(0xFFF97316), 'Orange'),
    'Green': _createTheme(const Color(0xFF10B981), 'Green'),
    'Blue': _createTheme(const Color(0xFF3B82F6), 'Blue'),
    'Teal': _createTheme(const Color(0xFF14B8A6), 'Teal'),
  };

  // Background Themes
  static final Map<String, BackgroundTheme> backgroundThemes = {
    'None': BackgroundTheme(
      name: 'None',
      colors: [],
      pattern: BackgroundPattern.solid,
    ),
    'Ocean': BackgroundTheme(
      name: 'Ocean',
      colors: [Color(0xFF006994), Color(0xFF0090C1), Color(0xFF00B4D8)],
      pattern: BackgroundPattern.gradient,
    ),
    'Sunset': BackgroundTheme(
      name: 'Sunset',
      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
      pattern: BackgroundPattern.gradient,
    ),
    'Forest': BackgroundTheme(
      name: 'Forest',
      colors: [Color(0xFF0F3D0E), Color(0xFF2D6A4F), Color(0xFF52B788)],
      pattern: BackgroundPattern.gradient,
    ),
    'Galaxy': BackgroundTheme(
      name: 'Galaxy',
      colors: [Color(0xFF0F0E17), Color(0xFF1A1D3A), Color(0xFF3E1F47)],
      pattern: BackgroundPattern.gradient,
    ),
    'Aurora': BackgroundTheme(
      name: 'Aurora',
      colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFFF6B9D)],
      pattern: BackgroundPattern.gradient,
    ),
  };

  static ThemeData _createTheme(Color seedColor, String name) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData _createDarkTheme(Color seedColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class CallJoinPage extends StatelessWidget {
  final String roomId;
  final String callerName;
  final String callType;
  const CallJoinPage({super.key, required this.roomId, required this.callerName, required this.callType});

  String _buildUrl() {
    final base = 'https://meet.jit.si/$roomId';
    if (callType == 'audio') {
      return '$base#config.startWithVideoMuted=true';
    }
    return base;
  }

  Future<void> _join() async {
    final url = Uri.parse(_buildUrl());
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Call'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(callType == 'audio' ? Icons.call : Icons.videocam, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(callType == 'audio' ? 'Audio Call' : 'Video Call', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              SelectableText(roomId),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _join,
                icon: const Icon(Icons.launch),
                label: const Text('Join Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundTheme {
  final String name;
  final List<Color> colors;
  final BackgroundPattern pattern;

  BackgroundTheme({
    required this.name,
    required this.colors,
    required this.pattern,
  });
}

enum BackgroundPattern {
  solid,
  gradient,
  animated,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedTheme = 'Indigo';
  String _selectedBackground = 'None';

  void _changeTheme(String themeName) {
    setState(() => _selectedTheme = themeName);
  }

  void _changeBackground(String backgroundName) {
    setState(() => _selectedBackground = backgroundName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sikder Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.themes[_selectedTheme],
      darkTheme: AppThemes._createDarkTheme(
        AppThemes.themes[_selectedTheme]!.colorScheme.primary,
      ),
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        onThemeChange: _changeTheme,
        currentTheme: _selectedTheme,
        onBackgroundChange: _changeBackground,
        currentBackground: _selectedBackground,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Function(String) onThemeChange;
  final String currentTheme;
  final Function(String) onBackgroundChange;
  final String currentBackground;

  const AuthWrapper({
    super.key,
    required this.onThemeChange,
    required this.currentTheme,
    required this.onBackgroundChange,
    required this.currentBackground,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                return HomePage(
                  onThemeChange: widget.onThemeChange,
                  currentTheme: widget.currentTheme,
                  onBackgroundChange: widget.onBackgroundChange,
                  currentBackground: widget.currentBackground,
                );
              }

              return ProfileSetupPage(user: snapshot.data!);
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}

// Login Page with Enhanced Animations
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);

    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.elasticOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        try {
          await _auth.signInWithPopup(GoogleAuthProvider());
        } on FirebaseAuthException catch (e) {
          // Fallback for browsers/environments where popups are blocked or not supported
          if (e.code == 'popup-blocked' ||
              e.code == 'popup-closed-by-user' ||
              e.code == 'operation-not-supported-in-this-environment') {
            await _auth.signInWithRedirect(GoogleAuthProvider());
            return;
          } else {
            rethrow;
          }
        }
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                stops: [
                  0.0 + (_backgroundController.value * 0.1),
                  0.3 + (_backgroundController.value * 0.1),
                  0.6 + (_backgroundController.value * 0.1),
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _logoRotation.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 100,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Animated Text
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textOpacity,
                            child: Column(
                              children: [
                        Text(
                          'Welcome to',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sikder Chat App',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                                const SizedBox(height: 24),
                                Text(
                                  'Connect • Chat • Share',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        letterSpacing: 4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Animated Button
                        ScaleTransition(
                          scale: _buttonScale,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : ElevatedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: const Icon(Icons.login, size: 28),
                                  label: const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 40),

                        // Feature hints with fade animation
                        FadeTransition(
                          opacity: _textOpacity,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureChip(Icons.groups, 'Group Chat'),
                              _buildFeatureChip(Icons.message, 'Private Chat'),
                              _buildFeatureChip(Icons.phone, 'Voice Calls'),
                              _buildFeatureChip(Icons.videocam, 'Video Calls'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Setup Page
class ProfileSetupPage extends StatefulWidget {
  final User user;

  const ProfileSetupPage({super.key, required this.user});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('users').doc(widget.user.uid).set({
        'name': _nameController.text.trim(),
        'dateOfBirth': Timestamp.fromDate(_selectedDate!),
        'email': widget.user.email,
        'photoURL': widget.user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'status': 'online',
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
        child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.user.photoURL != null)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(widget.user.photoURL!),
                      ),
                    ),
                  if (widget.user.photoURL != null) const SizedBox(height: 24),
                  Text(
                    'Welcome, ${widget.user.email}!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete your profile to continue',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select your date of birth'
                            : DateFormat('MMM dd, yyyy')
                                .format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Page with Screen Switcher
class HomePage extends StatefulWidget {
  final Function(String) onThemeChange;
  final String currentTheme;
  final Function(String) onBackgroundChange;
  final String currentBackground;

  const HomePage({
    super.key,
    required this.onThemeChange,
    required this.currentTheme,
    required this.onBackgroundChange,
    required this.currentBackground,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _currentScreen = 'Global'; // Global, Users
  late AnimationController _switcherController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _switcherController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _switcherController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _switcherController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  void _showScreenSwitcher() {
    _switcherController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Switch Screen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildScreenOption(
              icon: Icons.public,
              title: 'Global Chat',
              subtitle: 'Chat with everyone',
              color: Colors.blue,
              isSelected: _currentScreen == 'Global',
              onTap: () {
                setState(() => _currentScreen = 'Global');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildScreenOption(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'Browse all users',
              color: Colors.green,
              isSelected: _currentScreen == 'Users',
              onTap: () {
                setState(() => _currentScreen = 'Users');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => _switcherController.reverse());
  }

  Widget _buildScreenOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: RotationTransition(
          turns: _rotationAnimation,
          child: IconButton(
            icon: const Icon(Icons.apps_rounded, size: 28),
            onPressed: _showScreenSwitcher,
            tooltip: 'Switch Screen',
          ),
        ),
        title: Row(
          children: [
            Icon(
              _currentScreen == 'Global' ? Icons.public : Icons.people,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(_currentScreen),
          ],
        ),
        actions: [
          if (_currentScreen != 'Users')
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon!')),
                );
              },
            ),
          if (_currentScreen == 'Users')
            IconButton(
              icon: const Icon(Icons.groups),
              onPressed: () {
                final uid = _auth.currentUser?.uid ?? '';
                final roomId = 'group_${uid}_${DateTime.now().millisecondsSinceEpoch}';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallJoinPage(
                      roomId: roomId,
                      callerName: _auth.currentUser?.displayName ?? 'Caller',
                      callType: 'video',
                    ),
                  ),
                );
              },
              tooltip: 'Start Group Call',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'themes') {
                _showThemeSelector();
              } else if (value == 'background') {
                _showBackgroundSelector();
              } else if (value == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'themes',
                child: Row(
                  children: [
                    Icon(Icons.palette),
                    SizedBox(width: 12),
                    Text('Color Themes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'background',
                child: Row(
                  children: [
                    Icon(Icons.wallpaper),
                    SizedBox(width: 12),
                    Text('Backgrounds'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: _getBackgroundDecoration(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _currentScreen == 'Global'
              ? GlobalChatScreen(key: const ValueKey('global'))
              : UsersScreen(key: const ValueKey('users')),
        ),
      ),
    );
  }

  BoxDecoration? _getBackgroundDecoration() {
    final bgTheme = AppThemes.backgroundThemes[widget.currentBackground];
    if (bgTheme == null || bgTheme.colors.isEmpty) {
      return null;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bgTheme.colors,
      ),
    );
  }

  void _showBackgroundSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Background',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppThemes.backgroundThemes.keys.map((bgName) {
                final bgTheme = AppThemes.backgroundThemes[bgName]!;
                final isSelected = widget.currentBackground == bgName;
                return GestureDetector(
                  onTap: () {
                    widget.onBackgroundChange(bgName);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: bgTheme.colors.isNotEmpty
                          ? LinearGradient(colors: bgTheme.colors)
                          : null,
                      color: bgTheme.colors.isEmpty
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            bgName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: bgTheme.colors.isNotEmpty
                                  ? Colors.white
                                  : null,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppThemes.themes.keys.map((themeName) {
                final themeData = AppThemes.themes[themeName]!;
                final isSelected = widget.currentTheme == themeName;
                return GestureDetector(
                  onTap: () {
                    widget.onThemeChange(themeName);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeData.colorScheme.primary,
                          themeData.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: themeData.colorScheme.primary
                                    .withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          themeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Global Chat Screen (Separate page)
class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({super.key});

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final user = _auth.currentUser!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      await _firestore.collection('messages').add({
        'text': _messageController.text.trim(),
        'senderName': userData?['name'] ?? 'Unknown',
        'photoURL': user.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });

      _messageController.clear();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
            Text(
                        'No messages yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to start the conversation!',
                        style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
                );
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message =
                      messages[index].data() as Map<String, dynamic>;
                  final isMe = message['uid'] == _auth.currentUser!.uid;

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (index * 30)),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _MessageBubble(message: message, isMe: isMe),
                  );
                },
              );
            },
          ),
        ),
        _MessageInput(
          controller: _messageController,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

// Private Chats Screen
class PrivateChatsScreen extends StatelessWidget {
  const PrivateChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('privateChats')
          .where('participants', arrayContains: user.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No private chats yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to Users to start chatting privately',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index].data() as Map<String, dynamic>;
            final participants = List<String>.from(chat['participants']);
            final otherUserId =
                participants.firstWhere((id) => id != user.uid);

            return FutureBuilder<DocumentSnapshot>(
              future: firestore.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox.shrink();

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;
                final userName = userData?['name'] ?? 'Unknown User';
                final userPhoto = userData?['photoURL'] ?? '';
                final lastMessage = chat['lastMessage'] ?? '';
                final lastMessageTime = chat['lastMessageTime'] as Timestamp?;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: userPhoto.isNotEmpty
                          ? NetworkImage(userPhoto)
                          : null,
                      child: userPhoto.isEmpty
                          ? Text(userName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: lastMessageTime != null
                        ? Text(
                            _formatTime(lastMessageTime.toDate()),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateChatPage(
                            otherUserId: otherUserId,
                            otherUserName: userName,
                            otherUserPhoto: userPhoto,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

// Users Screen
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users =
            snapshot.data!.docs.where((doc) => doc.id != user.uid).toList();

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No other users yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Invite your friends to join!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            final userName = userData['name'] ?? 'Unknown User';
            final userEmail = userData['email'] ?? '';
            final userPhoto = userData['photoURL'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: userPhoto.isNotEmpty
                      ? NetworkImage(userPhoto)
                      : null,
                  child: userPhoto.isEmpty
                      ? Text(userName[0].toUpperCase())
                      : null,
                ),
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userEmail),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivateChatPage(
                              otherUserId: userId,
                              otherUserName: userName,
                              otherUserPhoto: userPhoto,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallJoinPage(
                              roomId: _buildPrivateRoomId(FirebaseAuth.instance.currentUser!.uid, userId),
                              callerName: user.displayName ?? userName,
                              callType: 'audio',
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallJoinPage(
                              roomId: _buildPrivateRoomId(FirebaseAuth.instance.currentUser!.uid, userId),
                              callerName: user.displayName ?? userName,
                              callType: 'video',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Private Chat Page
class PrivateChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;

  const PrivateChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _chatId {
    final currentUserId = _auth.currentUser!.uid;
    return currentUserId.compareTo(widget.otherUserId) < 0
        ? '${currentUserId}_${widget.otherUserId}'
        : '${widget.otherUserId}_$currentUserId';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      // FIRST: Create or update the chat document to ensure it exists
      await _firestore.collection('privateChats').doc(_chatId).set({
        'participants': [_auth.currentUser!.uid, widget.otherUserId],
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': _auth.currentUser!.uid,
      }, SetOptions(merge: true));

      // THEN: Add the message to the subcollection
      await _firestore
          .collection('privateChats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderId': _auth.currentUser!.uid,
        'recipientId': widget.otherUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUserPhoto.isNotEmpty
                  ? NetworkImage(widget.otherUserPhoto)
                  : null,
              child: widget.otherUserPhoto.isEmpty
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallJoinPage(
                    roomId: _chatId,
                    callerName: FirebaseAuth.instance.currentUser?.displayName ?? 'Caller',
                    callType: 'audio',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallJoinPage(
                    roomId: _chatId,
                    callerName: FirebaseAuth.instance.currentUser?.displayName ?? 'Caller',
                    callType: 'video',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('privateChats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe =
                        message['senderId'] == _auth.currentUser!.uid;

                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 30)),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: child,
                          ),
                        );
                      },
                      child: _MessageBubble(message: message, isMe: isMe),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timestamp = message['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? DateFormat('h:mm a').format(timestamp.toDate())
        : 'Sending...';
    final photoURL = message['photoURL'] ?? '';
    final senderName = message['senderName'] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && photoURL.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(photoURL),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      )
                    : null,
                color: isMe
                    ? null
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 10,
                          color: (isMe
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface)
                              .withOpacity(0.7),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Message Input Widget
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
