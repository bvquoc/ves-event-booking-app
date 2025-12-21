import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/voucher/voucher_status_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherStatusModel voucherStatus;
  final VoidCallback? onDetail;

  const VoucherCard({super.key, required this.voucherStatus, this.onDetail});

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
                child: _VoucherContent(
                  voucherStatus: voucherStatus,
                  onDetail: onDetail,
                ),
              ),
            ),

            _VoucherAction(onDetail: onDetail),
          ],
        ),
      ),
    );
  }
}

class _VoucherContent extends StatelessWidget {
  final VoucherStatusModel voucherStatus;
  final VoidCallback? onDetail;

  const _VoucherContent({required this.voucherStatus, this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          voucherStatus.voucher.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HSD : ${_formatDate(voucherStatus.voucher.endDate)}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
  final VoidCallback? onDetail;

  const _VoucherAction({this.onDetail});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: double.infinity,
      child: Material(
        color: Colors.blue,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
        child: InkWell(
          onTap: onDetail,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(14),
          ),
          child: const Center(
            child: Text(
              'Chi tiết',
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
