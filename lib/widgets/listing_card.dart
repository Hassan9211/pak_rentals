import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final double? width;

  const ListingCard({super.key, required this.listing, this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    // Default: ~42% of screen width so 2+ cards are visible
    final cardWidth = width ?? (MediaQuery.of(context).size.width * 0.42).clamp(150.0, 180.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: listing.bgColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      listing.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  if (listing.badge != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: listing.badgeColor ?? AppColors.cyan,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          listing.badge!,
                          style: GoogleFonts.dmSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: listing.badgeColor != null
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${listing.location}',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: listing.price,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan,
                              ),
                            ),
                            TextSpan(
                              text: listing.priceUnit,
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '⭐ ${listing.rating}',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LIST ITEM (search results) ──
class ListingListItem extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const ListingListItem({super.key, required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 54,
              decoration: BoxDecoration(
                color: listing.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  listing.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (listing.badge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (listing.badgeColor ?? AppColors.cyan)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: (listing.badgeColor ?? AppColors.cyan)
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        listing.badge!,
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: listing.badgeColor ?? AppColors.cyan,
                        ),
                      ),
                    ),
                  Text(
                    listing.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${listing.location}',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'PKR ${listing.price}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan,
                              ),
                            ),
                            TextSpan(
                              text: listing.priceUnit,
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '⭐ ${listing.rating} (${listing.reviews})',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
