import 'package:go_router/go_router.dart';

import '../features/applications/models/application.dart';
import '../features/applications/presentation/application_details_screen.dart';
import '../features/applications/presentation/application_form_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/role_gate_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/explore/presentation/opportunity_details_screen.dart';
import '../features/main/presentation/main_shell.dart';
import '../features/organization/presentation/create_opportunity_screen.dart';
import '../features/organization/presentation/manage_volunteers_screen.dart';
import '../features/organization/presentation/my_opportunities_screen.dart';
import '../features/organization/presentation/organization_dashboard_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/saved_opportunities_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/volunteer_history_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ============================================================
      // AUTHENTICATION
      // ============================================================

      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) =>
            const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) =>
            const OnboardingScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) =>
            const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) =>
            const SignupScreen(),
      ),

      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) =>
            const ForgotPasswordScreen(),
      ),

      // ============================================================
      // ROLE DETECTION
      // ============================================================

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) =>
            const RoleGateScreen(),
      ),

      // ============================================================
      // VOLUNTEER APP
      // ============================================================

      GoRoute(
        path: '/volunteer',
        name: 'volunteer',
        builder: (context, state) =>
            const MainShell(),
      ),

      // ============================================================
      // ORGANIZATION APP
      // ============================================================

      GoRoute(
        path: '/organization',
        name: 'organization',
        builder: (context, state) =>
            const OrganizationDashboardScreen(),
      ),

      GoRoute(
        path: '/organization/create-opportunity',
        name: 'organization-create-opportunity',
        builder: (context, state) =>
            const CreateOpportunityScreen(),
      ),

      GoRoute(
        path: '/organization/my-opportunities',
        name: 'organization-my-opportunities',
        builder: (context, state) =>
            const MyOpportunitiesScreen(),
      ),

      GoRoute(
        path: '/organization/manage-volunteers',
        name: 'organization-manage-volunteers',
        builder: (context, state) =>
            const ManageVolunteersScreen(),
      ),

      // ============================================================
      // OPPORTUNITIES
      // ============================================================

      GoRoute(
        path: '/opportunity/:id',
        name: 'opportunity-details',
        builder: (context, state) {
          final opportunityId =
              state.pathParameters['id']!;

          return OpportunityDetailsScreen(
            opportunityId: opportunityId,
          );
        },
      ),

      GoRoute(
        path: '/opportunity/:id/apply',
        name: 'application-form',
        builder: (context, state) {
          final opportunityId =
              state.pathParameters['id']!;

          return ApplicationFormScreen(
            opportunityId: opportunityId,
          );
        },
      ),

      // ============================================================
      // APPLICATIONS
      // ============================================================

      GoRoute(
        path: '/application/:id',
        name: 'application-details',
        builder: (context, state) {
          final applicationId =
              state.pathParameters['id']!;

          final applications =
              Application.mockApplications();

          final application =
              applications.firstWhere(
            (item) => item.id == applicationId,
            orElse: () => applications.first,
          );

          return ApplicationDetailsScreen(
            application: application,
          );
        },
      ),

      // ============================================================
      // PROFILE
      // ============================================================

      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) =>
            const EditProfileScreen(),
      ),

      GoRoute(
        path: '/profile/saved',
        name: 'saved-opportunities',
        builder: (context, state) =>
            const SavedOpportunitiesScreen(),
      ),

      GoRoute(
        path: '/profile/history',
        name: 'volunteer-history',
        builder: (context, state) =>
            const VolunteerHistoryScreen(),
      ),

      GoRoute(
        path: '/profile/settings',
        name: 'profile-settings',
        builder: (context, state) =>
            const SettingsScreen(),
      ),
    ],
  );
}