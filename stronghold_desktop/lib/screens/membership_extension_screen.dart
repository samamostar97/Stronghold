import 'package:flutter/material.dart';

class MembershipExtensionScreen extends StatefulWidget {
  const MembershipExtensionScreen({super.key});

  @override
  State<MembershipExtensionScreen> createState() =>
      _MembershipExtensionScreenState();
}

class _MembershipExtensionScreenState extends State<MembershipExtensionScreen> {
  final _searchController = TextEditingController();

  // Dummy data (kao u HTML-u)
  final List<_UserRow> _allUsers = const [
    _UserRow(firstName: 'John', lastName: 'Doe', username: 'jdoe'),
    _UserRow(firstName: 'Marko', lastName: 'Marković', username: 'mmarkovic'),
    _UserRow(firstName: 'Ana', lastName: 'Anić', username: 'aanic'),
    _UserRow(firstName: 'Petar', lastName: 'Petrović', username: 'ppetrovic'),
    _UserRow(firstName: 'Sara', lastName: 'Sarić', username: 'ssaric'),
    _UserRow(firstName: 'Emina', lastName: 'Eminović', username: 'eeminovic'),
    _UserRow(firstName: 'Adnan', lastName: 'Ademović', username: 'aademovic'),
    _UserRow(firstName: 'Amina', lastName: 'Alić', username: 'aalic'),
  ];

  List<_UserRow> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.of(_allUsers);
  }

  void _search() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_allUsers);
      } else {
        _filtered = _allUsers.where((u) {
          return u.firstName.toLowerCase().contains(q) ||
              u.lastName.toLowerCase().contains(q) ||
              u.username.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Colors from HTML
  static const _bg1 = Color(0xFF1A1D2E);
  static const _bg2 = Color(0xFF16192B);
  static const _card = Color(0xFF22253A);
  static const _panel = Color(0xFF2A2D3E);
  static const _muted = Color(0xFF8A8D9E);
  static const _border = Color(0xFF3A3D4E);

  static const _accent = Color(0xFFFF5757);
  static const _accent2 = Color(0xFFFF6B6B);

  static const _blue1 = Color(0xFF4A9EFF);
  static const _blue2 = Color(0xFF3A8EEF);

  static const _green1 = Color(0xFF2ECC71);
  static const _green2 = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bg1, _bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive padding based on screen width
              final horizontalPadding = constraints.maxWidth > 1200
                  ? 40.0
                  : constraints.maxWidth > 800
                      ? 24.0
                      : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 20),

                _GradientButton(
                  text: 'Nazad',
                  icon: '←',
                  colors: const [_accent, _accent2],
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Produžavanje članarina',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Search section
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 520;
                            return isNarrow
                                ? Column(
                                    children: [
                                      _SearchInput(
                                        controller: _searchController,
                                        onSubmitted: (_) => _search(),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: _GradientButton(
                                          text: 'Pretraži',
                                          icon: '',
                                          colors: const [_blue1, _blue2],
                                          onTap: _search,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _SearchInput(
                                          controller: _searchController,
                                          onSubmitted: (_) => _search(),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      _GradientButton(
                                        text: 'Pretraži',
                                        icon: '',
                                        colors: const [_blue1, _blue2],
                                        onTap: _search,
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Table container
                      Container(
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: [
                              // Table header
                              Container(
                                color: _bg1,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: const Row(
                                  children: [
                                    _Th('Ime'),
                                    _Th('Prezime'),
                                    _Th('Username'),
                                    _Th('Akcije'),
                                  ],
                                ),
                              ),

                              // Rows
                              for (int i = 0; i < _filtered.length; i++)
                                _TableRow(
                                  user: _filtered[i],
                                  isLast: i == _filtered.length - 1,
                                  borderColor: _border,
                                  onViewPayments: () {
                                    // TODO: open payments screen
                                  },
                                  onAddPayment: () {
                                    // TODO: open add payment / extend membership flow
                                  },
                                ),

                              if (_filtered.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'Nema rezultata.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  static const _panel = Color(0xFF2A2D3E);
  static const _accent = Color(0xFFFF5757);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: const [
            Text('🏋️', style: TextStyle(fontSize: 32, color: _accent)),
            SizedBox(width: 10),
            Text(
              'STRONGHOLD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text('👤'),
              SizedBox(width: 8),
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  static const _bg = Color(0xFF1A1D2E);
  static const _border = Color(0xFF3A3D4E);
  static const _muted = Color(0xFF8A8D9E);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Pretraži korisnika po imenu, prezimenu ili korisničkom imenu...',
        hintStyle: const TextStyle(color: _muted, fontSize: 14),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _border),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.text,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String text;
  final String icon; // e.g. "←" or ""
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon.isNotEmpty) ...[
                Text(
                  widget.icon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.text);

  final String text;
  static const _muted = Color(0xFF8A8D9E);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _muted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _UserRow {
  final String firstName;
  final String lastName;
  final String username;

  const _UserRow({
    required this.firstName,
    required this.lastName,
    required this.username,
  });
}

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.user,
    required this.isLast,
    required this.borderColor,
    required this.onViewPayments,
    required this.onAddPayment,
  });

  final _UserRow user;
  final bool isLast;
  final Color borderColor;
  final VoidCallback onViewPayments;
  final VoidCallback onAddPayment;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;

  static const _hoverBg = Color(0xFF22253A);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? _hoverBg : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(bottom: BorderSide(color: widget.borderColor)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            _Td(widget.user.firstName),
            _Td(widget.user.lastName),
            _Td(widget.user.username),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: [
                    _SmallButton(
                      text: 'Pregled uplata',
                      background: const Color(0xFF4A9EFF),
                      onTap: widget.onViewPayments,
                    ),
                    _SmallGradientButton(
                      text: 'Dodaj uplatu',
                      colors: const [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      onTap: widget.onAddPayment,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Td extends StatelessWidget {
  const _Td(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  const _SmallButton({
    required this.text,
    required this.background,
    required this.onTap,
  });

  final String text;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallGradientButton extends StatefulWidget {
  const _SmallGradientButton({
    required this.text,
    required this.colors,
    required this.onTap,
  });

  final String text;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  State<_SmallGradientButton> createState() => _SmallGradientButtonState();
}

class _SmallGradientButtonState extends State<_SmallGradientButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
