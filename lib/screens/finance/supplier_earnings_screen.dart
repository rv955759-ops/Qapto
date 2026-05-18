import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierEarningsScreen extends StatefulWidget {
  const SupplierEarningsScreen({super.key});

  @override
  State<SupplierEarningsScreen> createState() =>
      _SupplierEarningsScreenState();
}

class _SupplierEarningsScreenState
    extends State<SupplierEarningsScreen> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final matches = await Supabase.instance.client
        .from('matches_log')
        .select();

    List temp = [];

    for (var match in matches) {
      final offer = await Supabase.instance.client
          .from('capacity_offers')
          .select()
          .eq('id', match['offer_id'])
          .eq('user_id', user.id) // IMPORTANT
          .maybeSingle();

      if (offer != null) {
        temp.add({
          'machine': offer['machine_type'],
          'location': offer['location'],
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
      appBar: AppBar(title: const Text("My Earnings")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("No earnings yet"))
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