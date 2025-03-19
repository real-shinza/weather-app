import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.notoSansJpTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Map<String, String>> prefectures = [
    {'id': '011000', 'name': '宗谷地方'},
    {'id': '012000', 'name': '上川・留萌地方'},
    {'id': '016000', 'name': '石狩・空知・後志地方'},
    {'id': '013000', 'name': '網走・北見・紋別地方'},
    {'id': '014100', 'name': '釧路・根室地方'},
    {'id': '015000', 'name': '胆振・日高地方'},
    {'id': '017000', 'name': '渡島・檜山地方'},
    {'id': '020000', 'name': '青森県'},
    {'id': '050000', 'name': '秋田県'},
    {'id': '030000', 'name': '岩手県'},
    {'id': '040000', 'name': '宮城県'},
    {'id': '060000', 'name': '山形県'},
    {'id': '070000', 'name': '福島県'},
    {'id': '080000', 'name': '茨城県'},
    {'id': '090000', 'name': '栃木県'},
    {'id': '100000', 'name': '群馬県'},
    {'id': '110000', 'name': '埼玉県'},
    {'id': '130000', 'name': '東京都'},
    {'id': '120000', 'name': '千葉県'},
    {'id': '140000', 'name': '神奈川県'},
    {'id': '200000', 'name': '長野県'},
    {'id': '190000', 'name': '山梨県'},
    {'id': '220000', 'name': '静岡県'},
    {'id': '230000', 'name': '愛知県'},
    {'id': '210000', 'name': '岐阜県'},
    {'id': '240000', 'name': '三重県'},
    {'id': '150000', 'name': '新潟県'},
    {'id': '160000', 'name': '富山県'},
    {'id': '170000', 'name': '石川県'},
    {'id': '180000', 'name': '福井県'},
    {'id': '250000', 'name': '滋賀県'},
    {'id': '260000', 'name': '京都府'},
    {'id': '270000', 'name': '大阪府'},
    {'id': '280000', 'name': '兵庫県'},
    {'id': '290000', 'name': '奈良県'},
    {'id': '300000', 'name': '和歌山県'},
    {'id': '330000', 'name': '岡山県'},
    {'id': '340000', 'name': '広島県'},
    {'id': '320000', 'name': '島根県'},
    {'id': '310000', 'name': '鳥取県'},
    {'id': '360000', 'name': '徳島県'},
    {'id': '370000', 'name': '香川県'},
    {'id': '380000', 'name': '愛媛県'},
    {'id': '390000', 'name': '高知県'},
    {'id': '350000', 'name': '山口県'},
    {'id': '400000', 'name': '福岡県'},
    {'id': '440000', 'name': '大分県'},
    {'id': '420000', 'name': '長崎県'},
    {'id': '410000', 'name': '佐賀県'},
    {'id': '430000', 'name': '熊本県'},
    {'id': '450000', 'name': '宮崎県'},
    {'id': '460100', 'name': '鹿児島県'},
    {'id': '471000', 'name': '沖縄本島地方'},
    {'id': '472000', 'name': '大東島地方'},
    {'id': '473000', 'name': '宮古島地方'},
    {'id': '474000', 'name': '八重山地方'},
  ];
  Map<String, String>? selectedPrefecture;

  @override
  void initState() {
    super.initState();
    if (prefectures.isNotEmpty) {
      selectedPrefecture = prefectures[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '都道府県を選択',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            DropdownButton<Map<String, String>>(
              value: selectedPrefecture,
              onChanged: (Map<String, String>? newValue) {
                setState(() {
                  selectedPrefecture = newValue!;
                });
              },
              items: prefectures.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> prefecture) {
                return DropdownMenuItem<Map<String, String>>(
                  value: prefecture,
                  child: Text(prefecture['name']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherPage(id: selectedPrefecture!['id']!, name: selectedPrefecture!['name']!),
                  ),
                );
              },
              child: const Text('天気を確認'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  final String id;
  final String name;
  const WeatherPage({super.key, required this.id, required this.name});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  String weatherOverview = '';

  @override
  void initState() {
    super.initState();
    fetchWeatherOverview();
  }

  Future<void> fetchWeatherOverview() async {
    final url = Uri.parse('https://www.jma.go.jp/bosai/forecast/data/overview_forecast/${widget.id}.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes); // 文字化け対策
        final data = json.decode(utf8DecodedBody);
        setState(() {
          weatherOverview = data['text']; // 天気概況を取得
        });
      } else {
        setState(() {
          weatherOverview = '天気情報の取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        weatherOverview = 'エラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name}の天気')),
      body: Center(
        child: Text(
          weatherOverview,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
