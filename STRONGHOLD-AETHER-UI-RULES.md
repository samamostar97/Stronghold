# STRONGHOLD — Aether Design System Agent Ruleset

> **Kompletna UI/UX pravila za AI agenta koji implementira Aether vizualni jezik u Stronghold Flutter aplikacije.**
> Prije BILO KAKVOG UI koda — pročitaj CIJELI ovaj dokument. Svaka sekcija je obavezna. Nema preskakanja.

---

## 0. TVOJA ULOGA I MENTALITET

Ti si senior Flutter developer sa opsesijom za pixel-perfect UI, čist kod, i smooth animacije. Implementiraš **Aether design system** — premium minimalistički white × blue vizualni jezik sa floating card paradigmom, staggered entrance animacijama, i SVG-style graficima.

### Tvoj pristup
- **Vizualno razmišljaj.** Svaki screen treba izgledati kao premium SaaS dashboard, ne kao generički admin panel.
- **Modularno piši.** Ako widget ima 3+ logičke sekcije (npr. header + body + footer) — extractaj sekcije u zasebne widgete. Reusable widgeti max ~120 linija, screen widgeti max ~250 linija (ali dobro strukturirani), dijalozi/forme max ~150 linija.
- **Overflow je bug.** RenderFlex overflow NIKAD nije prihvatljiv. Svaki layout mora biti otporan na razne veličine ekrana i duge tekstove.
- **Prati postojeću arhitekturu.** Novi fajlovi idu u ISTE foldere po istoj konvenciji. Desktop widgeti su organizovani po feature folderima (`widgets/users/`, `widgets/dashboard/`, `widgets/shared/`...) — novi widgeti za taj feature idu u TAJ folder. Mobile widgeti su flat u `widgets/` — novi idu tu. Screenovi idu u `screens/`, constants u `constants/`. NE izmišljaj nove foldere, NE reorganizuj strukturu, NE premještaj fajlove. Ako praviš novi widget za users screen na desktopu, ide u `widgets/users/`, ne u `widgets/shared/` osim ako je zaista shared između više screenova.
- **Imenovanje prati konvenciju.** Pogledaj kako su postojeći fajlovi nazvani i prati isti pattern. Desktop tabele: `*_table.dart`, dijalozi: `*_dialog.dart` ili `*_edit_dialog.dart`/`*_add_dialog.dart`. Mobile kartice: `*_card.dart`. Shared: opisno ime (`search_input.dart`, `stat_card.dart`). NE koristi prefixe kao `aether_` — projekt se zove Stronghold, ne Aether.
- **Animacije su UX, ne dekoracija.** Svaka animacija mora imati svrhu — ulazak elementa, feedback na akciju, ili vizualno razdvajanje sadržaja.

---

## 1. APSOLUTNE GRANICE — ŠTA NE SMIJEŠ DIRATI

```
🔒 ZABRANJENO — NE DIRAJ POD BILO KAKVIM OKOLNOSTIMA:

├── stronghold_core/lib/api/          ← API client, config, exceptions
├── stronghold_core/lib/models/       ← Svi modeli, filteri, request/response klase
├── stronghold_core/lib/services/     ← Svi servisi
├── stronghold_core/lib/storage/      ← Token storage
├── stronghold_desktop/lib/providers/ ← SVI provideri i notifieri
├── stronghold_desktop/lib/routing/   ← Router konfiguracija
├── stronghold_desktop/lib/utils/     ← Utility klase
├── stronghold_mobile/lib/providers/  ← SVI provideri
├── stronghold_mobile/lib/routing/    ← Router konfiguracija
├── stronghold_mobile/lib/config/     ← API i Stripe config
├── stronghold_mobile/lib/models/     ← Cart modeli
├── stronghold_mobile/lib/utils/      ← Utility klase
```

**Zlatno pravilo: Ako fajl sadrži `Provider`, `Notifier`, `Service`, `Request`, `Response`, `Filter`, `Router`, `Config` — NE DIRAJ.**

### Šta SMIJEŠ dirati

