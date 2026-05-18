import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentScreen extends StatefulWidget {
  final String matchId;
  final double totalAmount;
  final double platformFee;

  const PaymentScreen({
    super.key,
    required this.matchId,
    required this.totalAmount,
    required this.platformFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();

    // ✅ ONLY for mobile
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    }
  }

  void openCheckout() {
    final amount = widget.totalAmount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount")),
      );
      return;
    }

    // ❌ BLOCK WEB (no dart:js crash)
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Web payment not supported yet")),
      );
      return;
    }

    // ✅ MOBILE PAYMENT
    var options = {
      'key': 'rzp_test_SmoH9K7exjlZF4',
      'amount': (amount * 100).toInt(),
      'name': 'QAPTO',
      'description': 'Deal Payment',
    };

    _razorpay!.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await Supabase.instance.client
        .from('matches_log')
        .update({'payment_status': 'paid'})
        .eq('id', widget.matchId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful")),
    );

    Navigator.pop(context, true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Amount: ₹${widget.totalAmount}",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Platform Fee: ₹${widget.platformFee}",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text("Deal Status: confirmed"),
            const Text("Payment Status: pending"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: openCheckout,
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}