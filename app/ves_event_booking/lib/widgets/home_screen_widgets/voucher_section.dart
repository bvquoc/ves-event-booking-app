import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/voucher/voucher_status_model.dart';
import 'section_header.dart';
import 'voucher_card.dart';

class VoucherSection extends StatelessWidget {
  final List<VoucherStatusModel> voucherStatusList;
  final VoidCallback? onViewAll;

  const VoucherSection({
    super.key,
    required this.voucherStatusList,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (voucherStatusList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(title: 'Voucher giảm giá', onTap: onViewAll),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: voucherStatusList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return VoucherCard(
                voucherStatus: voucherStatusList[index],
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
