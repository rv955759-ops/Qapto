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
    if (user == null) return;

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
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openMatch(Map offer) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // 🔥 CHECK EXISTING MATCH (PREVENT DUPLICATE)
      final existing = await Supabase.instance.client
          .from('matches_log')
          .select()
          .eq('offer_id', offer['id'])
          .eq('buyer_id', user.id)
          .maybeSingle();

      dynamic match;

      if (existing != null) {
        match = existing;
      } else {
        // 🔥 CREATE MATCH
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (offers.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No offers found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Available Offers")),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(offer['machine_type'] ?? 'Machine'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location: ${offer['location']}"),
                  Text("Rate: ₹${offer['hourly_rate']}"),
                ],
              ),
              onTap: () => openMatch(offer),
            ),
          );
        },
      ),
    );
  }
}