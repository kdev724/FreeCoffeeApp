import 'package:flutter/material.dart';
import 'services/coffee_redemption_service.dart';
import 'utils/responsive_helper.dart';

class RedemptionHistoryPage extends StatefulWidget {
  const RedemptionHistoryPage({super.key});

  @override
  State<RedemptionHistoryPage> createState() => _RedemptionHistoryPageState();
}

class _RedemptionHistoryPageState extends State<RedemptionHistoryPage> {
  List<Map<String, dynamic>> _redemptions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
  }

  Future<void> _loadRedemptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final redemptions = await CoffeeRedemptionService.getUserRedemptions();

      setState(() {
        _redemptions = redemptions;
        _isLoading = false;
      });
    } catch (error) {
      String errorMessage = error.toString();

      // Handle specific authentication errors
      if (errorMessage.contains('JWT expired') ||
          errorMessage.contains('Session expired') ||
          errorMessage.contains('Unauthorized')) {
        errorMessage = 'Your session has expired. Please log in again.';
      } else if (errorMessage.contains('No authenticated user')) {
        errorMessage = 'Please log in to view your redemption history.';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.pending;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coffee Redemption History',
          style: TextStyle(
            color: Colors.brown.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.brown.shade700),
            onPressed: _loadRedemptions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf8f7f6),
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your redemptions...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading redemptions',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _loadRedemptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC69C6D),
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Try Again'),
                            ),
                            SizedBox(width: 16),
                            if (_error?.contains('session has expired') ==
                                    true ||
                                _error?.contains('Please log in') == true)
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate back to login
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Log In Again'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : _redemptions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No coffee redemptions yet',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 18),
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your coffee bag redemptions will appear here',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 14),
                                color: Colors.grey.shade400,
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveHelper.getResponsivePadding(
                                    context, 24)),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.coffee),
                              label: Text('Redeem Coffee'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC69C6D),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRedemptions,
                        color: Color(0xFFC69C6D),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _redemptions.length,
                          itemBuilder: (context, index) {
                            final redemption = _redemptions[index];
                            final status = redemption['status'] ?? 'pending';

                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with status
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _getStatusColor(status),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getStatusIcon(status),
                                                size: 16,
                                                color: _getStatusColor(status),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  color:
                                                      _getStatusColor(status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ResponsiveHelper
                                                      .getResponsiveFontSize(
                                                          context, 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          '${redemption['credits_spent']} credits',
                                          style: TextStyle(
                                            color: Color(0xFFC69C6D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: ResponsiveHelper
                                                .getResponsiveFontSize(
                                                    context, 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    // Redemption date
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Redeemed: ${_formatDate(redemption['redemption_date'])}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: ResponsiveHelper
                                                .getResponsiveFontSize(
                                                    context, 14),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Shipping address
                                    if (redemption['shipping_address'] !=
                                        null) ...[
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Address: ${redemption['shipping_address']}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: ResponsiveHelper
                                                    .getResponsiveFontSize(
                                                        context, 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Tracking number
                                    if (redemption['tracking_number'] !=
                                        null) ...[
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_shipping,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Tracking: ${redemption['tracking_number']}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: ResponsiveHelper
                                                    .getResponsiveFontSize(
                                                        context, 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Notes
                                    if (redemption['notes'] != null &&
                                        redemption['notes'].isNotEmpty) ...[
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.note,
                                              size: 16,
                                              color: Colors.blue.shade600,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                redemption['notes'],
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: ResponsiveHelper
                                                      .getResponsiveFontSize(
                                                          context, 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
