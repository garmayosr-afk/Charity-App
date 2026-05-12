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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // We wrap your container in Expanded so it takes up the rest of the screen
              Expanded(
                child: Container(
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
                        // HEADER TEXT (Stays fixed at the top)
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

                        // We wrap the StreamBuilder in Expanded so the ListView can scroll freely inside it
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('campaigns')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.orange),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No urgent needs at the moment.",
                                    style: GoogleFonts.inter(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }

                              final campaigns = snapshot.data!.docs;

                              return ListView.builder(
                                // REMOVED shrinkWrap and NeverScrollableScrollPhysics!
                                // Now this list will scroll perfectly on its own.
                                itemCount: campaigns.length,
                                itemBuilder: (context, index) {
                                  final data = campaigns[index].data() as Map<String, dynamic>;

                                  final String title = data['name'] ?? 'Unnamed Campaign';
                                  final String description = data['description'] ?? 'No description provided';
                                  final double goal = (data['goal_amount'] ?? 1).toDouble();
                                  final double raised = (data['raised_amount'] ?? 0).toDouble();

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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Your exact card widget, completely unchanged
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  debugPrint("Donate clicked for $title");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
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
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.right,
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  goal,
                  style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 10),
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