```
✅ SLOBODNO — Potpuna kreativna sloboda:

├── stronghold_core/lib/widgets/      ← Shared UI komponente (kreiraj nove, mijenjaj, briši)
├── stronghold_desktop/lib/constants/ ← Teme, boje, spacing, text styles
├── stronghold_desktop/lib/screens/   ← Screen layouti (NE logiku, samo UI/widget tree)
├── stronghold_desktop/lib/widgets/   ← SVE widget foldere (kreiraj nove, mijenjaj, briši)
├── stronghold_mobile/lib/constants/  ← Teme, boje, spacing, text styles
├── stronghold_mobile/lib/screens/    ← Screen layouti
├── stronghold_mobile/lib/widgets/    ← SVE widgete (kreiraj nove, mijenjaj, briši)
```

### Šta znači "ne diraj logiku" u screenima
Screen fajlovi IMAJU UI kod koji smiješ mijenjati, ali i provider pozive koje NE smiješ. Konkretno:
- `ref.watch(...)`, `ref.read(...)`, `ref.listen(...)` — NE DIRAJ pozive, NE mijenjaj šta se čita
- `onPressed: () => ref.read(x).someMethod()` — NE DIRAJ callback logiku
- Slobodno mijenjaj: widget tree oko tih poziva, boje, layout, padding, dodaj animacije

**Primjer šta je OK:**
```dart
// PRIJE
ElevatedButton(
  onPressed: () => ref.read(userProvider.notifier).delete(id),
  child: Text('Obriši'),
)

// POSLIJE — OK, samo vizualna promjena, logika ista
AetherButton(
  onPressed: () => ref.read(userProvider.notifier).delete(id),  // ISTI CALLBACK
  label: 'Obriši',
  variant: AetherButtonVariant.danger,
).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
```

---

## 2. AETHER DESIGN TOKENS — BOJE

Zamijeni kompletni `app_colors.dart` u OBA app-a sa ovim tokenima.

```dart
// constants/app_colors.dart

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ═══════════════════════════════════════════
  //  AETHER CORE PALETTE
  // ═══════════════════════════════════════════

  // Primarne — Deep blue spektar
  static const deepBlue    = Color(0xFF0B1426);  // Najdublji — hero headeri
  static const midBlue     = Color(0xFF1E3A5F);  // Srednji — gradijenti, hover states
  static const navyBlue    = Color(0xFF2B5EA7);  // Tercijarni gradient stop

  // Akcentne — Electric blue × Cyan dual accent
  static const electric    = Color(0xFF4F8EF7);  // Primarni akcent — buttoni, linkovi, aktivni tab
  static const cyan        = Color(0xFF38BDF8);  // Sekundarni akcent — gradient parovi, highlights

  // Površine
  static const surface     = Color(0xFFFFFFFF);  // Kartice, dijalozi
  static const surfaceAlt  = Color(0xFFF7F9FC);  // Table headeri, input bg, alternativne površine
  static const background  = Color(0xFFF0F4FA);  // Page background

  // Tekst hijerarhija
  static const textPrimary   = Color(0xFF0B1426);  // Naslovi, važan tekst
  static const textSecondary = Color(0xFF6B7C93);  // Body tekst, opisi
  static const textMuted     = Color(0xFF9AAFC4);  // Placeholder, metapodaci, timestamps

  // Ivice i razdjelnici
  static const border      = Color(0x1F4F8EF7);  // rgba(79,142,247, 0.12)
  static const borderLight = Color(0x0F4F8EF7);  // rgba(79,142,247, 0.06)

  // Semantičke
  static const success     = Color(0xFF22D3A7);
  static const warning     = Color(0xFFFBBF24);
  static const danger      = Color(0xFFFB7185);
  static const purple      = Color(0xFF8B5CF6);
  static const orange      = Color(0xFFF97316);

  // ═══════════════════════════════════════════
  //  PREDEFINISANI GRADIJENTI
  // ═══════════════════════════════════════════

  /// Hero header gradient
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, midBlue, navyBlue],
    stops: [0.0, 0.6, 1.0],
  );

  /// Accent gradient — buttoni, avatar placeholderi, aktivni indikatori
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electric, cyan],
  );

  // ═══════════════════════════════════════════
  //  SHADOWS
  // ═══════════════════════════════════════════

  /// Floating card glow
  static final cardShadow = [
    BoxShadow(color: electric.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 8)),
  ];

  /// Stronger glow — hover state
  static final cardShadowStrong = [
    BoxShadow(color: electric.withOpacity(0.18), blurRadius: 48, offset: const Offset(0, 12)),
  ];

  /// Button shadow
  static final buttonShadow = [
    BoxShadow(color: electric.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  /// Cyan pulsing glow
  static final cyanGlow = [
    BoxShadow(color: cyan.withOpacity(0.4), blurRadius: 12),
  ];

  // ═══════════════════════════════════════════
  //  BADGE SISTEM
  // ═══════════════════════════════════════════

  static (Color, Color) badgeColors(String type) {
    return switch (type.toLowerCase()) {
      'active' || 'online' || 'success' || 'paid'       => (success.withOpacity(0.12), success),
      'pending' || 'warning' || 'processing'             => (warning.withOpacity(0.12), warning),
      'inactive' || 'danger' || 'expired' || 'cancelled' => (danger.withOpacity(0.12), danger),
      'admin' || 'primary'                               => (electric.withOpacity(0.12), electric),
      'editor' || 'secondary'                            => (purple.withOpacity(0.12), purple),
      'viewer' || 'info'                                 => (cyan.withOpacity(0.12), cyan),
      _                                                  => (textMuted.withOpacity(0.12), textMuted),
    };
  }
}
```

