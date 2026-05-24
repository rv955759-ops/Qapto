import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDealsScreen extends StatefulWidget {
  const MyDealsScreen({super.key});

  @override
  State<MyDealsScreen> createState() =>
      _MyDealsScreenState();
}

class _MyDealsScreenState
    extends State<MyDealsScreen> {

  List deals = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    fetchDeals();
  }

  Future<void> fetchDeals() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {

      final data =
          await Supabase.instance.client
              .from('matches_log')
              .select()
              .eq('buyer_id', user.id)
              .order(
                'created_at',
                ascending: false,
              );

      List tempDeals = [];

      for (var match in data) {

        final offer =
            await Supabase.instance.client
                .from('capacity_offers')
                .select()
                .eq(
                  'id',
                  match['offer_id'],
                )
                .maybeSingle();

        tempDeals.add({

          'id': match['id'],

          'machine':
              offer?['machine_type']
                  ?? 'Machine',

          'location':
              offer?['location']
                  ?? 'Unknown',

          'status':
              match['deal_status']
                  ?? 'pending',

          'payment':
              match['payment_status']
                  ?? 'pending',

          'total':
              offer?['hourly_rate'] ?? 0,
        });
      }

      setState(() {

        deals = tempDeals;

        loading = false;
      });

    } catch (e) {

      print("DEALS ERROR: $e");

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (deals.isEmpty) {

      return const Scaffold(
        body: Center(
          child: Text(
            "No deals found",
          ),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "My Deals",
        ),
      ),

      body: ListView.builder(

        itemCount: deals.length,

        itemBuilder: (context, index) {

          final deal = deals[index];

          return Card(

            margin:
                const EdgeInsets.all(10),

            child: ListTile(

              title: Text(
                deal['machine'],
              ),

              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    "Location: ${deal['location']}",
                  ),

                  Text(
                    "Deal Status: ${deal['status']}",
                  ),

                  Text(
                    "Payment: ${deal['payment']}",
                  ),
                ],
              ),

              trailing: Text(
                "₹${deal['total']}",
              ),
            ),
          );
        },
      ),
    );
  }
}