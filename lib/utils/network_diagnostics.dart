import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkDiagnostics {
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    print('🔍 Running network diagnostics...');

    // Check basic connectivity
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      results['connectivity'] = {
        'status': connectivityResult.toString(),
        'hasConnection': connectivityResult != ConnectivityResult.none,
      };
      print('📡 Connectivity: $connectivityResult');
    } catch (e) {
      results['connectivity'] = {
        'status': 'error',
        'error': e.toString(),
        'hasConnection': false,
      };
      print('❌ Connectivity check failed: $e');
    }

    // Test DNS resolution for common services
    final testHosts = [
      'google.com',
      'supabase.co',
      'heulzxrulgrplrbkkqjt.supabase.co',
    ];

    results['dns_tests'] = {};

    for (final host in testHosts) {
      try {
        print('🔍 Testing DNS for: $host');
        final addresses = await InternetAddress.lookup(host);
        results['dns_tests'][host] = {
          'status': 'success',
          'addresses': addresses.map((addr) => addr.address).toList(),
        };
        print(
            '✅ $host resolved to: ${addresses.map((addr) => addr.address).join(', ')}');
      } catch (e) {
        results['dns_tests'][host] = {
          'status': 'failed',
          'error': e.toString(),
        };
        print('❌ $host DNS failed: $e');
      }
    }

    // Test HTTP connectivity
    try {
      print('🌐 Testing HTTP connectivity...');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(Uri.parse('https://httpbin.org/get'));
      final response = await request.close();

      results['http_test'] = {
        'status': 'success',
        'statusCode': response.statusCode,
      };
      print('✅ HTTP test successful: ${response.statusCode}');

      client.close();
    } catch (e) {
      results['http_test'] = {
        'status': 'failed',
        'error': e.toString(),
      };
      print('❌ HTTP test failed: $e');
    }

    // Test Supabase specific endpoint
    try {
      print('🔍 Testing Supabase endpoint...');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(
          Uri.parse('https://heulzxrulgrplrbkkqjt.supabase.co/rest/v1/'));
      request.headers.set('apikey',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWx6eHJ1bGdycGxyYmtrcWp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxOTQwNDEsImV4cCI6MjA2ODc3MDA0MX0.LwAmMU4nTphb65wOUFsUJ9tQ8lqHbC4wCZX7kHfO7e4');
      final response = await request.close();

      results['supabase_test'] = {
        'status': 'success',
        'statusCode': response.statusCode,
      };
      print('✅ Supabase endpoint test successful: ${response.statusCode}');

      client.close();
    } catch (e) {
      results['supabase_test'] = {
        'status': 'failed',
        'error': e.toString(),
      };
      print('❌ Supabase endpoint test failed: $e');
    }

    return results;
  }

  static String generateReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('🔍 Network Diagnostics Report');
    buffer.writeln('=' * 40);

    // Connectivity
    final connectivity = results['connectivity'] as Map<String, dynamic>?;
    if (connectivity != null) {
      buffer.writeln('📡 Connectivity: ${connectivity['status']}');
      if (connectivity['hasConnection'] == true) {
        buffer.writeln('✅ Network connection available');
      } else {
        buffer.writeln('❌ No network connection');
      }
    }

    buffer.writeln();

    // DNS Tests
    buffer.writeln('🔍 DNS Resolution Tests:');
    final dnsTests = results['dns_tests'] as Map<String, dynamic>?;
    if (dnsTests != null) {
      dnsTests.forEach((host, result) {
        if (result['status'] == 'success') {
          buffer
              .writeln('✅ $host: ${(result['addresses'] as List).join(', ')}');
        } else {
          buffer.writeln('❌ $host: ${result['error']}');
        }
      });
    }

    buffer.writeln();

    // HTTP Test
    final httpTest = results['http_test'] as Map<String, dynamic>?;
    if (httpTest != null) {
      if (httpTest['status'] == 'success') {
        buffer.writeln('✅ HTTP connectivity: ${httpTest['statusCode']}');
      } else {
        buffer.writeln('❌ HTTP connectivity: ${httpTest['error']}');
      }
    }

    buffer.writeln();

    // Supabase Test
    final supabaseTest = results['supabase_test'] as Map<String, dynamic>?;
    if (supabaseTest != null) {
      if (supabaseTest['status'] == 'success') {
        buffer.writeln('✅ Supabase endpoint: ${supabaseTest['statusCode']}');
      } else {
        buffer.writeln('❌ Supabase endpoint: ${supabaseTest['error']}');
      }
    }

    return buffer.toString();
  }
}

