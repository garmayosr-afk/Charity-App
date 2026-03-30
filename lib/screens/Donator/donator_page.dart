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
    );
  }
}