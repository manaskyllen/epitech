import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/api/service/city_service.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/core/widgets/animated_widgets.dart';
import 'package:inspiria/core/widgets/profile_button.dart';
import 'package:inspiria/features/suitcase/data/suitcase_service.dart';

class DestinationData {
  const DestinationData(this.city, this.country, this.imagePath);
  final String city;
  final String country;
  final String imagePath;
}

class SuitcaseScreen extends StatefulWidget {
  const SuitcaseScreen({super.key});

  @override
  State<SuitcaseScreen> createState() => _SuitcaseScreenState();
}

class _SuitcaseScreenState extends State<SuitcaseScreen> {
  int? _selectedSuitcaseIndex = 1;
  int? _customDuration;
  String? _selectedCity;
  DateTime _startDate = DateTime.now();
  final TextEditingController _customCityController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  Timer? _debounce;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _suitcases = [
    {'title': 'Small', 'subtitle': '3 days', 'days': 3, 'image': 'assets/images/petite_valise.png'},
    {'title': 'Medium', 'subtitle': '7 days', 'days': 7, 'image': 'assets/images/moyenne_valise.png'},
    {'title': 'Large', 'subtitle': '15 days', 'days': 15, 'image': 'assets/images/grande_valise.png'},
  ];

  final List<DestinationData> _destinations = [
    const DestinationData('Paris', 'France', 'assets/images/paris.png'),
    const DestinationData('Tokyo', 'Japan', 'assets/images/japon.png'),
    const DestinationData('New York', 'USA', 'assets/images/newyork.png'),
    const DestinationData('Bali', 'Indonesia', 'assets/images/Bali.png'),
    const DestinationData('London', 'UK', 'assets/images/London.png'),
    const DestinationData('Dubai', 'UAE', 'assets/images/dubai.png'),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _customCityController.dispose();
    super.dispose();
  }

  void _generateSuitcase() async {
    String dest = _customCityController.text.trim();
    if (dest.isEmpty) dest = _selectedCity ?? '';

    if (dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a destination')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final int? userId = await TokenStorage().getUserId();

    if (!mounted || userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final SuitcaseModel newSuitcase = SuitcaseModel(
      name: 'Trip to $dest',
      departure_date: _startDate,
      end_date: _startDate.add(Duration(days: _customDuration ?? 7)),
      destination: dest,
      user_id: userId,
    );

    final response = await SuitcaseService.createSuitcase(newSuitcase);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      await context.push('/resultat-test', extra: response.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 25),
            _buildSuitcaseList(),
            const SizedBox(height: 30),
            _buildDurationSlider(),
            const SizedBox(height: 25),
            _buildDateSection(),
            const SizedBox(height: 30),
            _buildPopularDestinations(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'OTHER DESTINATIONS',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCitySearchField(),
            ),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySearchField() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), // Fixed deprecation
              blurRadius: 10,
            ),
          ],
        ),
        child: RawAutocomplete<CitySuggestion>(
          textEditingController: _customCityController,
          focusNode: FocusNode(),
          displayStringForOption: (option) => option.name,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 3) return const Iterable<CitySuggestion>.empty();

            if (_debounce?.isActive ?? false) _debounce!.cancel();
            final completer = Completer<Iterable<CitySuggestion>>();

            _debounce = Timer(const Duration(milliseconds: 500), () async {
              final results = await CityService.searchCities(textEditingValue.text);
              completer.complete(results);
            });

            return completer.future;
          },
          onSelected: (selection) {
            setState(() {
              _selectedCity = selection.name;
              _customCityController.text = selection.name;
            });
            FocusScope.of(context).unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search a city...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(option.fullAddress),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/InspiriaLogoV2.png', height: 25),
        actions: const [ProfileButton()],
      );

  Widget _buildBanner() => Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/images/Voyage.png'),
            fit: BoxFit.cover,
          ),
        ),
      );

  Widget _buildSuitcaseList() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _suitcases.length,
            (i) => StaggeredAnimationCard(index: i, child: _buildSuitcaseCard(i)),
          ),
        ),
      );

  Widget _buildSuitcaseCard(int i) {
    final item = _suitcases[i];
    final isSelected = _selectedSuitcaseIndex == i;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedSuitcaseIndex = i;
        _customDuration = item['days'];
      }),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Image.asset(item['image'] as String, height: 60),
            const SizedBox(height: 12),
            Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(item['subtitle'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSlider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CUSTOM DURATION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_customDuration ?? 7} days', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Slider(
              value: (_customDuration ?? 7).toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: Colors.black,
              onChanged: (v) => setState(() {
                _customDuration = v.toInt();
                _selectedSuitcaseIndex = null;
              }),
            ),
          ],
        ),
      );

  Widget _buildDateSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DEPARTURE DATE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            _buildDatePickerField(),
          ],
        ),
      );

  Widget _buildDatePickerField() {
    final formattedDate = "${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}";
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.black)),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(formattedDate),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinations() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('POPULAR DESTINATIONS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 15),
          _buildDestinationGrid(),
        ],
      );

  Widget _buildDestinationGrid() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.3,
          ),
          itemCount: _destinations.length,
          itemBuilder: (context, i) {
            final d = _destinations[i];
            final isSelected = _selectedCity == d.city;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCity = d.city;
                _customCityController.text = d.city;
              }),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(d.imagePath, height: 40),
                    const Spacer(),
                    Text(d.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(d.country, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _buildActionButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateSuitcase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GENERATE MY SUITCASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/my-suitcases'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('VIEW MY SUITCASES', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
}