import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qapto_app/services/match_service.dart';

class AddCapacityRequestScreen extends StatefulWidget {
  const AddCapacityRequestScreen({super.key});

  @override
  State<AddCapacityRequestScreen> createState() =>
      _AddCapacityRequestScreenState();
}

class _AddCapacityRequestScreenState
    extends State<AddCapacityRequestScreen> {
  final machineController = TextEditingController();
  final hoursController = TextEditingController();
  final maxRateController = TextEditingController();
  final locationController = TextEditingController();

  bool loading = false;

  Future<void> submitRequest() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    if (machineController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill required fields')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ 1. INSERT REQUEST
      final request = await Supabase.instance.client
          .from('capacity_requests')
          .insert({
            'user_id': user.id,
            'machine_type_needed': machineController.text.trim(),
            'hours_required':
                int.tryParse(hoursController.text.trim()) ?? 0,
            'max_hourly_rate':
                double.tryParse(maxRateController.text.trim()) ?? 0,
            'location': locationController.text.trim(),
            'status': 'open',
          })
          .select()
          .single();

      print("REQUEST CREATED: $request");

      // ✅ 2. FORCE MATCH CREATION (IMPORTANT)
      final offers = await Supabase.instance.client
          .from('capacity_offers')
          .select();

      for (final offer in offers) {
        if (offer['user_id'] == user.id) continue;

        await Supabase.instance.client.from('matches_log').insert({
          'offer_id': offer['id'],
          'request_id': request['id'],
          'buyer_id': request['user_id'],
          'supplier_id': offer['user_id'],
          'match_score': 100,
          'deal_status': 'pending',
          'payment_status': 'pending',
        });

        print("MATCH CREATED for request");
      }

      // ✅ 3. OPTIONAL MATCH SERVICE (secondary)
      await MatchService.runMatching();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request + Matches created')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    machineController.dispose();
    hoursController.dispose();
    maxRateController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Capacity Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: machineController,
              decoration: const InputDecoration(
                labelText: 'Machine / Process Needed *',
              ),
            ),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Hours Required'),
            ),
            TextField(
              controller: maxRateController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Max Hourly Rate'),
            ),
            TextField(
              controller: locationController,
              decoration:
                  const InputDecoration(labelText: 'Location *'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : submitRequest,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}