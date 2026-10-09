import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://feptsrjqqjztozrajiga.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlcHRzcmpxcWp6dG96cmFqaWdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE1Mzg5OTIsImV4cCI6MjEwNzExNDk5Mn0.nzj7KHBs3SxVqex707CuvJGc63P-mnwVwhQc9Vj8Z3o',
  );

  static bool isInitialized = false;

  static Future<void> initialize() async {
    try {
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
        );
        isInitialized = true;
      }
    } catch (e) {
      // Graceful fallback if URL/Key is invalid or client fails to initialize
      isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (!isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
