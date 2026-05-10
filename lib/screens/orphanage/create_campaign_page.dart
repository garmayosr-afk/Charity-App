import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitCampaign() async {
    // 1. Basic Form Validation
    final String name = _nameController.text.trim();
    final String goalText = _goalController.text.trim();
    final String description = _descController.text.trim();

    if (name.isEmpty || goalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields.')));
      return;
    }

    final double? goalAmount = double.tryParse(goalText);
    if (goalAmount == null || goalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid goal amount.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in!");
      }

      final String orphanageId = currentUser.uid;

      // 2. Check for Duplicate Campaign Name for THIS orphanage
      final existingCampaigns = await FirebaseFirestore.instance
          .collection('campaigns')
          .where('orphanage_id', isEqualTo: orphanageId)
          .where('name', isEqualTo: name)
          .get();

      if (existingCampaigns.docs.isNotEmpty) {
        // Name already exists! Stop here.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already have a campaign with this name!'), backgroundColor: Colors.red),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }

      // 3. Name is unique, create the campaign!
      await FirebaseFirestore.instance.collection('campaigns').add({
        'name': name,
        'description': description,
        'goal_amount': goalAmount,
        'raised_amount': 0, // Always starts at 0
        'status': 'active', // Status is active
        'orphanage_id': orphanageId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 4. Success! Clear form and go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to the dashboard
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Create Campaign",
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                "Please fill out the form below",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // Campaign Name Field
              _buildLabel('Campaign Name'),
              _buildTextField(
                controller: _nameController,
                hintText: 'Campaign Name',
              ),
              const SizedBox(height: 20),

              // Goal Amount Field
              _buildLabel('Goal Amount (TND)'),
              _buildTextField(
                controller: _goalController,
                hintText: 'Amount',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Description Field
              _buildLabel('Description'),
              _buildTextField(
                controller: _descController,
                hintText: 'Write details about the campaign...',
                maxLines: 4, // Makes it taller for descriptions
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00), // Orange app color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submitCampaign,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(
                          "Submit Campaign",
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the labels above fields cleanly
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
      ),
    );
  }

  // Helper widget for standardized text fields
  Widget _buildTextField({
    required TextEditingController controller, 
    required String hintText, 
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.redAccent[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
