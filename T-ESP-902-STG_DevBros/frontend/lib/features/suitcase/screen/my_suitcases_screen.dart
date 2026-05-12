import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/core/widgets/profile_button.dart';
import 'package:inspiria/features/suitcase/data/suitcase_service.dart';
import 'package:inspiria/routes/router_enum.dart';

class MySuitcasesScreen extends StatefulWidget {
  const MySuitcasesScreen({super.key});

  @override
  State<MySuitcasesScreen> createState() => _MySuitcasesScreenState();
}

class _MySuitcasesScreenState extends State<MySuitcasesScreen> {
  List<SuitcaseModel> _suitcases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuitcases();
  }

  Future<void> _fetchSuitcases() async {
    final userId = await TokenStorage().getUserId();

    if (userId != null) {
      final response = await SuitcaseService.getAllSuitcaseByUserId(
        userId.toString(),
      );

      if (mounted) {
        setState(() {
          _suitcases = response?.suitcaseList ?? [];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAndDeleteSuitcase(int suitcaseId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Suitcase ?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this trip ?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await SuitcaseService.deleteSuitcase(
        suitcaseId.toString(),
      );

      if (success && mounted) {
        setState(() {
          _suitcases.removeWhere((element) => element.id == suitcaseId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Suitcase deleted successfully',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error occurred while deleting suitcase',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getImageAsset(String? destination) {
    if (destination == null) return 'assets/images/ParisValise.png';

    final dest = destination.toLowerCase();
    if (dest.contains('paris')) return 'assets/images/ParisValise.png';
    if (dest.contains('bali')) return 'assets/images/BaliValise.png';
    if (dest.contains('dubai')) return 'assets/images/DubaiValise.png';
    if (dest.contains('london')) return 'assets/images/LondonValise.png';
    if (dest.contains('newyork') || dest.contains('new york')) {
      return 'assets/images/NewyorkValise.png';
    }
    if (dest.contains('japon') || dest.contains('tokyo')) {
      return 'assets/images/JaponValise.png';
    }

    return 'assets/images/VoyageValise.png';
  }

  @override
  Widget build(BuildContext context) {
    final int count = _suitcases.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(SCREEN.TRAVEL.path);
            }
          },
        ),
        title: Image.asset(
          'assets/images/InspiriaLogoV2.png',
          height: 20,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
        centerTitle: true,
        actions: const [ProfileButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Suitcases',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isLoading
                        ? SizedBox(
                            height: 14,
                            width: 100,
                            child: LinearProgressIndicator(
                              color: Colors.grey.shade200,
                            ),
                          )
                        : Text(
                            '$count suitcase${count > 1 ? 's' : ''} registered',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : count == 0
                    ? _buildEmptyState(context)
                    : _buildSuitcaseList(),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.luggage, size: 40, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            Text(
              'No suitcase registered',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start planning your first trip by generating a suitcase',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuitcaseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _suitcases.length,
      itemBuilder: (context, index) {
        final suitcase = _suitcases[index];
        return _buildSuitcaseCard(suitcase, context);
      },
    );
  }

  Widget _buildSuitcaseCard(SuitcaseModel suitcase, BuildContext context) {
    final DateTime departure = suitcase.departure_date;
    final DateTime end = suitcase.end_date;

    final durationDays = end.difference(departure).inDays;

    // Formatage de la date : JJ/MM/AAAA
    final String formattedDeparture =
        "${departure.day.toString().padLeft(2, '0')}/${departure.month.toString().padLeft(2, '0')}/${departure.year}";

    final imageAsset = _getImageAsset(suitcase.destination);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          suitcase.destination,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (suitcase.id != null) {
                          _confirmAndDeleteSuitcase(suitcase.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$durationDays days',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Le Spacer() permet de pousser la date vers la droite
                    const Spacer(),
                    Text(
                      formattedDeparture,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .push('/suitcase-detail', extra: suitcase);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open Suitcase',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
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
  }
}