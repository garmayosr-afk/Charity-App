import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationViewPage extends StatefulWidget {
  const DonationViewPage({super.key});

  @override
  State<DonationViewPage> createState() => _DonationViewPageState();
}

class _DonationViewPageState extends State<DonationViewPage> {
  // The dummy data list has been completely removed!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP CONTAINER (Total Donors)
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90A980), Color(0xFFFF8C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total Donors',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(
                                    'orphanages',
                                  ) // Or 'users' if your orphanage data is in the users collection
                                  .where(
                                    'orphanage_id',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid,
                                  )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String totalDonors =
                                    "0"; // Default to 0 if empty or doesn't exist

                                // Show a tiny loading circle while fetching
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 38,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                // If we found the document, calculate the donors
                                if (snapshot.hasData &&
                                    snapshot.data!.docs.isNotEmpty) {
                                  final data =
                                      snapshot.data!.docs.first.data()
                                          as Map<String, dynamic>;

                                  if (data['unique_donors'] != null) {
                                    var donorsField = data['unique_donors'];

                                    // If Firebase stored it as an Array/List, get the count of items!
                                    if (donorsField is List) {
                                      totalDonors = donorsField.length
                                          .toString();
                                    }
                                    // If Firebase stored it as a standard number, just show the number
                                    else {
                                      totalDonors = donorsField.toString();
                                    }
                                  }
                                }

                                return Text(
                                  totalDonors,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        right: 20,
                        top: 35,
                        child: Icon(
                          Icons.people_outline,
                          color: Colors.white24,
                          size: 70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. BOTTOM CONTAINER (Active Campaigns Wrapper)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ROW (Header text)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Campaigns',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'View All',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF8C00),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),

                        // LIVE STREAMBUILDER (Replaced the static ListView)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('campaigns')
                              .where(
                                'orphanage_id',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid,
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "No campaigns created yet.",
                                    style: GoogleFonts.inter(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final campaigns = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: campaigns.length,
                              itemBuilder: (context, index) {
                                final data =
                                    campaigns[index].data()
                                        as Map<String, dynamic>;

                                final String title =
                                    data['name'] ?? 'Unnamed Campaign';
                                final double raised =
                                    (data['raised_amount'] ?? 0).toDouble();
                                final double goal = (data['goal_amount'] ?? 1)
                                    .toDouble();
                                final String status =
                                    data['status'] ?? 'active';

                                return _buildCampaignItem(
                                  title,
                                  raised,
                                  goal,
                                  status,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UPDATED INDIVIDUAL LIST ITEM WIDGET TREE
  Widget _buildCampaignItem(
    String title,
    double raised,
    double goal,
    String status,
  ) {
    // Math and Logic
    double percent = raised / goal;
    if (percent > 1.0) percent = 1.0; // Caps progress bar at 100%

    bool isFinished = (raised >= goal) || (status != 'active');

    String badgeText = isFinished ? 'Finished' : 'Active';
    Color badgeBgColor = isFinished
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFD4F7E6);
    Color badgeTextColor = isFinished
        ? const Color(0xFFD32F2F)
        : const Color(0xFF2E8B57);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Title and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    color: badgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ROW 2: Raised and Goal amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${raised.toInt()} TND raised',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
              ),
              Text(
                'Goal: ${goal.toInt()} TND',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // PROGRESSBAR
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            color: isFinished ? Colors.green : const Color(0xFFFFB347),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),

          // TEXT (Percent funded)
          Text(
            '${(percent * 100).toInt()}% funded',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 12),
          const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }
}
