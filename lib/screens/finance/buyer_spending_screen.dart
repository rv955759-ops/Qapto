import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerSpendingScreen extends StatefulWidget {
  const BuyerSpendingScreen({super.key});

  @override
  State<BuyerSpendingScreen> createState() =>
      _BuyerSpendingScreenState();
}

class _BuyerSpendingScreenState extends State<BuyerSpendingScreen> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSpending();
  }

  Future<void> fetchSpending() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    // 1️⃣ Get all matches
    final matches = await Supabase.instance.client
        .from('matches_log')
        .select();

    List temp = [];

    for (var match in matches) {
      // 2️⃣ Get request for THIS user only
      final request = await Supabase.instance.client
          .from('capacity_requests')
          .select()
          .eq('id', match['request_id'])
          .eq('user_id', user.id) // 🔥 IMPORTANT
          .maybeSingle();

      if (request != null) {
        temp.add({
          'machine': request['machine_type_needed'],
          'location': request['location'],
          'amount': match['total_amount'] ?? 0,
          'status': match['payment_status'],
        });
      }
    }

    setState(() {
      data = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Spending")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("No spending yet"))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    // HEADER
                    const Row(
                      children: [
                        Expanded(child: Text("Machine")),
                        Expanded(child: Text("Location")),
                        Expanded(child: Text("Amount")),
                        Expanded(child: Text("Status")),
                      ],
                    ),
                    const Divider(),

                    // DATA
                    ...data.map((item) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(child: Text(item['machine'])),
                                Expanded(child: Text(item['location'])),
                                Expanded(
                                    child: Text("₹${item['amount']}")),
                                Expanded(
                                  child: Text(
                                    item['status'],
                                    style: TextStyle(
                                      color: item['status'] == 'paid'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
    );
  }
}