---

## 3. AETHER DESIGN TOKENS — TIPOGRAFIJA

```dart
// constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _font = 'SpaceGrotesk';

  // Display
  static const heroTitle = TextStyle(fontFamily: _font, fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.9, height: 1.2);
  static const pageTitle = TextStyle(fontFamily: _font, fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.78, height: 1.25);

  // Headings
  static const cardTitle = TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);
  static const sectionTitle = TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3);

  // Metrics
  static const metricLarge = TextStyle(fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.56, height: 1.1);
  static const metricMedium = TextStyle(fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.44, height: 1.2);

  // Body
  static const body = TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5);
  static const bodyMedium = TextStyle(fontFamily: _font, fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);
  static const bodySecondary = TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.5);

  // Small
  static const caption = TextStyle(fontFamily: _font, fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textMuted, height: 1.4);
  static const label = TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.3);
  static const badge = TextStyle(fontFamily: _font, fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.2);
  static const overline = TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.88, height: 1.3);
  static const tableHeader = TextStyle(fontFamily: _font, fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.84, height: 1.2);
}
```

---

## 4. SPACING I RADII TOKENI

```dart
// constants/app_spacing.dart

import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Scale
  static const xs = 4.0; static const sm = 8.0; static const md = 12.0;
  static const base = 16.0; static const lg = 20.0; static const xl = 24.0;
  static const xxl = 28.0; static const xxxl = 32.0; static const huge = 40.0;

  // Page padding
  static const desktopPage = EdgeInsets.fromLTRB(36, 28, 36, 60);
  static const mobilePage = EdgeInsets.fromLTRB(20, 16, 20, 32);
  static const cardPadding = EdgeInsets.all(24);
  static const cardPaddingCompact = EdgeInsets.symmetric(horizontal: 22, vertical: 20);

  // Border radius
  static final heroRadius = BorderRadius.circular(24);
  static final cardRadius = BorderRadius.circular(20);
  static final panelRadius = BorderRadius.circular(16);
  static final avatarRadius = BorderRadius.circular(14);
  static final buttonRadius = BorderRadius.circular(12);
  static final smallRadius = BorderRadius.circular(10);
  static final chipRadius = BorderRadius.circular(9);
  static final badgeRadius = BorderRadius.circular(8);
  static final tinyRadius = BorderRadius.circular(7);
}
```

---

## 5. FLUTTER_ANIMATE MOTION SISTEM

```yaml
# Dodaj u pubspec.yaml OBA app-a
dependencies:
  flutter_animate: ^4.5.2
```

### Motion Tokens

