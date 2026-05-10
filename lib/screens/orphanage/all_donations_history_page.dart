import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllDonationsHistoryPage extends StatefulWidget {
  const AllDonationsHistoryPage({super.key});

  @override
  State<AllDonationsHistoryPage> createState() => _AllDonationsHistoryPageState();
}

class _AllDonationsHistoryPageState extends State<AllDonationsHistoryPage> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Donations History', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('orphanage_id', isEqualTo: uid)
            .orderBy('date', descending: true)
            // No limit here! We fetch everything.
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No donations found.", style: GoogleFonts.inter()));
          }

          final donations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

              // Fetch User Name for each card
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(donorId).get(),
                builder: (context, userSnapshot) {
                  String donorName = 'Anonymous';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    donorName = userData['name'] ?? 'Anonymous';
                  }

                  return _buildHistoryCard('+${amount.toInt()} TND', donorName, dateString);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Exact same card layout as the dashboard
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
              Text(amount, style: GoogleFonts.inter(color: const Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text('Confirmé', style: GoogleFonts.inter(color: Colors.green, fontSize: 10)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(date, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFDECDA), shape: BoxShape.circle),
                child: const Icon(Icons.favorite, color: Colors.orange, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
