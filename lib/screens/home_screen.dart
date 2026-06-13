import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'login_screen.dart';
import 'workers_screen.dart';
import 'worker_profile_screen.dart';
import 'client_profile_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String currentView = 'client';
  String? userName;
  String? userRole;
  bool isLoading = true;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Plumber', 'icon': Icons.plumbing, 'color': Color(0xFF3498DB)},
    {
      'name': 'Electrician',
      'icon': Icons.electrical_services,
      'color': Color(0xFFF39C12),
    },
    {'name': 'Painter', 'icon': Icons.format_paint, 'color': Color(0xFF9B59B6)},
    {'name': 'Carpenter', 'icon': Icons.handyman, 'color': Color(0xFF795548)},
    {'name': 'AC Repair', 'icon': Icons.ac_unit, 'color': Color(0xFF00BCD4)},
    {'name': 'Driver', 'icon': Icons.drive_eta, 'color': Color(0xFF2ECC71)},
    {'name': 'Cook', 'icon': Icons.restaurant, 'color': Color(0xFFE74C3C)},
    {'name': 'Teacher', 'icon': Icons.school, 'color': Color(0xFF1ABC9C)},
    {
      'name': 'Doctor',
      'icon': Icons.medical_services,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Graphic Designer',
      'icon': Icons.design_services,
      'color': Color(0xFF673AB7),
    },
    {
      'name': 'Web Developer',
      'icon': Icons.computer,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Photographer',
      'icon': Icons.camera_alt,
      'color': Color(0xFFFF5722),
    },
    {'name': 'Guard', 'icon': Icons.security, 'color': Color(0xFF607D8B)},
    {
      'name': 'Cleaner',
      'icon': Icons.cleaning_services,
      'color': Color(0xFF4CAF50),
    },
    {'name': 'Mason', 'icon': Icons.architecture, 'color': Color(0xFFFF9800)},
    {'name': 'Tailor', 'icon': Icons.checkroom, 'color': Color(0xFFE91E63)},
    {'name': 'Mechanic', 'icon': Icons.build, 'color': Color(0xFF9E9E9E)},
    {'name': 'Gardener', 'icon': Icons.grass, 'color': Color(0xFF8BC34A)},
    {'name': 'Data Entry', 'icon': Icons.keyboard, 'color': Color(0xFF00ACC1)},
    {
      'name': 'Video Editor',
      'icon': Icons.video_call,
      'color': Color(0xFFAB47BC),
    },
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadAd();
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9699182556705292/4612929358',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance.ref();
    final snapshot = await db.child('users/$uid').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        userName = data['name']?.toString() ?? 'User';
        userRole = data['role']?.toString() ?? 'client';
        currentView = userRole!;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void switchView() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Switch Mode',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => currentView = 'worker');
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: currentView == 'worker'
                      ? Color(0xFF2ECC71).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: currentView == 'worker'
                        ? Color(0xFF2ECC71)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.handyman, color: Color(0xFF2ECC71), size: 30),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Worker Mode',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Manage your services',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (currentView == 'worker')
                      Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => currentView = 'client');
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentView == 'client'
                      ? Color(0xFF3498DB).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: currentView == 'client'
                        ? Color(0xFF3498DB)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search,
                      color: Color(0xFF3498DB),
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client Mode',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Find & hire workers',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (currentView == 'client')
                      Icon(Icons.check_circle, color: Color(0xFF3498DB)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
        ),
      );
    }

    Color appBarColor = currentView == 'worker'
        ? Color(0xFF2ECC71)
        : Color(0xFF3498DB);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text(
          'RozgaarApp',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: switchView,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    currentView == 'worker' ? 'Worker' : 'Client',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: currentView == 'worker' ? _workerDashboard() : _clientDashboard(),
      bottomSheet: _isAdLoaded
          ? Container(height: 50, child: AdWidget(ad: _bannerAd!))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatListScreen()),
            );
          } else if (index == 2) {
            if (currentView == 'worker') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkerProfileScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientProfileScreen()),
              );
            }
          }
        },
        selectedItemColor: appBarColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _workerDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Color(0xFF2ECC71),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userName ?? 'Worker'}! 👷',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage your profile and jobs',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        '0',
                        'Total Jobs',
                        Icons.work,
                        Color(0xFF2ECC71),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        '0.0',
                        'Rating',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        '0',
                        'Reviews',
                        Icons.reviews,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfileScreen(),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF2ECC71)),
                        SizedBox(width: 10),
                        Text(
                          'Edit My Profile',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF2ECC71)),
                      SizedBox(width: 10),
                      Text(
                        'Job History',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientDashboard() {
    return Column(
      children: [
        Container(
          color: Color(0xFF3498DB),
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${userName ?? 'Client'}! 👋',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for any service...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          WorkersScreen(
                            categoryName: categories[index]['name'],
                            categoryColor: categories[index]['color'],
                            categoryIcon: categories[index]['icon'],
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categories[index]['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categories[index]['icon'],
                          color: categories[index]['color'],
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        categories[index]['name'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
