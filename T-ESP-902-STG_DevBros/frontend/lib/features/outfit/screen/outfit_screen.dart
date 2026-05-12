import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/clothing_model.dart';
import 'package:inspiria/core/response/clothing_responce.dart';
import 'package:inspiria/core/services/stockage/minio_service.dart';
import 'package:inspiria/features/outfit/data/clothing_material/clothing_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  bool _isGridViewSelected = true; 
  String _selectedCategory = 'tshirt';
  
  String _searchQuery = ''; 

  late Future<ClothingResponces?> _clothingFuture;

  final Color _kLightGray = const Color(0xFFF8F9FA); 
  
 @override
void initState() {
  super.initState();
  _clothingFuture = _loadClothing();
}

Future<ClothingResponces?> _loadClothing() async {
  await TokenStorage().getAccessToken();
  final userId = await TokenStorage().getUserId();
  return ClothingService.getClothingByUserId(userId.toString());
}

  String? _getDatabaseCategoryName(String key) {
    switch (key) {
      case 'sweater': return 'Top';      
      case 'personDress': return 'Bottom';
      case 'shoePrints': return 'Shoe';   
      case 'headwear': return 'Headwear'; 
      default: return null; 
    }
  }

  int _countItems(List<ClothingModel> allItems, String categoryKey) {
    if (categoryKey == 'tshirt') return allItems.length;

    final dbName = _getDatabaseCategoryName(categoryKey);
    if (dbName == null) return 0;

    return allItems.where((item) {
      final itemType = item.itemType?.toLowerCase() ?? '';
      return itemType.contains(dbName.toLowerCase());
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final Map<String, String> categories = {
      'tshirt': 'All Items',
      'sweater': 'Tops',
      'personDress': 'Bottoms',
      'shoePrints': 'Shoes',
      'headwear':'Headwear'
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSquircleBtn(
                    icon: Icons.arrow_back, 
                    onTap: () => context.go(SCREEN.HOMEPAGE.path)
                  ),
                  const Text(
                    'MY CLOSET',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                  _buildSquircleBtn(icon: Icons.tune, onTap: () {}), 
                ],
              ),
              
              SizedBox(height: screenHeight * 0.03),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(color: _kLightGray, borderRadius: BorderRadius.circular(16)),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'Search by color...', // TODO faire la recherche sur le nom ??
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: _kLightGray, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _buildSegmentBtn(icon: Icons.grid_view, isActive: _isGridViewSelected, onTap: () => setState(() => _isGridViewSelected = true)),
                        const SizedBox(width: 4),
                        _buildSegmentBtn(icon: Icons.format_list_bulleted, isActive: !_isGridViewSelected, onTap: () => setState(() => _isGridViewSelected = false)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.03),

              Expanded(
                child: FutureBuilder<ClothingResponces?>(
                  future: _clothingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(child: Text("Erreur : ${snapshot.error ?? 'Inconnue'}"));
                    }

                    final response = snapshot.data!;
                    final allItems = response.clothingList ?? [];
                    
                    final targetCategory = _getDatabaseCategoryName(_selectedCategory);
                    
                    final filteredList = allItems.where((item) {
                      bool matchesCategory = true;
                      if (targetCategory != null) {
                        final itemType = item.itemType?.toLowerCase() ?? '';
                        matchesCategory = itemType.contains(targetCategory.toLowerCase());
                      }

                      bool matchesSearch = true;
                      if (_searchQuery.isNotEmpty) {
                        final color = item.color?.toLowerCase() ?? '';
                        matchesSearch = color.contains(_searchQuery.toLowerCase());
                        
                        // Si on veux aussi chercher par Type ->
                        // final type = item.itemType?.toLowerCase() ?? '';
                        // matchesSearch = color.contains(_searchQuery.toLowerCase()) || type.contains(_searchQuery.toLowerCase());
                      }

                      return matchesCategory && matchesSearch;
                    }).toList();

                    return Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.entries.map((entry) {
                              final isSelected = _selectedCategory == entry.key;
                              final count = _countItems(allItems, entry.key); 
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0F172A) : _kLightGray,
                                      borderRadius: BorderRadius.circular(30), 
                                    ),
                                    child: Row(
                                      children: [
                                        FaIcon(_getIcon(entry.key), size: 16, color: isSelected ? Colors.blue[200] : Colors.blue[700]),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.value, 
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87, 
                                            fontWeight: FontWeight.w600
                                          )
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          count.toString(), 
                                          style: TextStyle(
                                            color: isSelected ? Colors.grey[400] : Colors.grey[500], 
                                            fontSize: 12
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        Expanded(
                          child: filteredList.isEmpty 
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('No clothing found.'),
                                  if (_searchQuery.isNotEmpty) 
                                    const SizedBox(height: 20),
                                  if (_searchQuery.isNotEmpty) 
                                     const Padding(
                                       padding: EdgeInsets.all(32.0),
                                      //  child: AddItemCard(isGridView: false, onTap: () => print("Add Item")),
                                     )
                                ],
                              ),
                            )
                          : CustomScrollView(
                              slivers: [
                                _isGridViewSelected
                                    ? SliverGrid(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.65,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                        ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return ClothingGridCard(clothingItem: filteredList[index]);
                                          },
                                          childCount: filteredList.length,
                                        ),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: ClothingListCard(clothingItem: filteredList[index]),
                                            );
                                          },
                                          childCount: filteredList.length,
                                        ),
                                      ),

                                const SliverToBoxAdapter(
                                  // child: Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 16),
                                  //   child: AddItemCard(
                                  //     isGridView: false, 
                                  //     onTap: () => print("Go to Add Item Page"),
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquircleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: _kLightGray, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  Widget _buildSegmentBtn({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, spreadRadius: 1)] : null,
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.grey[600], size: 20),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'tshirt': return FontAwesomeIcons.shirt;
      case 'sweater': return FontAwesomeIcons.layerGroup;
      case 'personDress': return FontAwesomeIcons.personDress;
      case 'shoePrints': return FontAwesomeIcons.shoePrints;
      case 'headwear' : return FontAwesomeIcons.hatCowboy;
      default: return FontAwesomeIcons.tags;
    }
  }
}

