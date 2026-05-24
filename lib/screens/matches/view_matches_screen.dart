import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'match_detail_screen.dart';

class ViewMatchesScreen extends StatefulWidget {
  const ViewMatchesScreen({super.key});

  @override
  State<ViewMatchesScreen> createState() => _ViewMatchesScreenState();
}

class _ViewMatchesScreenState extends State<ViewMatchesScreen> {
  List offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('capacity_offers')
          .select();

      final filtered =
          data.where((o) => o['user_id'] != user.id).toList();

      setState(() {
        offers = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR FETCHING OFFERS: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openMatch(Map offer) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {
      print("CARD CLICKED");

      final existingList = await Supabase.instance.client
          .from('matches_log')
          .select()
          .eq('offer_id', offer['id'])
          .eq('buyer_id', user.id)
          .limit(1);

      dynamic existing = existingList.isNotEmpty
          ? existingList.first
          : null;

      dynamic match;

      if (existing != null) {
        match = existing;
      } else {
        match = await Supabase.instance.client
            .from('matches_log')
            .insert({
              'offer_id': offer['id'],
              'buyer_id': user.id,
              'supplier_id': offer['user_id'],
              'deal_status': 'pending',
              'payment_status': 'pending',
            })
            .select()
            .single();
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(
            matchId: match['id'],
          ),
        ),
      );
    } catch (e) {
      print("MATCH ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> removeMatch(Map offer, int index) async {
    try {
      await Supabase.instance.client
          .from('matches_log')
          .delete()
          .eq('offer_id', offer['id']);

      setState(() {
        offers.removeAt(index);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Match removed"),
        ),
      );
    } catch (e) {
      print("REMOVE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (offers.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No offers found"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Offers"),
      ),

      body: ListView.builder(
        itemCount: offers.length,

        itemBuilder: (context, index) {
          final offer = offers[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: InkWell(
              onTap: () {
                openMatch(offer);
              },

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            offer['machine_type']
                                    ?? 'Machine',

                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Location: ${offer['location'] ?? 'No location'}",
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Rate: ₹${offer['hourly_rate'] ?? 0}",
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),

                      onPressed: () {
                        removeMatch(offer, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}