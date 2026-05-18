import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qapto_app/services/match_service.dart';

class AddCapacityOfferScreen extends StatefulWidget {
  const AddCapacityOfferScreen({super.key});

  @override
  State<AddCapacityOfferScreen> createState() =>
      _AddCapacityOfferScreenState();
}

class _AddCapacityOfferScreenState
    extends State<AddCapacityOfferScreen> {
  final machineController = TextEditingController();
  final hoursController = TextEditingController();
  final rateController = TextEditingController();
  final locationController = TextEditingController();

  bool loading = false;

  Future<void> submitOffer() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() => loading = true);

    try {
      // ✅ 1. INSERT OFFER
      final offer = await Supabase.instance.client
          .from('capacity_offers')
          .insert({
            'user_id': user.id,
            'machine_type': machineController.text.trim(),
            'available_hours_per_day':
                int.tryParse(hoursController.text.trim()) ?? 0,
            'hourly_rate':
                double.tryParse(rateController.text.trim()) ?? 0,
            'location': locationController.text.trim(),
            'is_active': true,
          })
          .select()
          .single();

      print("OFFER CREATED: $offer");

      // ✅ 2. FORCE MATCH CREATION
      final requests = await Supabase.instance.client
          .from('capacity_requests')
          .select();

      for (final request in requests) {
        if (request['user_id'] == user.id) continue;

        await Supabase.instance.client.from('matches_log').insert({
          'offer_id': offer['id'],
          'request_id': request['id'],
          'buyer_id': request['user_id'],
          'supplier_id': offer['user_id'],
          'match_score': 100,
          'deal_status': 'pending',
          'payment_status': 'pending',
        });

        print("MATCH CREATED for offer");
      }

      // ✅ 3. OPTIONAL MATCH SERVICE
      await MatchService.runMatching();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer + Matches created')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    machineController.dispose();
    hoursController.dispose();
    rateController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Capacity Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: machineController,
              decoration: const InputDecoration(
                labelText: 'Machine / Process Type',
              ),
            ),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Available Hours per Day',
              ),
            ),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Hourly Rate'),
            ),
            TextField(
              controller: locationController,
              decoration:
                  const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : submitOffer,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Offer'),
            ),
          ],
        ),
      ),
    );
  }
}