import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationViewPage extends StatefulWidget {
  const DonationViewPage({super.key});

  @override
  State<DonationViewPage> createState() => _DonationViewPageState();
}

class _DonationViewPageState extends State<DonationViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pop(context), // This returns you to the previous page
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 2. BOTTOM CONTAINER (Urgent Needs / Campaigns)
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
                        Text(
                          'All Urgent Needs',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),

                        // LIVE STREAMBUILDER (Shows ALL campaigns)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('campaigns')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
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
                                    "No urgent needs at the moment.",
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
                                final String description =
                                    data['description'] ??
                                    'No description provided';
                                final double goal = (data['goal_amount'] ?? 1)
                                    .toDouble();
                                final double raised =
                                    (data['raised_amount'] ?? 0).toDouble();

                                // Calculate percentage
                                double percent = raised / goal;
                                if (percent > 1.0) {
                                  percent = 1.0;
                                }
                                if (percent.isNaN || percent.isInfinite) {
                                  percent = 0.0;
                                }

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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // REPLACED WIDGET: The new Urgent Card design
  Widget _buildUrgentCard({
    required String title,
    required String description,
    required String goal,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
}
