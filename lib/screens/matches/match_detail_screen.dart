import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qapto_app/screens/finance/payment_screen.dart';
import 'package:qapto_app/screens/chat/chat_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchDetailScreen> createState() =>
      _MatchDetailScreenState();
}

class _MatchDetailScreenState
    extends State<MatchDetailScreen> {

  Map<String, dynamic>? data;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {

    try {

      final match = await Supabase.instance.client
          .from('matches_log')
          .select()
          .eq('id', widget.matchId)
          .single();

      final offer = await Supabase.instance.client
          .from('capacity_offers')
          .select()
          .eq('id', match['offer_id'])
          .maybeSingle();

      final rate =
          (offer?['hourly_rate'] ?? 0).toDouble();

      final hours =
          (offer?['available_hours_per_day'] ?? 1)
              .toDouble();

      setState(() {

        data = {

          'machine':
              offer?['machine_type'] ?? 'Machine',

          'location':
              offer?['location'] ?? 'Unknown',

          'rate': rate,

          'hours': hours,

          'total': rate * hours,

          'fee': rate * hours * 0.1,

          'deal_status':
              match['deal_status'] ?? 'pending',

          'payment_status':
              match['payment_status'] ?? 'pending',

          'paid_at':
              match['paid_at'],
        };

        loading = false;
      });

    } catch (e) {

      print("ERROR: $e");

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> cancelDeal() async {

    final paidAt = data?['paid_at'];

    if (paidAt == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Deal not paid yet",
          ),
        ),
      );

      return;
    }

    final paidTime =
        DateTime.parse(paidAt);

    final difference =
        DateTime.now()
            .difference(paidTime)
            .inHours;

    if (difference > 24) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cancellation window expired",
          ),
        ),
      );

      return;
    }

    await Supabase.instance.client
        .from('matches_log')
        .update({
          'deal_status': 'cancelled',
        })
        .eq('id', widget.matchId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Deal cancelled successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (loading || data == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Deal Summary",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              "Machine: ${data!['machine']}",
            ),

            Text(
              "Location: ${data!['location']}",
            ),

            Text(
              "Rate: ₹${data!['rate']}",
            ),

            Text(
              "Hours: ${data!['hours']}",
            ),

            const SizedBox(height: 20),

            const Divider(),

            Text(
              "Total: ₹${data!['total']}",

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "Platform Fee: ₹${data!['fee']}",

              style: const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Deal: ${data!['deal_status']}",
            ),

            Text(
              "Payment: ${data!['payment_status']}",
            ),

            const Spacer(),

            // CHAT
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        matchId: widget.matchId,
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Chat",
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ❌ CANCEL DEAL
            if (data!['payment_status']
                    == 'confirmed')

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: cancelDeal,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                  ),

                  child: const Text(
                    "Cancel Deal",
                  ),
                ),
              ),

            if (data!['payment_status']
                    == 'confirmed')

              const SizedBox(height: 10),

            //  PAYMENT
            if (data!['payment_status']
                    != 'confirmed')

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            PaymentScreen(
                          matchId:
                              widget.matchId,

                          totalAmount:
                              data!['total'],

                          platformFee:
                              data!['fee'],
                        ),
                      ),
                    );
                  },

                  child: const Text(
                    "Proceed to Payment",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}