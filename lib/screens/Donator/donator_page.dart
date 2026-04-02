import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Donator/donation_page.dart';

class DonatorPage extends StatefulWidget {
  const DonatorPage({super.key});

  @override
  State<DonatorPage> createState() => _DonatorPageState();
}

class _DonatorPageState extends State<DonatorPage> {
  String searchQuery = '';
  String? selectedOrphanageId;
  int _selectedIndex = 2;

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;

          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyaccountPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationhistoryPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 6),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.orange : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome Back"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1E9DC), Color(0xFFDDE6DB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search orphanage...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orphanages')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;
                      final filteredDocs = docs.where((doc) {
                        final name = doc['name'].toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      return Column(
                        children: filteredDocs.map((doc) {
                          return ListTile(
                            title: Text(doc['name']),
                            onTap: () {
                              setState(() {
                                selectedOrphanageId = doc.id;
                              });
                            },
                            selected: selectedOrphanageId == doc.id,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  if (selectedOrphanageId != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orphanages')
                          .doc(selectedOrphanageId)
                          .collection('needs')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final needsDocs = snapshot.data!.docs;

                        if (needsDocs.isEmpty) {
                          return const Text("No needs posted yet.");
                        }

                        return SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: needsDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const DonationPage()),
                                    );
                                  },
                                  child: Text(data['title']),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(index: 0, icon: Icons.person, iconColor: Colors.purple, label: 'My Account'),
              _buildNavItem(index: 1, icon: Icons.assignment, iconColor: Colors.brown, label: 'Donations'),
              _buildNavItem(index: 2, icon: Icons.home, iconColor: Colors.orange, label: 'Home'),
              _buildNavItem(index: 3, icon: Icons.card_giftcard, iconColor: Colors.amber, label: 'Donate Now'),
              _buildNavItem(index: 4, icon: Icons.info, iconColor: Colors.blue, label: 'About Us'),
            ],
          ),
        ),
      ),
    );
  }
}