```dart
// constants/motion.dart

import 'package:flutter/material.dart';

abstract final class Motion {
  // Duracije
  static const fast     = Duration(milliseconds: 200);
  static const normal   = Duration(milliseconds: 350);
  static const smooth   = Duration(milliseconds: 500);
  static const dramatic = Duration(milliseconds: 700);
  static const slow     = Duration(milliseconds: 1200);

  // Krivulje
  static const curve  = Cubic(0.16, 1, 0.3, 1);  // Primarni easing — 90% animacija
  static const spring = Curves.easeOutBack;
  static const gentle = Curves.easeOut;

  // Stagger
  static const staggerDelay   = Duration(milliseconds: 70);
  static const maxStaggerItems = 15;
  static const sectionDelay   = Duration(milliseconds: 100);
}
```

### Patterni — Copy-Paste

```dart
// 1. FLOATING CARD ENTRANCE
myCard
  .animate()
  .fadeIn(duration: Motion.smooth, curve: Motion.curve)
  .slideY(begin: 0.08, end: 0, duration: Motion.smooth, curve: Motion.curve);

// 2. STAGGERED LIST (max 15 stavki)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final delay = index < Motion.maxStaggerItems
        ? Motion.staggerDelay * index
        : Duration.zero;
    return ItemWidget(item: items[index])
      .animate(delay: delay)
      .fadeIn(duration: Motion.normal, curve: Motion.gentle)
      .slideX(begin: -0.03, end: 0, duration: Motion.normal, curve: Motion.curve);
  },
)

// 3. HERO HEADER ENTRANCE
heroContainer
  .animate()
  .fadeIn(duration: Motion.dramatic, curve: Motion.curve)
  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1),
         duration: Motion.dramatic, curve: Motion.curve);

// 4. SHIMMER LOADING
skeletonBox
  .animate(onPlay: (c) => c.repeat())
  .shimmer(duration: 1500.ms, color: AppColors.electric.withOpacity(0.08));

// 5. PROGRESS BAR FILL
progressFill
  .animate()
  .scaleX(begin: 0, end: 1, duration: Motion.slow, curve: Motion.curve,
          alignment: Alignment.centerLeft);
```

### Page Entrance Sekvenca (obavezni redoslijed)
1. Hero header — delay 0ms
2. Stat kartice — stagger: 150ms, 250ms, 350ms, 450ms
3. Main content card — delay 500ms
4. Secondary content — delay 600ms+

### Animacijska Pravila
- Dijalozi: `.fadeIn() + .scale(begin: Offset(0.95, 0.95))` — NE slideUp
- Hover (desktop): `MouseRegion` + `AnimatedContainer` sa `Motion.fast` — NE flutter_animate
- NIKAD ne animiraj scroll (nema parallax)
- NIKAD animacije duže od 1200ms osim chart fill
- NIKAD bounce/elastic krivulje — Aether je smooth

---

## 6. AETHER VIZUALNI IDENTITET — Šta ga čini prepoznatljivim

### 6.1 Hero Header sa Negative Margin Overlap
Stat kartice se PREKLAPAJU sa hero headerom:
```dart
Column(children: [
  AetherHeroHeader(/* ... */),      // padding-bottom: 90px
  Transform.translate(
    offset: const Offset(0, -50),   // Kartice ulaze u header
    child: statCardsRow,
  ),
  // Ostatak sadržaja
])
```

### 6.2 Decorative Elements na Hero Headeru
- 2 koncentrična kruga (border-only) u gornjem desnom uglu
- 1 radial gradient orb (cyan, 8% opacity) u donjem dijelu
- Opcionalni dot grid pattern (CustomPainter sa 24px grid, 0.8r krugovi, 15% opacity)

### 6.3 Pill Tab Switcher
Umjesto TabBar — grupa buttona u surface kontejneru sa 4px padding i shadow:
```dart
Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.buttonRadius,
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
  ),
  child: Row(children: tabs.map((tab) =>
    // Aktivan: bg=deepBlue, color=white
    // Neaktivan: bg=transparent, color=textSecondary
  ).toList()),
)
```

### 6.4 Live Dot Indicator
Mali pulsing dot (8px, cyan, sa cyanGlow shadow) pored status labela.

### 6.5 Gradient Avatari
Kad nema slike — `accentGradient` pozadina sa bijelim inicijalima, borderRadius 14px.

