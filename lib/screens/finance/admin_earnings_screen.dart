import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEarningsScreen extends StatefulWidget {
  const AdminEarningsScreen({super.key});

  @override
  State<AdminEarningsScreen> createState() =>
      _AdminEarningsScreenState();
}

class _AdminEarningsScreenState extends State<AdminEarningsScreen> {
  List data = [];
  bool isLoading = true;
  double totalPlatformFee = 0;

  @override
  void initState() {
    super.initState();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    final response = await Supabase.instance.client
        .from('matches_log')
        .select();

    double tempTotal = 0;

    for (var item in response) {
      final fee = (item['platform_fee'] ?? 0);
      tempTotal += fee;
    }

    setState(() {
      data = response;
      totalPlatformFee = tempTotal;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Earnings")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔥 TOTAL CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.deepPurple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Platform Earnings",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "₹$totalPlatformFee",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: data.isEmpty
                      ? const Center(child: Text("No earnings yet"))
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.analytics),
                                title: Text(
                                    "Deal ID: ${item['id']}"),
                                subtitle: Text(
                                    "Total: ₹${item['total_amount']}"),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "₹${item['platform_fee']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      item['payment_status'],
                                      style: TextStyle(
                                        color:
                                            item['payment_status'] ==
                                                    'paid'
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}