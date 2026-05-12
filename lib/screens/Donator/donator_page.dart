import 'package:charity_app/screens/Donator/donation_history_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Donator/donation_page.dart';
import '../Donator/about_us.dart';
import '../Donator/my_account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Donator/donation_view_page.dart';

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
            // THE NEW SEARCH RESULTS LIST VIEW
            _buildSearchResults(),
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
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Loading...',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  !snapshot.data!.exists) {
                                return Text(
                                  'Welcome!',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              final userData = snapshot.data!.data()
                                  as Map<String, dynamic>?;
                              final userName =
                                  userData?['name'] ?? 'Friend';

                              return Text(
                                userName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
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
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                  color: const Color(0xFF2C2C2C),
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
                      searchQuery = value.toLowerCase().trim();
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

  // --- NEW: SEARCH RESULTS LOGIC ---
  Future<List<Map<String, dynamic>>> _fetchCombinedSearchResults() async {
    List<Map<String, dynamic>> results = [];

    // 1. Fetch campaigns
    var campaignQuery =
        await FirebaseFirestore.instance.collection('campaigns').get();
    for (var doc in campaignQuery.docs) {
      var data = doc.data();
      String name = data['name'] ?? data['title'] ?? '';
      if (name.toLowerCase().contains(searchQuery)) {
        results.add({
          'id': doc.id,
          'name': name,
          'type': 'Campaign',
          'orphanage_id': data['orphanage_id'] ?? '',
        });
      }
    }

    // 2. Fetch orphanages
    var orphanageQuery =
        await FirebaseFirestore.instance.collection('orphanages').get();
    for (var doc in orphanageQuery.docs) {
      var data = doc.data();
      String name = data['name'] ?? '';
      if (name.toLowerCase().contains(searchQuery)) {
        results.add({
          'id': doc.id,
          'name': name,
          'type': 'Orphanage',
          'orphanage_id': doc.id, // For an orphanage, its own ID is the orphanage_id
        });
      }
    }

    return results;
  }

  // --- NEW: SEARCH RESULTS WIDGET ---
  Widget _buildSearchResults() {
    if (searchQuery.isEmpty) return const SizedBox(); // Hide when empty

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCombinedSearchResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "No results found.",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          );
        }

        final items = snapshot.data!;

        return Container(
          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.shade200, height: 1),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                title: Text(
                  item['name'],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  item['type'],
                  style: GoogleFonts.inter(
                    color: item['type'] == 'Campaign'
                        ? Colors.orange
                        : Colors.blue,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  // Navigate to DonationPage with correct IDs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationPage(
                        orphanageId: item['orphanage_id'],
                        campaignId:
                            item['type'] == 'Campaign' ? item['id'] : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
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
              color: Colors.black.withValues(alpha: 0.02),
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

  // 3. URGENT NEEDS SECTION
  Widget _buildUrgentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
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

                  // EXTRACT IDS
                  final String currentCampaignId = campaigns[index].id;
                  final String currentOrphanageId =
                      data['orphanage_id']?.toString() ?? '';

                  final String title = data['name'] ?? 'Unnamed Campaign';
                  final String description =
                      data['description'] ?? 'No description provided';
                  final double goal = (data['goal_amount'] ?? 1).toDouble();
                  final double raised = (data['raised_amount'] ?? 0).toDouble();

                  double percent = raised / goal;
                  if (percent > 1.0) percent = 1.0;
                  if (percent.isNaN || percent.isInfinite) percent = 0.0;

                  return _buildUrgentCard(
                    campaignId: currentCampaignId,
                    orphanageId: currentOrphanageId,
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

  // UPDATED URGENT CARD
  Widget _buildUrgentCard({
    required String campaignId,
    required String orphanageId,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  // NEW ROUTING: Goes to donation page passing variables
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationPage(
                        campaignId: campaignId,
                        orphanageId: orphanageId,
                      ),
                    ),
                  );
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

  // 4. DONATION HISTORY SECTION
  Widget _buildDonationHistorySection() {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('donations')
                .where('donor_id', isEqualTo: currentUid)
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
                  final double amount = (data['amount'] ?? 0).toDouble();

                  String dateString = 'Recent';
                  if (data['date'] != null) {
                    DateTime date = (data['date'] as Timestamp).toDate();
                    dateString = "${date.day}/${date.month}/${date.year}";
                  }

                  String campaignId =
                      data['campaign_id']?.toString().trim() ?? '';
                  String orphanageId =
                      data['orphanage_id']?.toString().trim() ?? '';

                  bool isCampaign = campaignId.isNotEmpty;

                  return FutureBuilder<DocumentSnapshot>(
                    future: isCampaign
                        ? FirebaseFirestore.instance
                            .collection('campaigns')
                            .doc(campaignId)
                            .get()
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(orphanageId)
                            .get(),
                    builder: (context, nameSnapshot) {
                      String nameToDisplay = '...';

                      if (nameSnapshot.connectionState ==
                          ConnectionState.done) {
                        if (nameSnapshot.hasData &&
                            nameSnapshot.data!.exists) {
                          final docData = nameSnapshot.data!.data()
                              as Map<String, dynamic>;

                          nameToDisplay = docData['name'] ??
                              docData['title'] ??
                              (isCampaign
                                  ? 'Unknown Campaign'
                                  : 'Unknown Orphanage');
                        } else {
                          nameToDisplay = isCampaign
                              ? 'Unknown Campaign'
                              : 'Unknown Orphanage';
                        }
                      }

                      return _buildHistoryCard(
                        '+${amount.toInt()} TND',
                        nameToDisplay,
                        dateString,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  color: const Color(0xFFD32F2F),
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
                  ),
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
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite,
                      color: Color(0xFFFF9800),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.person, const Color(0xFF4A148C), 'My Account'),
            _buildNavItem(1, Icons.assignment, Colors.orangeAccent, 'Donations'),
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
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyaccountPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DonationHistoryPage(),
              ),
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
            color: isSelected ? Colors.orange : iconColor.withValues(alpha: 0.6),
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