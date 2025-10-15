class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'https://heulzxrulgrplrbkkqjt.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWx6eHJ1bGdycGxyYmtrcWp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxOTQwNDEsImV4cCI6MjA2ODc3MDA0MX0.LwAmMU4nTphb65wOUFsUJ9tQ8lqHbC4wCZX7kHfO7e4';

  // Social login redirect URLs for mobile apps
  static const String googleRedirectUrl =
      'io.supabase.flutter://login-callback/';
  static const String facebookRedirectUrl =
      'io.supabase.flutter://login-callback/';
  static const String appleRedirectUrl =
      'io.supabase.flutter://login-callback/';

  // For web development (if needed)
}
