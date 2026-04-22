import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/listing_detail_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/confirmation_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/inbox/inbox_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/listings/create_listing_screen.dart';
import '../screens/listings/edit_listing_screen.dart';
import '../screens/listings/availability_screen.dart';
import '../screens/reviews/submit_review_screen.dart';
import '../screens/reports/create_report_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/settings/payment_methods_screen.dart';
import '../screens/settings/language_screen.dart';
import '../screens/settings/privacy_security_screen.dart';
import '../screens/settings/cnic_verification_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_listings_screen.dart';
import '../screens/admin/admin_bookings_screen.dart';
import '../screens/admin/admin_payouts_screen.dart';
import '../screens/admin/admin_reports_screen.dart';

class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/home';
  static const String search = '/search';
  static const String browse = '/browse';
  static const String listingDetail = '/listing-detail';

  // Booking flow
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String confirmation = '/confirmation';

  // User
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String inbox = '/inbox';
  static const String chat = '/chat';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String paymentMethods = '/payment-methods';
  static const String languageSettings = '/language';
  static const String privacySecurity = '/privacy-security';
  static const String cnicVerification = '/cnic-verification';

  // Listings management
  static const String createListing = '/create-listing';
  static const String editListing = '/edit-listing';
  static const String availability = '/availability';

  // Reviews & Reports
  static const String submitReview = '/submit-review';
  static const String createReport = '/create-report';

  // Admin
  static const String adminAnalytics = '/admin/analytics';
  static const String adminUsers = '/admin/users';
  static const String adminListings = '/admin/listings';
  static const String adminBookings = '/admin/bookings';
  static const String adminPayouts = '/admin/payouts';
  static const String adminReports = '/admin/reports';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        home: (_) => const HomeScreen(),
        search: (_) => const SearchScreen(),
        browse: (_) => const BrowseScreen(),
        listingDetail: (_) => const ListingDetailScreen(),
        booking: (_) => const BookingScreen(),
        payment: (_) => const PaymentScreen(),
        confirmation: (_) => const ConfirmationScreen(),
        dashboard: (_) => const DashboardScreen(),
        notifications: (_) => const NotificationsScreen(),
        inbox: (_) => const InboxScreen(),
        chat: (_) => const ChatScreen(),
        saved: (_) => const SavedScreen(),
        profile: (_) => const ProfileScreen(),
        editProfile: (_) => const EditProfileScreen(),
        paymentMethods: (_) => const PaymentMethodsScreen(),
        languageSettings: (_) => const LanguageScreen(),
        privacySecurity: (_) => const PrivacySecurityScreen(),
        cnicVerification: (_) => const CnicVerificationScreen(),
        createListing: (_) => const CreateListingScreen(),
        editListing: (_) => const EditListingScreen(),
        availability: (_) => const AvailabilityScreen(),
        submitReview: (_) => const SubmitReviewScreen(),
        createReport: (_) => const CreateReportScreen(),
        adminAnalytics: (_) => const AdminAnalyticsScreen(),
        adminUsers: (_) => const AdminUsersScreen(),
        adminListings: (_) => const AdminListingsScreen(),
        adminBookings: (_) => const AdminBookingsScreen(),
        adminPayouts: (_) => const AdminPayoutsScreen(),
        adminReports: (_) => const AdminReportsScreen(),
      };
}
