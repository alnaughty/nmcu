import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/enums/transition_enum.dart';

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required ZTransitionAnim type,
  Alignment? alignment,
  Curve? curve,
}) {
  return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case ZTransitionAnim.fade:
            return FadeTransition(opacity: animation, child: child);
          case ZTransitionAnim.scale:
            alignment ??= Alignment.center;
            assert((alignment != null) || (curve != null), """
                When using type "scale" you need argument: 'alignment && curve'
                """);
            // this.curve = Curves.linear
            return ScaleTransition(
              alignment: alignment!,
              scale: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.00,
                  0.50,
                  curve: curve!,
                ),
              ),
              child: child,
            );
          case ZTransitionAnim.slideRL:
            var slideTransition = SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
            return slideTransition;
          case ZTransitionAnim.slideLR:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case ZTransitionAnim.slideBT:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case ZTransitionAnim.slideTB:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      }
      // transition ?? FadeTransition(opacity: animation, child: child),
      );
}
