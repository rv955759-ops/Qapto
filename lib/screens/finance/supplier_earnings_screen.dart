import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierEarningsScreen
    extends StatefulWidget {

  const SupplierEarningsScreen({
    super.key,
  });

  @override
  State<SupplierEarningsScreen>
      createState() =>
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

    final user =
        Supabase.instance.client
            .auth
            .currentUser;

    if (user == null) {

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {

      final matches =
          await Supabase.instance.client
              .from('matches_log')
              .select();

      List temp = [];

      for (var match in matches) {

        final offer =
            await Supabase.instance.client
                .from('capacity_offers')
                .select()
                .eq(
                  'id',
                  match['offer_id'],
                )
                .eq(
                  'user_id',
                  user.id,
                )
                .maybeSingle();

        if (offer != null) {

          temp.add({

            'machine':
                offer['machine_type']
                    ?? 'Machine',

            'location':
                offer['location']
                    ?? 'Unknown',

            'amount':
                match['total_amount']
                    ?? 0,

            'status':
                match['payment_status']
                    ?? 'pending',
          });
        }
      }

      setState(() {

        data = temp;

        isLoading = false;
      });

    } catch (e) {

      print("SUPPLIER ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "My Earnings",
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : data.isEmpty

              ? const Center(
                  child: Text(
                    "No earnings yet",
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(12),

                  itemCount: data.length,

                  itemBuilder:
                      (context, index) {

                    final item = data[index];

                    return Card(

                      child: Padding(

                        padding:
                            const EdgeInsets.all(
                                12),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              item['machine'],

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              "Location: ${item['location']}",
                            ),

                            Text(
                              "Amount: ₹${item['amount']}",
                            ),

                            Text(
                              "Status: ${item['status']}",

                              style: TextStyle(
                                color:
                                    item['status'] ==
                                            'confirmed'

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
    );
  }
}