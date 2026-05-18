import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:qapto_app/screens/auth/login_screen.dart';
import 'package:qapto_app/screens/offers/add_capacity_offer_screen.dart';
import 'package:qapto_app/screens/offers/my_offers_screen.dart';
import 'package:qapto_app/screens/requests/add_capacity_request_screen.dart';
import 'package:qapto_app/screens/requests/my_requests_screen.dart';
import 'package:qapto_app/screens/matches/view_matches_screen.dart';

import 'package:qapto_app/screens/finance/admin_earnings_screen.dart';
import 'package:qapto_app/screens/finance/supplier_earnings_screen.dart';
import 'package:qapto_app/screens/finance/buyer_spending_screen.dart';

import 'package:qapto_app/app_session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QAPTO Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // OFFERS
          const Text("Offers", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCapacityOfferScreen(),
                ),
              );
            },
            child: const Text('Add Capacity Offer'),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOffersScreen(), // ✅ FIX
                ),
              );
            },
            child: const Text('My Offers'),
          ),

          const SizedBox(height: 20),

          // REQUESTS
          const Text("Requests", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCapacityRequestScreen(),
                ),
              );
            },
            child: const Text('Add Capacity Request'),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyRequestsScreen(), // ✅ FIX
                ),
              );
            },
            child: const Text('My Requests'),
          ),

          const SizedBox(height: 20),

          // FINANCE
          const Text("Finance", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupplierEarningsScreen(),
                ),
              );
            },
            child: const Text("My Earnings"),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuyerSpendingScreen(),
                ),
              );
            },
            child: const Text("My Spending"),
          ),

          const SizedBox(height: 8),

          if (AppSession.role == 'admin')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminEarningsScreen(),
                  ),
                );
              },
              child: const Text("Admin Earnings"),
            ),

          const SizedBox(height: 20),

          // MATCHES
          const Text("Matches", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewMatchesScreen(),
                ),
              );
            },
            child: const Text('View Matches'),
          ),
        ],
      ),
    );
  }
}