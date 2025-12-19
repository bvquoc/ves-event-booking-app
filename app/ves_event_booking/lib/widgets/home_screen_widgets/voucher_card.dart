import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onUse;
  final VoidCallback? onDetail;

  const VoucherCard({
    super.key,
    required this.voucher,
    this.onUse,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100, 
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: _VoucherContent(voucher: voucher, onDetail: onDetail),
              ),
            ),

            _VoucherAction(isUsed: voucher.isUsed ?? false, onUse: onUse),
          ],
        ),
      ),
    );
  }
}

class _VoucherContent extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onDetail;

  const _VoucherContent({required this.voucher, this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          voucher.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HSD : ${_formatDate(voucher.endDate)}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),

            GestureDetector(
              onTap: onDetail,
              child: const Text(
                'Chi tiết',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontStyle: FontStyle.italic
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _VoucherAction extends StatelessWidget {
  final bool isUsed;
  final VoidCallback? onUse;

  const _VoucherAction({required this.isUsed, this.onUse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: double.infinity,
      child: Material(
        color: Colors.blue,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
        child: InkWell(
          onTap: isUsed ? null : onUse,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(14),
          ),
          child: const Center(
            child: Text(
              'ĐỔI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
