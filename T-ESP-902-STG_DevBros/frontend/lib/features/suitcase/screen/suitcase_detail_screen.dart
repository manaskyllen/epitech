import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/core/widgets/profile_button.dart';

class SuitcaseDetailScreen extends StatefulWidget {
  const SuitcaseDetailScreen({
    super.key,
    required this.suitcase,
  });

  final SuitcaseModel suitcase;

  @override
  State<SuitcaseDetailScreen> createState() => _SuitcaseDetailScreenState();
}

class _SuitcaseDetailScreenState extends State<SuitcaseDetailScreen> {
  String _getImageAsset(String? destination) {
    if (destination == null) return 'assets/images/VoyageValise.png';

    final dest = destination.toLowerCase();
    if (dest.contains('paris')) return 'assets/images/ParisValise.png';
    if (dest.contains('bali')) return 'assets/images/BaliValise.png';
    if (dest.contains('dubai')) return 'assets/images/DubaiValise.png';
    if (dest.contains('london')) return 'assets/images/LondonValise.png';
    if (dest.contains('new york') || dest.contains('newyork')) {
      return 'assets/images/NewyorkValise.png';
    }
    if (dest.contains('japon') || dest.contains('tokyo')) {
      return 'assets/images/JaponValise.png';
    }

    return 'assets/images/VoyageValise.png';
  }

  String _getCategoryIcon(String? itemName) {
    if (itemName == null) return '👕';
    final name = itemName.toLowerCase();

    // Hauts
    if (name.contains('t-shirt') || name.contains('tshirt') || name.contains('tee shirt')) return '👕';
    if (name.contains('poloshirt') || name.contains('polo')) return '👕';
    if (name.contains('shirt') && !name.contains('t-shirt') && !name.contains('polo')) return '👔';
    if (name.contains('sweater') || name.contains('pullover') || name.contains('jumper')) return '🧶';
    if (name.contains('hoodie')) return '🧥';

    // Bas
    if (name.contains('short')) return '🩳';
    if (name.contains('jeans') || name.contains('jean')) return '👖';
    if (name.contains('pants') || name.contains('trouser')) return '👖';
    if (name.contains('skirt')) return '👗'; // Pas d'émoji jupe dédié, on utilise robe

    // Extérieur
    if (name.contains('coat') || name.contains('jacket')) return '🧥';
    if (name.contains('scarf')) return '🧣';
    if (name.contains('gloves')) return '🧤';
    if (name.contains('hat') || name.contains('cap')) return '🧢';

    // Chaussures
    if (name.contains('shoes') || name.contains('sneakers')) return '👟';
    if (name.contains('boots')) return '🥾';
    if (name.contains('sandals') || name.contains('flipflop')) return '🩴';
    if (name.contains('formal shoes') || name.contains('dress shoes')) return '👞';

    // Accessoires
    if (name.contains('backpack') || name.contains('bag')) return '🎒';
    if (name.contains('suitcase')) return '🧳';
    if (name.contains('sunglasses') || name.contains('glasses')) return '👓';
    if (name.contains('watch')) return '⌚';
    if (name.contains('umbrella')) return '🌂';
    if (name.contains('wallet')) return '👛';

    // Sous-vêtements / Divers
    if (name.contains('socks')) return '🧦';
    if (name.contains('underwear')) return '🩲';
    if (name.contains('swimsuit') || name.contains('swimwear')) return '🩱';

    return '👕'; // Par défaut si non trouvé
  }

  @override
  Widget build(BuildContext context) {
    final imageAsset = _getImageAsset(widget.suitcase.destination);
    // Utilisation directe de la liste clothings du modèle
    final clothings = widget.suitcase.clothings ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/InspiriaLogoV2.png',
          height: 20,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
        centerTitle: true,
        actions: const [ProfileButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec image
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.suitcase.destination,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.suitcase.name,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Trip details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTripInfo(
                      icon: Icons.calendar_today_outlined,
                      label: 'Duration',
                      value:
                          '${widget.suitcase.end_date.difference(widget.suitcase.departure_date).inDays} days',
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildTripInfo(
                      icon: Icons.date_range_outlined,
                      label: 'Departure',
                      value:
                          '${widget.suitcase.departure_date.day}/${widget.suitcase.departure_date.month}',
                    ),
                  ],
                ),
              ),
            ),

            // Items section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ITEMS IN YOUR SUITCASE',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${clothings.length}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items list
            if (clothings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No items in your suitcase',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: clothings.length,
                  itemBuilder: (context, index) {
                    final item = clothings[index];
                    return _buildClothingItem(item, index);
                  },
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildClothingItem(Map<String, dynamic> item, int index) {
    // Adaptation au retour API : "itemSubtype" sert de nom et "itemType" de catégorie
    final name = item['itemSubtype'] ?? 'Item ${index + 1}';
    final category = item['itemType'] ?? 'General';
    // Le retour API n'a pas de champ quantity direct, on affiche 1 ou on peut utiliser le pivot si nécessaire
    final quantity = 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon - Utilisation de la fonction de mapping intelligente sur le nom
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _getCategoryIcon(name),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'x$quantity',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}