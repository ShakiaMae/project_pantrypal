import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import '../pantry/pantry_screen.dart';
import '../recipes/add_recipe_screen.dart' as add_recipe;
import '../recipes/recipe_browser_screen.dart' as recipe_browser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _userName;

  final Color neonPink = const Color(0xFFFF1EC9);
  final Color darkBg = const Color(0xFF0A0A0F);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (mounted) {
      setState(() {
        _userName = user?.name;
      });
    }
  }

  Future<void> _logout() async {
    await StorageService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      const PantryScreen(),
      const recipe_browser.RecipeBrowserScreen(),
    ];

    return Scaffold(
      backgroundColor: darkBg,

      body: IndexedStack(index: _currentIndex, children: screens),

      // -----------------------------------------------------------------
      // CLEAN BOTTOM NAVIGATION BAR (no glow)
      // -----------------------------------------------------------------
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: neonPink,
          unselectedItemColor: Colors.white54,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: neonPink),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen, color: neonPink),
              label: 'Pantry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu, color: neonPink),
              label: 'Recipes',
            ),
          ],
        ),
      ),

      // -----------------------------------------------------------------
      // CLEAN NEON PINK FAB
      // -----------------------------------------------------------------
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
        backgroundColor: neonPink,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const add_recipe.AddRecipeScreen()),
          );
        },
      )
          : null,
    );
  }

  // =====================================================================
  // HOME TAB
  // =====================================================================
  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Welcome${_userName != null ? ', $_userName' : ''}!',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 30),

            Text(
              'Quick Actions',
              style: TextStyle(
                color: neonPink,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Manage Pantry',
                    icon: Icons.kitchen,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    title: 'Browse Recipes',
                    icon: Icons.restaurant_menu,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Add Recipe',
                    icon: Icons.add_circle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const add_recipe.AddRecipeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    title: 'Grocery List',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Grocery list coming soon!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // CLEAN WELCOME CARD (no glow)
  // =====================================================================
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: neonPink.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neonPink.withOpacity(0.2),
            ),
            child: Icon(Icons.kitchen, size: 42, color: neonPink),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to PantryPal!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage your pantry and discover amazing recipes.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // ACTION CARDS (clean flat neon style)
  // =====================================================================
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: neonPink.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: neonPink),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
