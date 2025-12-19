import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import 'section_header.dart';
import 'voucher_card.dart';

class VoucherSection extends StatelessWidget {
  final List<VoucherModel> vouchers;
  final VoidCallback? onViewAll;

  const VoucherSection({
    super.key,
    required this.vouchers,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (vouchers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: 'Voucher giảm giá',
          onTap: onViewAll,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return VoucherCard(
                voucher: vouchers[index],
                onUse: () {
                  // TODO: apply voucher
                },
                onDetail: () {
                  // TODO: open voucher detail
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
