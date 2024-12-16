import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/custom_builder.dart';
import 'package:nomnom/app/enums/transition_enum.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/views/auth_children/account_completion_page.dart';
import 'package:nomnom/views/auth_children/main_login_page.dart';
import 'package:nomnom/views/auth_children/otp_verification.dart';
import 'package:nomnom/views/landing_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page.dart';
import 'package:nomnom/views/navigation_page.dart';
import 'package:nomnom/views/splash_screen.dart';

class GoRouterObserver extends NavigatorObserver {
  GoRouterObserver({required this.analytics});
  final FirebaseAnalytics analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    analytics.logScreenView(screenName: route.settings.name);
  }
}

class RouteConfig {
  RouteConfig._pr();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  static final RouteConfig _instance = RouteConfig._pr();
  static RouteConfig get instance => _instance;
  GoRouter get router => _router;
  final GoRouter _router = GoRouter(
      observers: [GoRouterObserver(analytics: analytics)],
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
            path: "/",
            pageBuilder: (BuildContext context, GoRouterState state) =>
                buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const SplashScreen(),
                  type: ZTransitionAnim.fade,
                ),
            routes: [
              GoRoute(
                  path: 'navigation-page',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      buildPageWithDefaultTransition(
                        context: context,
                        state: state,
                        child: const NavigationPage(),
                        type: ZTransitionAnim.fade,
                      ),
                  routes: [
                    GoRoute(
                      path: 'restaurant-listing-page',
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              buildPageWithDefaultTransition(
                        context: context,
                        state: state,
                        child: const RestaurantPage(),
                        type: ZTransitionAnim.fade,
                      ),
                    )
                  ]),
              GoRoute(
                path: "landing-page",
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const LandingPage(),
                  type: ZTransitionAnim.fade,
                ),
              ),
              GoRoute(
                  path: "account-completion-page",
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final UserModel? update = state.extra as UserModel?;
                    return buildPageWithDefaultTransition(
                      context: context,
                      state: state,
                      child: AccountCompletionPage(
                        toUpdate: update,
                      ),
                      type: ZTransitionAnim.fade,
                    );
                  }),
              GoRoute(
                  path: "main-login-page",
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      buildPageWithDefaultTransition(
                        context: context,
                        state: state,
                        child: const MainLoginPage(),
                        type: ZTransitionAnim.fade,
                      ),
                  routes: [
                    GoRoute(
                      path: "otp-verification-page/:verification_id/:phone",
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              buildPageWithDefaultTransition(
                        context: context,
                        state: state,
                        child: OtpVerificationPage(
                          phoneNumber: state.pathParameters['phone'] as String,
                          verificationID:
                              state.pathParameters['verification_id'] as String,
                        ),
                        type: ZTransitionAnim.fade,
                      ),
                    )
                  ]),
            ])
      ]);
}
