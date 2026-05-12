import 'package:charity_app/screens/Donator/adress_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart';
import '../payement/prepayement_page.dart';
import '../../widgets/card.dart';

class DonationPage extends StatefulWidget {
  final String? orphanageId;
  final String? campaignId;

  const DonationPage({super.key, this.orphanageId, this.campaignId});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  String? _selectedUniqueId; // We now use a combined ID for the dropdown
  String? _selectedRealId;   // The actual Firestore ID to pass to payment
  String? _selectedType;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDonationTargets();
  }

  Future<void> _fetchDonationTargets() async {
    try {
      List<Map<String, dynamic>> fetchedItems = [];

      // 1. Fetch Orphanages
      final orphanagesSnapshot =
          await FirebaseFirestore.instance.collection('orphanages').get();
      
      for (var doc in orphanagesSnapshot.docs) {
        fetchedItems.add({
          'real_id': doc.id,
          'unique_id': 'Orphanage_${doc.id}', // Prevents ID overlaps
          'name': doc.data().containsKey('name') ? doc['name'] : 'Unnamed Orphanage',
          'type': 'Orphanage',
        });
      }

      // 2. Fetch Campaigns
      final campaignsSnapshot =
          await FirebaseFirestore.instance.collection('campaigns').get();
      
      for (var doc in campaignsSnapshot.docs) {
        fetchedItems.add({
          'real_id': doc.id,
          'unique_id': 'Campaign_${doc.id}', // Prevents ID overlaps
          'name': doc.data().containsKey('name') ? doc['name'] : 'Unnamed Campaign',
          'type': 'Campaign',
        });
      }

      setState(() {
        _dropdownItems = fetchedItems;
        _isLoading = false;

        // 3. Pre-select logic: Check Campaign FIRST
        if (widget.campaignId != null && widget.campaignId!.isNotEmpty) {
          _selectedUniqueId = 'Campaign_${widget.campaignId}';
          _selectedRealId = widget.campaignId;
          _selectedType = 'Campaign';
        } else if (widget.orphanageId != null && widget.orphanageId!.isNotEmpty) {
          _selectedUniqueId = 'Orphanage_${widget.orphanageId}';
          _selectedRealId = widget.orphanageId;
          _selectedType = 'Orphanage';
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMoneyDonation() {
    if (_selectedRealId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a campaign or orphanage to donate to.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Determine which ID to pass
    String? passOrphanageId = _selectedType == 'Orphanage' ? _selectedRealId : null;
    String? passCampaignId = _selectedType == 'Campaign' ? _selectedRealId : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrepayementPage(
          orphanageId: passOrphanageId,
          campaignId: passCampaignId, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Now"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Choose A Campaign To Donate',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFB08060),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFFB08060))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFB08060).withOpacity(0.5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Select a Campaign / Orphanage'),
                              value: _selectedUniqueId, // Uses the unique ID
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFFB08060)),
                              items: _dropdownItems.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['unique_id'], 
                                  child: Text('${item['name']} (${item['type']})'), 
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUniqueId = newValue;
                                  // Update the real ID and Type based on selection
                                  var selectedItem = _dropdownItems.firstWhere(
                                      (element) => element['unique_id'] == newValue);
                                  _selectedRealId = selectedItem['real_id'];
                                  _selectedType = selectedItem['type'];
                                });
                              },
                            ),
                          ),
                        ),

                  const SizedBox(height: 30),

                  RoleCard(
                    icon: Icons.attach_money,
                    color: Colors.orangeAccent,
                    title: "Money Donation ",
                    description: "Donate Money Directly",
                    buttonText: "Donate Money",
                    onPressed: _handleMoneyDonation,
                  ),

                  const SizedBox(height: 16),
                  
                  RoleCard(
                    icon: Icons.checkroom,
                    color: Colors.orangeAccent,
                    title: "Other Donations ",
                    description:
                        "Donate new or gently used clothing, Food And School Materials for children of all ages",
                    buttonText: "Donate now",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdressePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}