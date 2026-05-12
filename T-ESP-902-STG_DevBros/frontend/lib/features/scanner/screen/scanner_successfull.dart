import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/features/outfit/data/clothing_material/clothing_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class ScannerSuccessfull extends StatefulWidget {
  const ScannerSuccessfull({super.key, this.data});
  final Map<String, dynamic>? data;

  @override
  State<ScannerSuccessfull> createState() => _ScannerSuccessfullState();
}

class _ScannerSuccessfullState extends State<ScannerSuccessfull> {
  late TextEditingController _typeController;
  late TextEditingController _subTypeController;
  late TextEditingController _colorController;
  late TextEditingController _seasonController;
  late TextEditingController _sizeController;
  late TextEditingController _genderController;
  late TextEditingController _styleController;
  late TextEditingController _textureController;
  
  String _aiDetectedStyle = 'Casual';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> rawData = widget.data ?? {};
    final Map<String, dynamic> aiResponse = rawData['aiData'] ?? {};
    final Map<String, dynamic> aiFields = aiResponse['data'] ?? {};

    _typeController = TextEditingController(text: (aiFields['ItemType'] ?? 'top').toString());
    _subTypeController = TextEditingController(text: (aiFields['ItemSubtype'] ?? '').toString());
    
    String colorText = 'Unknown';
    final colorValue = aiFields['Color'];
    if (colorValue is List && colorValue.isNotEmpty) {
      colorText = colorValue[0].toString();
    } else if (colorValue is String) {
      colorText = colorValue;
    }

    _colorController = TextEditingController(text: colorText);
    _seasonController = TextEditingController(text: (aiFields['Season'] ?? 'Autumn').toString());
    _sizeController = TextEditingController(text: (aiFields['Size'] ?? 'M').toString());
    _genderController = TextEditingController(text: (aiFields['Gender'] ?? 'unisex').toString());
    _styleController = TextEditingController(text: (aiFields['Style'] ?? 'casual').toString());
    _textureController = TextEditingController(text: (aiFields['texture'] ?? 'standard').toString());
    
    final rawStyle = aiFields['style']?.toString() ?? 'casual';
    _aiDetectedStyle = rawStyle.isNotEmpty ? rawStyle[0].toUpperCase() + rawStyle.substring(1) : 'Casual';
  }

  @override
  void dispose() {
    for (final c in [_typeController, _subTypeController, _colorController, _seasonController, _sizeController, _genderController, _styleController, _textureController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleStoreItem() async {
    setState(() => _isSaving = true);
    try {
      final int? userId = await TokenStorage().getUserId();
      final File? imageFile = widget.data?['imageFile'];

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      if (imageFile == null) {
        throw Exception('Image file not found.');
      }

      final Map<String, dynamic> finalData = {
        'itemType': _typeController.text,
        'itemSubtype': _subTypeController.text,
        'color': _colorController.text,
        'size': _sizeController.text,
        'style': _styleController.text,
        'season': _seasonController.text,
        'fabric': 'cotton', 
        'gender': _genderController.text,
        'texture': _textureController.text,
        'user_id': userId,
      };

      final success = await ClothingService.storeClothingFinal(finalData, imageFile);
      
      if (mounted) {
        if (success) {
          context.go(SCREEN.HOMEPAGE.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save item in database')),
          );
        }
      }
    } catch (e) {
      debugPrint('Store Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final File? imageFile = widget.data?['imageFile'];

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 20),
                _buildItemPreview(imageFile),
                const Divider(height: 35, color: Color(0xFFF5F5F5), thickness: 1.5),
                
                _buildEditableField('CATEGORY', _typeController),
                _buildEditableField('SUB-CATEGORY', _subTypeController),
                
                Row(
                  children: [
                    Expanded(child: _buildEditableField('COLOR', _colorController)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildEditableField('SEASON', _seasonController)),
                  ],
                ),
                
                Row(
                  children: [
                    Expanded(child: _buildEditableField('SIZE', _sizeController)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildEditableField('GENDER', _genderController)),
                  ],
                ),
                
                _buildEditableField('STYLE', _styleController),
                _buildEditableField('TEXTURE', _textureController),
                
                const SizedBox(height: 15),
                _buildAiSuggestions(),
                
                const SizedBox(height: 25),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderButton(
          icon: Icons.arrow_back, 
          onTap: () => context.go(SCREEN.SCANNER.path),
        ),
        const Text('Verify Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
        _buildHeaderButton(
          icon: Icons.close, 
          onTap: () => context.go(SCREEN.SCANNER.path),
        ),
      ],
    );
  }

  Widget _buildItemPreview(File? imageFile) {
    return Row(
      children: [
        Container(
          height: 60, width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), 
            color: const Color(0xFFF8F8F8),
            border: Border.all(color: const Color(0xFFEEEEEE))
          ),
          child: imageFile != null 
            ? ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(imageFile, fit: BoxFit.cover))
            : const Icon(Icons.image_outlined, color: Colors.grey),
        ),
        const SizedBox(width: 15),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI SCAN COMPLETE', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
              SizedBox(height: 2),
              Text('Review details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)),
              Text('Correct any mistakes before saving', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          SizedBox(
            height: 32,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF0F0F0), width: 1.5)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI STYLE SUGGESTION', style: TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.2))
            ),
            child: Text(
              _aiDetectedStyle, 
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleStoreItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isSaving 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('CONFIRM & SAVE', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(24)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_filled, color: Colors.white, size: 22),
          Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 22),
          Icon(Icons.add_circle_outline, color: Colors.grey, size: 22),
          Icon(Icons.person_outline, color: Colors.grey, size: 22),
        ],
      ),
    );
  }
}