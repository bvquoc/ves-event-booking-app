import '../models/voucher_model.dart';

final List<VoucherModel> mockVouchers = [
  VoucherModel(
    id: 'vch_001',
    code: 'WELCOME10',
    title: 'Giảm 100% vé cho sự kiện đầu. Tối đa 10.000đ khi ...',
    description:
        'Áp dụng cho đơn hàng đầu tiên. Giảm tối đa 10.000đ cho mỗi đơn hàng.',
    discountType: 'fixed_amount',
    discountValue: 10000,
    minOrderAmount: 0,
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2025, 6, 25),
    isUsed: false,
  ),
  VoucherModel(
    id: 'vch_002',
    code: 'SUMMER50',
    title: 'Giảm 50% cho vé mùa hè',
    description:
        'Giảm 50% giá vé cho các sự kiện trong mùa hè. Tối đa 50.000đ.',
    discountType: 'percentage',
    discountValue: 50,
    minOrderAmount: 100000,
    startDate: DateTime(2024, 6, 1),
    endDate: DateTime(2025, 7, 10),
    isUsed: false,
  ),
  VoucherModel(
    id: 'vch_003',
    code: 'USED2024',
    title: 'Voucher đã sử dụng',
    description: 'Voucher này đã được sử dụng trước đó.',
    discountType: 'fixed_amount',
    discountValue: 20000,
    minOrderAmount: 200000,
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 12, 31),
    isUsed: true,
  ),
];