### 6.6 Glow Shadows
Shadow boja je UVIJEK blue-tinted (bazirana na `electric`), NIKAD crna.

---

## 7. OVERFLOW PREVENCIJA — OBAVEZNO

### Pravila bez izuzetka

1. **Tekst u Row** — UVIJEK wrap u `Expanded` ili `Flexible`
2. **Dinamički tekst** — UVIJEK `overflow: TextOverflow.ellipsis` + `maxLines: 1`
3. **Row sa info + akcije** — Expanded za info dio, fiksni width za akcije
4. **Grid layouts** — `LayoutBuilder` za responsivni column count
5. **Page content** — UVIJEK u `SingleChildScrollView` ili `CustomScrollView`
6. **Table ćelije** — `Expanded(flex: N)` za svaku kolonu, ne fiksni width
7. **Dijalozi** — `ConstrainedBox(maxWidth: 560, maxHeight: 700)` + scroll
8. **ListView u Column** — `shrinkWrap: true` + `NeverScrollableScrollPhysics()`
9. **Mobile** — NE koristi fiksne piksele za širine, koristi `MediaQuery` ili `Expanded`

### Self-Check
Prije predaje SVAKOG screena:
- [ ] Testiraj sa 25+ char imenima
- [ ] Testiraj sa praznim podacima (empty state)
- [ ] Provjeri min. širinu (desktop: 1024px, mobile: 320px)
- [ ] Zero RenderFlex overflow

---

## 8. SCOPE MATRIX

### Desktop (stronghold_desktop)

| Screen | Scope | Prioritet |
|--------|-------|-----------|
| `login_screen` | FULL REDESIGN | 🔴 |
| `admin_shell` | FULL REDESIGN | 🔴 |
| `dashboard_home_screen` | FULL REDESIGN | 🔴 |
| `users_screen` | FULL REDESIGN | 🔴 |
| `memberships_screen` | FULL REDESIGN | 🟡 |
| `supplements_screen` | FULL REDESIGN | 🟡 |
| `orders_screen` | FULL REDESIGN | 🟡 |
| `trainers_screen` | FULL REDESIGN | 🟡 |
| `seminars_screen` | FULL REDESIGN | 🟡 |
| `appointments_screen` | THEME SWAP | 🟢 |
| `categories_screen` | THEME SWAP | 🟢 |
| `suppliers_screen` | THEME SWAP | 🟢 |
| `faq_screen` | THEME SWAP | 🟢 |
| `nutritionists_screen` | THEME SWAP | 🟢 |
| `business_report_screen` | THEME SWAP | 🟢 |
| `visitors_screen` | THEME SWAP | 🟢 |
| `leaderboard_screen` | THEME SWAP | 🟢 |
| `payment_history_screen` | THEME SWAP | 🟢 |
| `reviews_screen` | THEME SWAP | 🟢 |
| `membership_packages_screen` | THEME SWAP | 🟢 |

### Mobile (stronghold_mobile)

| Screen | Scope | Prioritet |
|--------|-------|-----------|
| `login_screen` | FULL REDESIGN | 🔴 |
| `register_screen` | FULL REDESIGN | 🔴 |
| `home_screen` | FULL REDESIGN | 🔴 |
| `navigation_shell` | FULL REDESIGN | 🔴 |
| `supplement_shop_screen` | FULL REDESIGN | 🟡 |
| `supplement_detail_screen` | FULL REDESIGN | 🟡 |
| `cart_screen` | FULL REDESIGN | 🟡 |
| `checkout_screen` | FULL REDESIGN | 🟡 |
| `user_progress_screen` | FULL REDESIGN | 🟡 |
| `leaderboard_screen` | FULL REDESIGN | 🟡 |
| `profile_settings_screen` | THEME SWAP | 🟢 |
| `appointment_screen` | THEME SWAP | 🟢 |
| `book_appointment_screen` | THEME SWAP | 🟢 |
| `seminar_screen` | THEME SWAP | 🟢 |
| `trainer_list_screen` | THEME SWAP | 🟢 |
| `nutritionist_list_screen` | THEME SWAP | 🟢 |
| `order_history_screen` | THEME SWAP | 🟢 |
| `review_history_screen` | THEME SWAP | 🟢 |
| `faq_screen` | THEME SWAP | 🟢 |
| Ostali | THEME SWAP | 🟢 |

