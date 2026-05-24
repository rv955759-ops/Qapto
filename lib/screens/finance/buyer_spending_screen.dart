import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerSpendingScreen
    extends StatefulWidget {

  const BuyerSpendingScreen({
    super.key,
  });

  @override
  State<BuyerSpendingScreen>
      createState() =>
          _BuyerSpendingScreenState();
}

class _BuyerSpendingScreenState
    extends State<BuyerSpendingScreen> {

  List data = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    fetchSpending();
  }

  Future<void> fetchSpending() async {

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
              .select()
              .eq(
                'buyer_id',
                user.id,
              );

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

      print("BUYER ERROR: $e");

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
          "My Spending",
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
                    "No spending yet",
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