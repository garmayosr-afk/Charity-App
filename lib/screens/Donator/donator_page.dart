import 'package:charity_app/screens/Donator/donation_history_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Donator/donation_page.dart';
import '../Donator/adress_page.dart';
import '../Donator/about_us.dart';
import '../Donator/my_account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Donator/DonationView_Page.dart';
import '../Donator/donation_page.dart';

class DonatorPage extends StatefulWidget {
  const DonatorPage({super.key});

  @override
  State<DonatorPage> createState() => _DonatorPageState();
}

class _DonatorPageState extends State<DonatorPage> {
  String searchQuery = '';
  int _selectedIndex = 2; // Home is selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Light cream background
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildUrgentSection(),
            const SizedBox(height: 24),
            _buildDonationHistorySection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // 1. TOP HEADER & SEARCH BAR
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9A44), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Yosr',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Make a difference',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    radius: 20,
                    child: Text(
                      'Y',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C), // Dark search bar
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '...Search',
                    hintStyle: GoogleFonts.cairo(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. STATS ROW
  Widget _buildStatsRow() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const Center(child: Text("Please log in to see stats."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // FIRST STREAM: Listen to the user's donations
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('donor_id', isEqualTo: currentUid)
            .snapshots(),
        builder: (context, donationSnapshot) {
          int donationCount = 0;
          double totalAmount = 0;

          if (donationSnapshot.hasData) {
            donationCount = donationSnapshot.data!.docs.length;
            for (var doc in donationSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalAmount += (data['amount'] ?? 0).toDouble();
            }
          }

          // SECOND STREAM: Listen to orphanages where user is a unique donor
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orphanages')
                .where('unique_donors', arrayContains: currentUid)
                .snapshots(),
            builder: (context, centerSnapshot) {
              int centersCount = 0;
              if (centerSnapshot.hasData) {
                centersCount = centerSnapshot.data!.docs.length;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(donationCount.toString(), 'Donations'),
                  _buildStatCard(
                    '${totalAmount.toInt()} TND',
                    'Total',
                    isCenter: true,
                  ),
                  _buildStatCard(centersCount.toString(), 'Supported Centers'),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isCenter = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: isCenter
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFFF6D00),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 3. URGENT NEEDS SECTION (Now completely dynamic!)
  Widget _buildUrgentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    // Make sure you use push() and not pushReplacement()
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonationViewPage(),
                    ),
                  );
                },
                child: Text(
                  'View All ←',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'Urgent needs',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // StreamBuilder for ALL campaigns
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('campaigns')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error loading campaigns");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No urgent needs at the moment.",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                );
              }

              final campaigns = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final data = campaigns[index].data() as Map<String, dynamic>;

                  final String title = data['name'] ?? 'Unnamed Campaign';
                  final String description =
                      data['description'] ?? 'No description provided';
                  final double goal = (data['goal_amount'] ?? 1).toDouble();
                  final double raised = (data['raised_amount'] ?? 0).toDouble();

                  // Calculate percentage for the progress bar
                  double percent = raised / goal;
                  if (percent > 1.0) percent = 1.0;
                  if (percent.isNaN || percent.isInfinite) percent = 0.0;

                  return _buildUrgentCard(
                    title: title,
                    description: description,
                    goal: 'goal: ${goal.toInt()} TND',
                    percent: percent,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // UPDATED URGENT CARD (No emojis, English 'Donate', dynamic text)
  Widget _buildUrgentCard({
    required String title,
    required String description,
    required String goal,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side (Donate Button & Progress Bar)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donate Button
              InkWell(
                onTap: () {
                  // Add your donation navigation logic here
                  debugPrint("Donate clicked for $title");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Donate',
                    style: GoogleFonts.inter(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Progress Bar with Percentage
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.orange,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right Side (Text data)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  goal,
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. HISTORY SECTION
  // 3. DONATION HISTORY SECTION
  Widget _buildDonationHistorySection() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const SizedBox(); // Hide if not logged in
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // You mentioned you will build the View All logic yourself!
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonationPage(),
                    ),
                  );
                },
                child: Text(
                  'View All ←',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Donation History',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('📋', style: TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // LIVE STREAMBUILDER
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('donations')
                .where('donor_id', isEqualTo: currentUid)
                // Note: Using 'where' and 'orderBy' together requires a composite index in Firebase!
                // If it fails to load, check your debug console for the direct link to create it.
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No donation history yet.",
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }

              final donations = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final data = donations[index].data() as Map<String, dynamic>;

                  // 1. Amount
                  final double amount = (data['amount'] ?? 0).toDouble();

                  // 2. Date formatting
                  String dateString = 'Recent';
                  if (data['date'] != null) {
                    DateTime date = (data['date'] as Timestamp).toDate();
                    // Assuming you want standard formatting, adjust as needed!
                    dateString = "${date.day}/${date.month}/${date.year}";
                  }

                  // 3. Name Trick Logic
                  String campaignId =
                      data['campaign_id']?.toString().trim() ?? '';
                  String orphanageId =
                      data['orphanage_id']?.toString().trim() ?? '';

                  String nameToDisplay = campaignId.isNotEmpty
                      ? campaignId
                      : orphanageId;

                  return _buildHistoryCard(
                    '+${amount.toInt()} TND',
                    nameToDisplay,
                    dateString,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // THE UI FOR THE INDIVIDUAL HISTORY CARD
  Widget _buildHistoryCard(String amount, String nameText, String dateString) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Amount & Confirmed
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  color: const Color(0xFFD32F2F), // Reddish-orange
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.check,
                    color: Color(0xFF81C784),
                    size: 14,
                  ), // Light green
                  const SizedBox(width: 4),
                  Text(
                    'Confirmé',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF81C784),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right side: Name, Date, Icon
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nameText,
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateString,
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0), // Light orange background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite, // Heart icon
                      color: Color(0xFFFF9800), // Orange
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. CUSTOM BOTTOM NAVIGATION
  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.person,
              const Color(0xFF4A148C),
              'My Account',
            ),
            _buildNavItem(
              1,
              Icons.assignment,
              Colors.orangeAccent,
              'Donations',
            ),
            _buildNavItem(2, Icons.home, Colors.redAccent, 'Home'),
            _buildNavItem(3, Icons.card_giftcard, Colors.red, 'Donate Now'),
            _buildNavItem(4, Icons.info_outline, Colors.blue, 'About Us'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    Color iconColor,
    String label,
  ) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          // Routing Logic
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyaccountPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonationHisoryPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonationPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange : iconColor.withOpacity(0.6),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
