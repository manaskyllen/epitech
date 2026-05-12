import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/widgets/profile_button.dart';

class SuitcaseResultScreen extends StatefulWidget {
  const SuitcaseResultScreen({super.key, required this.resultData});
  final Map<String, dynamic> resultData;

  @override
  State<SuitcaseResultScreen> createState() => _SuitcaseResultScreenState();
}

class _ProcessedUiData {
  _ProcessedUiData(this.items, this.total); // Constructor moved before fields

  final Map<String, List<Map<String, dynamic>>> items;
  final int total;
}

class _SuitcaseResultScreenState extends State<SuitcaseResultScreen> {
  String _destination = '';
  int _days = 0;
  int _totalItems = 0;

  int? _minTemp;
  int? _maxTemp;
  String _weatherCondition = 'Unknown Weather';

  Map<String, List<Map<String, dynamic>>> _categorizedItems = {
    'TOPS': [],
    'BOTTOMS': [],
    'SHOES': [],
    'ACCESSORIES': [],
  };

  @override
  void initState() {
    super.initState();
    _processSuitcaseData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rawWarnings = widget.resultData['warnings'];
      if (rawWarnings != null && rawWarnings is Map) {
        final Map<String, int> warningsMap = {};
        rawWarnings.forEach((key, value) {
          if (value is num) {
            warningsMap[key.toString()] = value.toInt();
          }
        });
        if (warningsMap.isNotEmpty) {
          _showWarningPopup(warningsMap);
        }
      }
    });
  }

  /// Mapping intelligent avec icônes FontAwesome
  IconData _getProWeatherIcon(String condition) {
    final cond = condition.toLowerCase();

    if (cond.contains('pluie forte') || cond.contains('heavy rain')) {
      return FontAwesomeIcons.cloudShowersHeavy;
    }
    if (cond.contains('pluie') || cond.contains('rain') || cond.contains('averse')) {
      return FontAwesomeIcons.cloudRain;
    }
    if (cond.contains('orage') || cond.contains('thunder')) {
      return FontAwesomeIcons.cloudBolt;
    }
    if (cond.contains('neige') || cond.contains('snow')) {
      return FontAwesomeIcons.snowflake;
    }
    if (cond.contains('brouillard') || cond.contains('mist') || cond.contains('brume')) {
      return FontAwesomeIcons.smog;
    }
    if (cond.contains('couvert') || cond.contains('very cloudy')) {
      return FontAwesomeIcons.cloud;
    }
    if (cond.contains('nuage') || cond.contains('cloud')) {
      return FontAwesomeIcons.cloudSun;
    }

    return FontAwesomeIcons.solidSun;
  }

  void _processSuitcaseData() {
    try {
      final data = widget.resultData;
      final suitcase = data['suitcase'];
      final List<dynamic> clothings = suitcase != null ? (suitcase['clothings'] ?? []) : [];

      int daysDiff = 1;
      if (suitcase != null && suitcase['departure_date'] != null && suitcase['end_date'] != null) {
        final start = DateTime.parse(suitcase['departure_date']);
        final end = DateTime.parse(suitcase['end_date']);
        daysDiff = end.difference(start).inDays;
      }

      final weather = data['weather'];
      if (weather != null && weather is Map) {
        _minTemp = (weather['temp_min'] as num?)?.toInt();
        _maxTemp = (weather['temp_max'] as num?)?.toInt();
        _weatherCondition = weather['condition']?.toString() ?? 'Unknown Weather';
      }

      final processedData = _processClothingsToUi(clothings);

      setState(() {
        _destination = (suitcase != null) ? (suitcase['destination'] ?? '') : '';
        _days = daysDiff > 0 ? daysDiff : 1;
        _categorizedItems = processedData.items;
        _totalItems = processedData.total;
      });
    } catch (e) {
      debugPrint('Error while parsing: $e');
    }
  }

  _ProcessedUiData _processClothingsToUi(List<dynamic> apiClothings) {
    final Map<String, List<Map<String, dynamic>>> categories = {
      'TOPS': [],
      'BOTTOMS': [],
      'SHOES': [],
      'ACCESSORIES': [],
    };
    int count = 0;

    for (final item in apiClothings) {
      final String type = (item['itemType'] ?? '').toString().toLowerCase();
      final String subType = (item['itemSubtype'] ?? item['itemType'] ?? 'Article').toString();
      final String fabric = item['fabric'] ?? '';
      final String color = item['color'] ?? '';

      String details = '$fabric $color'.trim();
      if (details.isEmpty) details = item['style'] ?? 'Standard';

      String categoryKey = 'ACCESSORIES';
      if (['t-shirt', 'shirt', 'sweater', 'jacket', 'coat', 'top', 'sweatshirt', 'chemise', 'pull', 'veste', 'manteau', 'haut'].contains(type)) {
        categoryKey = 'TOPS';
      } else if (['pants', 'jeans', 'shorts', 'skirt', 'swimwear', 'pantalon', 'jean', 'short', 'jupe', 'maillot', 'bas'].contains(type)) {
        categoryKey = 'BOTTOMS';
      } else if (['shoes', 'sneakers', 'boots', 'sandals', 'chaussures', 'baskets', 'bottes', 'sandales'].contains(type)) {
        categoryKey = 'SHOES';
      }

      categories[categoryKey]!.add({
        'name': subType,
        'details': details,
        'qty': item['quantity'] ?? 1,
        'image': 'assets/images/placeholder.png',
      });
      count++;
    }
    return _ProcessedUiData(categories, count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Image.asset(
          'assets/images/InspiriaLogoV2.png',
          height: 20,
          errorBuilder: (_, __, ___) => const Text('INSPIRIA', style: TextStyle(color: Colors.black)),
        ),
        centerTitle: true,
        actions: const [ProfileButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildWeatherCard(_destination, _days, _minTemp, _maxTemp, _weatherCondition),
            const SizedBox(height: 20),
            _buildTotalCounter(_totalItems),
            if (_totalItems == 0 && _categorizedItems.values.every((l) => l.isEmpty))
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'Your suitcase is empty for the moment.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              )
            else
              ..._categorizedItems.entries.map((entry) {
                if (entry.value.isEmpty) return const SizedBox.shrink();
                return _buildCategorySection(entry.key, entry.value);
              }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String city, int days, int? minT, int? maxT, String condition) {
    final String tempText = (minT != null && maxT != null) ? '$minT-$maxT°C' : '--°C';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    city,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text('$days days', style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thermostat, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(tempText, style: GoogleFonts.inter(color: Colors.white)),
                  ],
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        _getProWeatherIcon(condition),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          condition,
                          style: GoogleFonts.inter(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCounter(int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Items', style: GoogleFonts.inter(fontSize: 16)),
          Text('$total', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8, top: 20),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => _buildItemCard(items[i]),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Image.asset(
              item['image'] ?? 'assets/images/placeholder.png',
              errorBuilder: (_, __, ___) => const Icon(Icons.checkroom, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text(item['details'], style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Text("${item['qty']}", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWarningPopup(Map<String, int> warnings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Missing Items', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: warnings.length,
                itemBuilder: (context, index) {
                  final String key = warnings.keys.elementAt(index);
                  final int quantity = warnings[key]!;
                  return _buildWarningSection(key, quantity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection(String itemType, int quantity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Text(itemType.toUpperCase(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text('Suggested $quantity', style: GoogleFonts.inter(color: Colors.red.shade900, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}