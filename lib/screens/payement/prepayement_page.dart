import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import 'personalinfo_page.dart';

class PrepayementPage extends StatefulWidget {
  const PrepayementPage({super.key});

  @override
  State<PrepayementPage> createState() => _PrepayementPageState();
}

class _PrepayementPageState extends State<PrepayementPage> {
  int? _selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();

  Widget _buildAmountButton(int amount) {
    bool isSelected = _selectedAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAmount = amount;
            _customAmountController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$amount',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.orange : const Color(0xFF003366),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TND',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.orange : const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Background(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEADB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.import_contacts,
                        color: Color(0xFFDF5A20),
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.65,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7A00), Color(0xFFFFB800)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Select an amount",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132F4C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildAmountButton(25),
                        const SizedBox(width: 16),
                        _buildAmountButton(50),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildAmountButton(100),
                        const SizedBox(width: 16),
                        _buildAmountButton(250),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: _customAmountController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
                        hintText: "Custom amount",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedAmount = null; // Unselect buttons if typing
                        });
                      },
                    ),

                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFCA56A), Color(0xFFF7D57B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const InformationsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Continue to Payment",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
                ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
