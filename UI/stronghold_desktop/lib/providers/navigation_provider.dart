import 'package:flutter/foundation.dart';

/// Ekrani do kojih se moze programski navigirati (npr. sa dashboarda).
enum NavTarget { checkIn, users, memberships, payments, supplements, orders }

/// Namjera koju odredisni ekran izvrsava nakon prebacivanja
/// (npr. otvori dijalog za kreiranje ili detalje konkretnog zapisa).
class NavIntent {
  final NavTarget target;
  final String? action;
  final int? entityId;

  const NavIntent(this.target, {this.action, this.entityId});
}

/// Most izmedju ekrana i MainLayout-a: ekran zatrazi prebacivanje,
/// MainLayout preuzme target, a odredisni ekran preuzme intent.
class NavigationProvider extends ChangeNotifier {
  NavTarget? _pendingTarget;
  NavIntent? _pendingIntent;

  NavTarget? get pendingTarget => _pendingTarget;

  void go(NavTarget target, {String? action, int? entityId}) {
    _pendingTarget = target;
    _pendingIntent = action == null && entityId == null
        ? null
        : NavIntent(target, action: action, entityId: entityId);
    notifyListeners();
  }

  /// MainLayout javlja da je prebacivanje obavljeno.
  void confirmTarget() => _pendingTarget = null;

  /// Odredisni ekran preuzima (i time gasi) svoju namjeru.
  NavIntent? takeIntent(NavTarget target) {
    if (_pendingIntent?.target != target) return null;
    final intent = _pendingIntent;
    _pendingIntent = null;
    return intent;
  }
}
