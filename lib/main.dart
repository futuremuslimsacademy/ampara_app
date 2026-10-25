import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ampara_data.dart';

void main() => runApp(const AmparaApp());

class AmparaApp extends StatelessWidget {
  const AmparaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ফিউচার মুসলিমস একাডেমি: আমপারা',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          primary: AppColors.emerald,
          secondary: AppColors.gold,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emerald, AppColors.emeraldDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 170,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Image.asset(
                AppAssets.logo,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ফিউচার মুসলিমস একাডেমি',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'আমপারা',
              style: TextStyle(color: AppColors.gold, fontSize: 22),
            ),
            const SizedBox(height: 14),
            const Text(
              'কুরআন শেখা হোক সহজ ও সুন্দর',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Surah> _surahs = [];
  bool _loading = true;
  bool _error = false;
  int? _lastNo;

  @override
  void initState() {
    super.initState();
    _load();
    _loadLast();
  }

  Future<void> _load() async {
    try {
      final list = await AmparaRepo.load();
      if (mounted) {
        setState(() {
          _surahs = list;
          _loading = false;
          _error = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _loadLast() async {
    final n = await ReadStore.lastSurah();
    if (mounted) setState(() => _lastNo = n);
  }

  Future<void> _open(Surah s) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SurahScreen(surah: s)),
    );
    _loadLast();
  }

  Surah? get _last {
    if (_lastNo == null) return null;
    for (final s in _surahs) {
      if (s.number == _lastNo) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final last = _last;
    return Scaffold(
      appBar: AppBar(title: const Text('ফিউচার মুসলিমস একাডেমি')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _LogoHeader(),
          const SizedBox(height: 14),
          const _Banner(),
          const SizedBox(height: 20),
          const _SectionTitle('শেখা চালিয়ে যান'),
          _ContinueCard(
            surah: last,
            onTap: last == null ? null : () => _open(last),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('আমপারার সূরাসমূহ'),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.emerald),
              ),
            ),
          if (_error)
            _ErrorBox(onRetry: () {
              setState(() {
                _loading = true;
                _error = false;
              });
              _load();
            }),
          for (final s in _surahs)
            _SurahTile(surah: s, onTap: () => _open(s)),
          const SizedBox(height: 20),
          const _SectionTitle('একাডেমির কোর্স'),
          const _CourseSoon(),
          const SizedBox(height: 20),
          const _ContactCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(
            AppAssets.logo,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.menu_book_rounded,
              color: AppColors.emerald,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ফিউচার মুসলিমস একাডেমি',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldDark),
              ),
              SizedBox(height: 2),
              Text(
                'আমপারা',
                style: TextStyle(fontSize: 16, color: AppColors.gold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Image.asset(
            AppAssets.banner,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) =>
                Container(height: 200, color: AppColors.emerald),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC084C37)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আমপারা শিখুন',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'শিশুদের জন্য সহজ ও সুন্দর কুরআন শিক্ষা',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.emeraldDark),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Surah? surah;
  final VoidCallback? onTap;
  const _ContinueCard({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = surah;
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.play_circle_outline_rounded,
                  size: 36, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: s == null
                    ? const Text(
                        'এখনো কোনো সূরা শুরু করা হয়নি। নিচ থেকে একটি সূরা বেছে নিন।',
                        style: TextStyle(color: AppColors.ink, height: 1.4),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('শেষ পড়া সূরা',
                              style: TextStyle(color: AppColors.emerald)),
                          const SizedBox(height: 2),
                          Text(s.banglaName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${toBn(s.count)} আয়াত'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 44, color: AppColors.gold),
            const SizedBox(height: 10),
            const Text(
              'সূরার তালিকা আনা যায়নি। ইন্টারনেট চালু করে আবার চেষ্টা করুন। প্রথমবার ইন্টারনেট লাগবে, এরপর ছাড়াই চলবে।',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.emerald.withAlpha(30),
          child: Text(
            toBn(surah.number),
            style: const TextStyle(
                color: AppColors.emeraldDark,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
        title: Text(surah.banglaName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${toBn(surah.count)} আয়াত · ${surah.typeBn}'),
        trailing: Text(
          surah.shortArabic,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 20, color: AppColors.emerald),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CourseSoon extends StatelessWidget {
  const _CourseSoon();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppAssets.classPhoto,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(height: 160, color: AppColors.emerald),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('অনলাইনে কুরআন ও ইসলামী শিক্ষা',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('নূরানী, তাজবীদ, নাজেরা ও হিফজসহ সব কোর্সের পাঠ শিগগিরই আসছে।',
                    style: TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    const number = '01786254358';
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ভর্তি ও যোগাযোগ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('বিনামূল্যে ট্রায়াল ক্লাসের জন্য আজই যোগাযোগ করুন।'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone_rounded, color: AppColors.emerald),
                const SizedBox(width: 8),
                const Text(number,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: number));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('নম্বর কপি হয়েছে')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('কপি'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SurahScreen extends StatefulWidget {
  final Surah surah;
  const SurahScreen({super.key, required this.surah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  double _font = 28;

  @override
  void initState() {
    super.initState();
    ReadStore.setLast(widget.surah.number);
    ReadStore.getFont().then((v) {
      if (mounted) setState(() => _font = v);
    });
  }

  void _change(double d) {
    final v = (_font + d).clamp(20.0, 44.0).toDouble();
    setState(() => _font = v);
    ReadStore.setFont(v);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.banglaName),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => _change(-2),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _change(2),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  s.shortArabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'সূরা ${s.banglaName} · ${toBn(s.count)} আয়াত · ${s.typeBn}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (s.bismillah != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                s.bismillah!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: _font,
                    height: 2.0,
                    color: AppColors.emeraldDark),
              ),
            ),
          for (var i = 0; i < s.ayahs.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.emerald.withAlpha(30),
                        child: Text(
                          toBn(i + 1),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.emeraldDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.ayahs[i],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: _font, height: 2.0, color: AppColors.ink),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
