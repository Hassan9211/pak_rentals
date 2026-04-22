import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';
import '../services/api_client.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await DashboardApi.get();
      final data = res['data'] as Map<String, dynamic>? ?? res;
      if (mounted) setState(() { _data = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Connection failed'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _error != null
                      ? _buildError()
                      : RefreshIndicator(
                          color: AppColors.cyan,
                          backgroundColor: AppColors.bgCard,
                          onRefresh: _load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                _buildHero(),
                                _buildSection(context),
                              ],
                            ),
                          ),
                        ),
            ),
            AppBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(_error!, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(8)),
              child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = UserState();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogo(),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: const Center(child: Text('🔔', style: TextStyle(fontSize: 15))),
                ),
              ),
              const SizedBox(width: 8),
              UserAvatar(initials: user.initials),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final user = UserState();
    final data = _data ?? {};
    final unread = data['unread_count'] as int? ?? 0;
    final pendingPayments = data['pending_payments_count'] as int? ?? 0;
    final openReports = data['open_reports_count'] as int? ?? 0;

    final myBookings = (data['my_bookings'] as List?)?.length ?? 0;
    final myListings = (data['my_listings'] as List?)?.length ?? 0;
    final hostRequests = (data['host_requests'] as List?)?.length ?? 0;

    final stats = [
      {'label': 'My Listings', 'val': '$myListings', 'sub': hostRequests > 0 ? '$hostRequests requests' : 'Active'},
      {'label': 'My Bookings', 'val': '$myBookings', 'sub': pendingPayments > 0 ? '$pendingPayments pending pay' : 'All paid'},
      {'label': 'Messages', 'val': '$unread', 'sub': unread > 0 ? 'Unread' : 'No new'},
      {'label': 'Reports', 'val': '$openReports', 'sub': openReports > 0 ? 'Open' : 'All clear'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, AppColors.bgCard],
        ),
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
          Text(user.name, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: stats.map((s) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s['label']!, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
                  Text(s['val']!, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(s['sub']!, style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.cyan)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    final data = _data ?? {};
    final myListings = (data['my_listings'] as List?) ?? [];
    final myBookings = (data['my_bookings'] as List?) ?? [];
    final hostRequests = (data['host_requests'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Listings
          SectionHeader(
            title: 'My Listings',
            action: 'Manage all',
            onAction: () => Navigator.pushNamed(context, '/create-listing'),
          ),
          const SizedBox(height: 10),
          if (myListings.isEmpty)
            _emptyCard('No listings yet', 'Tap + to create your first listing')
          else
            ...myListings.take(4).map((l) {
              final listing = Listing.fromJson(l as Map<String, dynamic>);
              return _listingRow(listing);
            }),

          if (hostRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeader(title: 'Booking Requests', action: 'View all'),
            const SizedBox(height: 10),
            ...hostRequests.take(3).map((b) => _bookingRequestRow(b as Map<String, dynamic>)),
          ],

          if (myBookings.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeader(title: 'My Bookings', action: 'View all'),
            const SizedBox(height: 10),
            ...myBookings.take(3).map((b) => _myBookingRow(b as Map<String, dynamic>)),
          ],
        ],
      ),
    );
  }

  Widget _listingRow(Listing l) {
    final statusColor = l.status == 'approved'
        ? AppColors.success
        : l.status == 'pending'
            ? AppColors.warning
            : AppColors.error;
    final statusLabel = l.status == 'approved' ? 'Active' : l.status == 'pending' ? 'Pending' : l.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: l.bgColor, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text(l.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('PKR ${l.price}${l.priceUnit}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }

  Widget _bookingRequestRow(Map<String, dynamic> b) {
    final listing = b['listing'] as Map<String, dynamic>?;
    final renter = b['renter'] as Map<String, dynamic>?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Text('📋', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing?['title'] as String? ?? 'Booking Request',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('From: ${renter?['name'] as String? ?? 'Renter'}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(label: 'Pending', color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _myBookingRow(Map<String, dynamic> b) {
    final listing = b['listing'] as Map<String, dynamic>?;
    final status = b['status'] as String? ?? 'pending';
    final statusColor = status == 'active' || status == 'confirmed'
        ? AppColors.success
        : status == 'pending'
            ? AppColors.warning
            : AppColors.textMuted;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          const Text('🏠', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing?['title'] as String? ?? 'Booking',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('${b['start_date'] ?? ''} → ${b['end_date'] ?? ''}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusBadge(label: status, color: statusColor),
        ],
      ),
    );
  }

  Widget _emptyCard(String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          const Text('📭', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text(sub, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
