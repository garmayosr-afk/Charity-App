import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Donation History',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: currentUid == null
          ? Center(
              child: Text(
                "Please log in to view your history.",
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
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
                    dateString = "${date.day}/${date.month}/${date.year}";
                  }

                  // 3. Extract IDs
                  String campaignId = data['campaign_id']?.toString().trim() ?? '';
                  String orphanageId = data['orphanage_id']?.toString().trim() ?? '';
                  
                  bool isCampaign = campaignId.isNotEmpty;

                  // 4. FutureBuilder to fetch the actual name from the DB
                  return FutureBuilder<DocumentSnapshot>(
                    future: isCampaign
                        ? FirebaseFirestore.instance.collection('campaigns').doc(campaignId).get()
                        : FirebaseFirestore.instance.collection('users').doc(orphanageId).get(),
                    builder: (context, nameSnapshot) {
                      
                      String nameToDisplay = '...'; // Shows briefly while loading

                      if (nameSnapshot.connectionState == ConnectionState.done) {
                        if (nameSnapshot.hasData && nameSnapshot.data!.exists) {
                          final docData = nameSnapshot.data!.data() as Map<String, dynamic>;
                          
                          // It will try to find 'name'. If your campaign uses 'title' instead, it will find that!
                          nameToDisplay = docData['name'] ?? docData['title'] ?? (isCampaign ? 'Unknown Campaign' : 'Unknown Orphanage');
                        } else {
                          nameToDisplay = isCampaign ? 'Unknown Campaign' : 'Unknown Orphanage';
                        }
                      }

                      // 5. Return your exact UI card
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
    );
  }

  // The exact same UI card widget
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
}