class AddItemCard extends StatelessWidget {

  const AddItemCard({super.key, required this.isGridView, required this.onTap});
  final bool isGridView;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isGridView ? null : 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300), 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF111827), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Add New Item',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1E293B),
                decorationThickness: 2,
              ),
            ),
            const SizedBox(height: 4),
            
            Text(
              'Scan or upload from gallery',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ClothingListCard extends StatelessWidget {

  const ClothingListCard({super.key, required this.clothingItem});
  final ClothingModel clothingItem;

  @override
  Widget build(BuildContext context) {
    final String imageName = '${clothingItem.id}.jpeg';

    return Container(
      height: 110, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<Uint8List?>(
                future: MinioService.getFile(imageName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  }
                  return const Icon(Icons.image_not_supported, color: Colors.grey); 
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  clothingItem.itemType ?? 'Unknown clothing',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  clothingItem.color ?? 'Unknown color',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Color(0xFFFF4B4B), size: 18),
              ],
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Text(
                  clothingItem.size ?? '-', 
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClothingGridCard extends StatelessWidget {

  const ClothingGridCard({super.key, required this.clothingItem});
  final ClothingModel clothingItem;

  @override
  Widget build(BuildContext context) {
    final String imageName = '${clothingItem.id}.jpeg'; 

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: FutureBuilder<Uint8List?>(
                      future: MinioService.getFile(imageName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(snapshot.data!, fit: BoxFit.cover);
                        }
                        return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)); 
                      },
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            clothingItem.itemType ?? 'Unknown clothing',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star, color: Color(0xFFFF4B4B), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clothingItem.color ?? 'Unknown color',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      clothingItem.size ?? '-',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}