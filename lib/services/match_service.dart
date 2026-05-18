import 'package:supabase_flutter/supabase_flutter.dart';

class MatchService {
  static final supabase = Supabase.instance.client;

  static Future<void> runMatching() async {
    final offers = await supabase.from('capacity_offers').select();
    final requests = await supabase.from('capacity_requests').select();

    print("OFFERS: $offers");
    print("REQUESTS: $requests");

    for (final offer in offers) {
      for (final request in requests) {

        // ❌ skip same user
        if (offer['user_id'] == request['user_id']) continue;

        // 🔥 REMOVE ALL STRICT CONDITIONS (FOR NOW)

        // ❌ Prevent duplicate
        final existing = await supabase
            .from('matches_log')
            .select()
            .eq('offer_id', offer['id'])
            .eq('request_id', request['id'])
            .maybeSingle();

        if (existing != null) continue;

        // ✅ FORCE INSERT MATCH
        final res = await supabase.from('matches_log').insert({
          'offer_id': offer['id'],
          'request_id': request['id'],
          'buyer_id': request['user_id'],
          'supplier_id': offer['user_id'],
          'match_score': 100,
          'deal_status': 'pending',
          'payment_status': 'pending',
        });

        print("MATCH INSERTED: $res");
      }
    }
  }
}