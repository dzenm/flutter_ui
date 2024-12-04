import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2024/12/3 15:31
///
/// A mock authentication service.
class LoginAuth extends ChangeNotifier {
  bool _signedIn = SPManager.getUserLoginState();

  /// Whether user has signed in.
  bool get signedIn => _signedIn;

  /// Signs out the current user.
  Future<void> signOut() async {
    // await Future<void>.delayed(const Duration(milliseconds: 100));
    // Sign out.
    _signedIn = false;
    notifyListeners();
  }

  /// Signs in a user.
  Future<bool> signIn(String username, String password) async {
    // await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }
}

/// An inherited notifier to host [LoginAuth] for the subtree.
class LoginAuthScope extends InheritedNotifier<LoginAuth> {
  /// Creates a [LoginAuthScope].
  const LoginAuthScope({
    required LoginAuth super.notifier,
    required super.child,
    super.key,
  });

  /// Gets the [LoginAuth] above the context.
  static LoginAuth of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<LoginAuthScope>()!.notifier!;
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => FadeTransition(
        opacity: animation.drive(_curveTween),
        child: child,
      ));

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