### Core Widgets (stronghold_core/widgets)

| Widget | Akcija |
|--------|--------|
| `glass_card.dart` | REPLACE → AetherCard (floating card sa border + glow shadow) |
| `gradient_button.dart` | UPDATE → accentGradient + buttonShadow |
| `particle_background.dart` | KEEP ako je na loginu, inače REMOVE |
| `ring_progress.dart` | UPDATE → electric/cyan boje |
| `status_pill.dart` | UPDATE → koristi AppColors.badgeColors() |
| `avatar_widget.dart` | UPDATE → accentGradient, borderRadius 14px |

**THEME SWAP** = samo zamijeni hardcoded boje sa AppColors referencama + dodaj basic entrance animaciju na page level.
**FULL REDESIGN** = kompletni widget tree rework prema Aether patternima, ali ISTA logika/provideri.

---

## 9. WORKFLOW — REDOSLIJED RADA

### Faza 1: Foundation (RADI PRVO — ništa drugo dok ovo ne radi)
1. Zamijeni `app_colors.dart` u oba app-a
2. Zamijeni `app_text_styles.dart` u oba app-a
3. Zamijeni `app_spacing.dart` u oba app-a
4. Zamijeni/kreiraj `app_theme.dart` u oba app-a (postavi u `MaterialApp`)
5. Dodaj `flutter_animate` u oba pubspec.yaml
6. Kreiraj `motion.dart` u oba constants/ foldera
7. Dodaj Space Grotesk font (`google_fonts` paket ili manual asset)
8. Updateaj core widgete (glass_card, gradient_button, status_pill, avatar_widget, ring_progress)
9. **BUILD + RUN oba app-a** — moraju se pokrenuti bez error-a

### Faza 2: Shell
1. Desktop: `app_sidebar.dart` → `admin_top_bar.dart` → `command_palette.dart` → `admin_shell.dart`
2. Mobile: `app_bottom_nav.dart` → `navigation_shell.dart`

### Faza 3: 🔴 High Priority — jedan po jedan, testiraj svaki
Desktop: Login → Dashboard → Users
Mobile: Login → Register → Home

### Faza 4: 🟡 Medium Priority
Jedan po jedan, isti pristup.

### Faza 5: 🟢 Theme Swap
Bulk swap — samo boje i basic animacije.

---

## 10. MOBILE SPECIFIČNA PRAVILA

Mobile je za **obične korisnike teretane**, ne admine. UX mora biti brz, vertikalan, i gamificiran.

### Layout razlike od desktopa

| Element | Desktop | Mobile |
|---------|---------|--------|
| Page header | Hero gradient 90px padding + overlap | Manji hero ili styled AppBar |
| Navigation | Sidebar + top bar | Bottom nav (max 5 stavki) |
| Tabele | Full data table sa kolonama | Kartice/liste (vertikalni scroll) |
| Stat kartice | 4 u jednom redu | 2×2 grid ili horizontalni scroll |
| Dijalozi | Centered modal | Bottom sheet |
| Akcije | Buttoni u headeru | FAB ili bottom action bar |
| Grid (shop) | 4 kolone | 2 kolone |

### Touch target: minimum 44×44px za sve interaktivne elemente.

---

## 11. DON'TS — 47 ZABRANA

### Riverpod
1. NE mijenjaj potpise providera
2. NE dodavaj nove providere
3. NE mijenjaj ref.watch/read/listen pozive
4. NE premještaj provider fajlove
5. NE mijenjaj `list_notifier.dart` / `list_state.dart`
6. NE dodavaj UI logiku u providere
7. NE koristi StateProvider — projekat koristi Notifier pattern
8. NE mijenjaj `api_providers.dart`

### Dizajn
9. NE koristi Material default boje (Colors.blue itd.) — SAMO AppColors
10. NE koristi crne shadowove — SAMO blue-tinted
11. NE koristi BorderRadius.circular() direktno — koristi AppSpacing konstante
12. NE koristi default Material buttons bez Aether stila
13. NE miješaj fontove — SAMO Space Grotesk
14. NE koristi opacity ispod 0.04 za pozadine
15. NE stavljaj shadow na svaki element — samo floating kartice i buttone
16. NE stavljaj hero header na THEME SWAP screenove

