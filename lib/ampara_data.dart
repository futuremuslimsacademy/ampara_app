import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const emerald = Color(0xFF0B6E4F);
  static const emeraldDark = Color(0xFF084C37);
  static const cream = Color(0xFFFBF6EA);
  static const gold = Color(0xFFC9A227);
  static const ink = Color(0xFF1F2A24);
}

class AppAssets {
  static const logo = 'assets/file_0000000079d082119b67e67d9c9050aa.png';
  static const banner = 'assets/file_0000000095e0821192eca039edc6ad2f.png';
  static const classPhoto = 'assets/file_000000004c2882119ae43395464e95a9.png';
}

String toBn(int n) {
  const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

const banglaNames = <int, String>{
  78: 'আন-নাবা',
  79: 'আন-নাযিআত',
  80: 'আবাসা',
  81: 'আত-তাকভীর',
  82: 'আল-ইনফিতার',
  83: 'আল-মুতাফফিফীন',
  84: 'আল-ইনশিকাক',
  85: 'আল-বুরূজ',
  86: 'আত-তারিক',
  87: 'আল-আলা',
  88: 'আল-গাশিয়াহ',
  89: 'আল-ফাজর',
  90: 'আল-বালাদ',
  91: 'আশ-শামস',
  92: 'আল-লাইল',
  93: 'আদ-দুহা',
  94: 'আল-ইনশিরাহ',
  95: 'আত-তীন',
  96: 'আল-আলাক',
  97: 'আল-কদর',
  98: 'আল-বাইয়্যিনাহ',
  99: 'আয-যিলযাল',
  100: 'আল-আদিয়াত',
  101: 'আল-কারিআহ',
  102: 'আত-তাকাসুর',
  103: 'আল-আসর',
  104: 'আল-হুমাযাহ',
  105: 'আল-ফীল',
  106: 'কুরাইশ',
  107: 'আল-মাউন',
  108: 'আল-কাউসার',
  109: 'আল-কাফিরূন',
  110: 'আন-নাসর',
  111: 'আল-মাসাদ',
  112: 'আল-ইখলাস',
  113: 'আল-ফালাক',
  114: 'আন-নাস',
};

class Surah {
  final int number;
  final String arabicName;
  final String type;
  final int count;
  final List<String> ayahs = [];
  String? bismillah;
  Surah(this.number, this.arabicName, this.type, this.count);

  String get banglaName => banglaNames[number] ?? 'সূরা $number';
  String get typeBn => type == 'Meccan' ? 'মাক্কী' : 'মাদানী';
  String get shortArabic {
    final i = arabicName.indexOf(' ');
    return i > 0 ? arabicName.substring(i + 1) : arabicName;
  }
}

class AmparaRepo {
  static const _key = 'ampara_cache_v1';
  static const _url = 'https://api.alquran.cloud/v1/juz/30/quran-uthmani';
  static final _marks =
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]');

  static Future<List<Surah>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    if (cached != null) {
      try {
        return _parse(jsonDecode(cached) as List);
      } catch (_) {}
    }
    final res = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('http ${res.statusCode}');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final ayahs = body['data']['ayahs'] as List;
    final rows = <List<dynamic>>[];
    for (final a in ayahs) {
      final s = a['surah'];
      rows.add([
        s['number'],
        s['name'],
        s['revelationType'],
        s['numberOfAyahs'],
        a['numberInSurah'],
        a['text'],
      ]);
    }
    final result = _parse(rows);
    await prefs.setString(_key, jsonEncode(rows));
    return result;
  }

  static List<Surah> _parse(List rows) {
    final map = <int, Surah>{};
    for (final r in rows) {
      final n = r[0] as int;
      final s = map.putIfAbsent(
        n,
        () => Surah(n, r[1] as String, r[2] as String, r[3] as int),
      );
      var text = (r[5] as String).trim();
      if ((r[4] as int) == 1) {
        final words = text.split(RegExp(r'\s+'));
        if (words.length > 4 && words.first.replaceAll(_marks, '') == 'بسم') {
          s.bismillah = words.take(4).join(' ');
          text = words.skip(4).join(' ');
        }
      }
      s.ayahs.add(text);
    }
    final list = map.values.toList();
    list.sort((a, b) => a.number.compareTo(b.number));
    return list;
  }
}

class ReadStore {
  static Future<int?> lastSurah() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('last_surah');
  }

  static Future<void> setLast(int n) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_surah', n);
  }

  static Future<double> getFont() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble('font_size') ?? 28.0;
  }

  static Future<void> setFont(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('font_size', v);
  }
}
