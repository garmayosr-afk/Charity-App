import 'package:charity_app/screens/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'all_donations_history_page.dart';
import 'create_campaign_page.dart';
import 'donation_view_page.dart';

class OrphanagePage extends StatefulWidget {
  const OrphanagePage({super.key});

  @override
  State<OrphanagePage> createState() => _OrphanagePageState();
}

class _OrphanagePageState extends State<OrphanagePage> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Logout Logic
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // The warm cream background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. CUSTOM HEADER WITH LOGOUT (From your snippet) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEAD6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.domain,
                            color: Color(0xFFFF7A00),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Orphanage\nDashboard',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage Your Orphanage',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF1A1A1A),
                        size: 20,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- 2. ACTION BUTTONS (Your exact containers) ---
                Row(
                  children: [
                    // Left Button: View Donations History
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DonationViewPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF7A00),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.history, color: Color(0xFFFF7A00)),
                              SizedBox(height: 8),
                              Text(
                                'View\nDonations\nHistory',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFF7A00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Button: Create Campaign (Orange Gradient)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateCampaignPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFAD42), Color(0xFFFF7A00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Create\nCampaign',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- 3. TOTAL ANNUAL DONATIONS (From the new logic) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90A980), Color(0xFF6B8E5C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Annual Donations',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // --- REPLACEMENT FOR TOTAL ANNUAL DONATIONS STREAM ---
                      // (Find your Total Annual Donations StreamBuilder and replace it with this)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('donations')
                            .where(
                              'orphanage_id',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                            ) // Fetched instantly here!
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Error loading',
                              style: GoogleFonts.inter(color: Colors.white),
                            );
                          }

                          double totalAmount = 0;
                          if (snapshot.hasData) {
                            for (var doc in snapshot.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              totalAmount += (data['amount'] ?? 0).toDouble();
                            }
                          }
                          return Text(
                            '${totalAmount.toInt()} TND',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- 4. RECENT DONATIONS LIST (From the new logic) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AllDonationsHistoryPage(),
                          ),
                        );
                      },
                      child: Text(
                        'View All ←',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Donations History',
                          style: GoogleFonts.cairo(
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

                _buildRecentDonationsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the nested list of recent donations
  // --- REPLACEMENT FOR RECENT DONATIONS LIST METHOD ---
  Widget _buildRecentDonationsList() {
    final String? currentUid =
        FirebaseAuth.instance.currentUser?.uid; // Fetching exactly when needed

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .where('orphanage_id', isEqualTo: currentUid)
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        // THIS IS THE MAGIC LINE: It will tell you if Firebase is blocking the query!
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Database Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No donations yet.",
                style: GoogleFonts.inter(color: Colors.grey),
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
            final String donorId = data['donor_id'] ?? '';
            final double amount = (data['amount'] ?? 0).toDouble();

            String dateString = 'Recent';
            if (data['date'] != null) {
              DateTime date = (data['date'] as Timestamp).toDate();
              dateString = "${date.day}/${date.month}/${date.year}";
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(donorId)
                  .get(),
              builder: (context, userSnapshot) {
                String donorName = 'Anonymous';
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  donorName = userData['name'] ?? 'Anonymous';
                }

                return _buildHistoryCard(
                  '+${amount.toInt()} TND',
                  donorName,
                  dateString,
                );
              },
            );
          },
        );
      },
    );
  }

  // The beautiful list card UI
  Widget _buildHistoryCard(String amount, String name, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 1),
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
              Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Confirmé',
                    style: GoogleFonts.inter(color: Colors.green, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECDA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