### Animacije
17. NE animiraj scroll (nema parallax)
18. NE koristi animacije duže od 1200ms osim chart fill
19. NE staggeruj više od 15 stavki
20. NE koristi bounce/elastic krivulje
21. NE animiraj boje — samo opacity, position, scale
22. NE dodavaj loading animacije za podatke koji dolaze <200ms
23. NE koristi AnimationController kad flutter_animate može
24. NE animiraj layout (width/height) — samo opacity i transform

### Kod
25. NE piši reusable widget duži od 120 linija, screen duži od 250, dijalog duži od 150 — EXTRACTAJ logičke sekcije
26. NE hardcodaj stringove
27. NE koristi setState za kompleksno stanje
28. NE dupliciraj widgete između desktop i mobile — shared idu u core/widgets
29. NE ostavljaj TODO komentare
30. NE koristi Container kad DecoratedBox + Padding radi isti posao
31. NE koristi SizedBox.expand() bez ConstrainedBox roditelja
32. NE ignoriši const konstruktore

### Overflow
33. NE stavljaj Text u Row bez Expanded/Flexible
34. NE koristi fiksnu širinu za dinamičke elemente
35. NE zaboravi TextOverflow.ellipsis na dinamičke tekstove
36. NE koristi ListView u Column bez shrinkWrap + NeverScrollableScrollPhysics
37. NE koristi IntrinsicHeight/IntrinsicWidth
38. NE zaboravi ConstrainedBox(maxWidth) na dijalozima

### Routing/Struktura
39. NE mijenjaj routing — screenovi se zovu isto, primaju iste parametre
40. NE mijenjaj main.dart osim za postavljanje nove teme
41. NE kreiraj nove foldere — koristi POSTOJEĆU strukturu
42. NE premještaj fajlove iz jednog foldera u drugi
43. NE reorganizuj folder hijerarhiju (ne mijenjaj flat u nested ili obrnuto)
44. NE imenuj fajlove sa `aether_` prefiksom — prati postojeću naming konvenciju projekta
45. Desktop novi widget za feature X → `widgets/X/novi_widget.dart` (prati feature folder pattern)
46. Mobile novi widget → `widgets/novi_widget.dart` (prati flat pattern)
47. Shared widget između oba app-a → `stronghold_core/lib/widgets/` (NE dupliciraj)

---

## 12. CHECKLIST PRIJE PREDAJE SVAKOG SCREENA

### Vizualno
- [ ] SAMO AppColors — nema hardcoded boja
- [ ] SAMO AppTextStyles — nema hardcoded font veličina
- [ ] SAMO AppSpacing radii — nema hardcoded border-radius
- [ ] Floating kartice: border + glow shadow (oba, ne samo jedno)
- [ ] Hero header (FULL REDESIGN): gradient + dekorativni krugovi + overlap

### Animacije
- [ ] Page entrance sekvenca po Motion tokenima
- [ ] Stagger na listama (max 15)
- [ ] Shimmer loading za async podatke
- [ ] Nema animacija >1200ms

### Overflow
- [ ] Testirano sa 25+ char imenima
- [ ] Testirano sa praznim podacima
- [ ] NULA RenderFlex overflow
- [ ] Svi dinamički tekstovi imaju ellipsis

### Kod
- [ ] Nijedan reusable widget >120 linija, screen >250, dijalog >150
- [ ] Widgeti sa 3+ logičkih sekcija extractani u zasebne widgete
- [ ] Provider pozivi NEPROMIJENJENI
- [ ] Routing NEPROMIJENJEN
- [ ] const gdje god moguće
- [ ] Nema dupliciranih widgeta između apps
- [ ] Novi fajlovi prate postojeću folder strukturu (desktop: feature folders, mobile: flat)
- [ ] Naming konvencija prati postojeće fajlove (no aether_ prefix)

---

*Stronghold Aether UI Ruleset v1.0 — Flutter dual-app redesign compliance document*
