import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/repositories/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository({DateTime? now})
    : _snapshot = _initialSnapshot(now ?? DateTime.now());

  WalletSnapshot _snapshot;

  @override
  WalletSnapshot load() => _snapshot;

  @override
  void save(WalletSnapshot snapshot) => _snapshot = snapshot;

  static WalletSnapshot _initialSnapshot(DateTime now) => WalletSnapshot(
    coinBalance: 2480,
    cashBalance: 150000,
    memberTier: 'Thành viên Vàng',
    coinsToNextTier: 520,
    tierProgress: 0.72,
    checkedInToday: false,
    lastCheckInDay: null,
    vouchers: _initialVouchers(now),
    transactions: _initialTransactions(),
  );

  static String _expiryInDays(DateTime now, int days) {
    final date = DateTime(now.year, now.month, now.day + days);
    return 'HSD: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static List<VoucherEntity> _initialVouchers(DateTime now) => [
    VoucherEntity(
      id: 'v_freeship_all',
      code: 'FREESHIP40K',
      title: 'Freeship toàn quốc',
      description: 'Giảm tối đa 40.000₫ cho mọi đơn hàng',
      discountValue: 'FREE',
      discountLabel: 'SHIP',
      type: VoucherType.shipping,
      maxDiscount: 40000,
      expiryDate: _expiryInDays(now, 3),
      isMint: true,
      tag: 'HOT',
      isSaved: true,
    ),
    VoucherEntity(
      id: 'v_order_30k',
      code: 'NEORA30K',
      title: 'Giảm 30K đơn từ 299K',
      description: 'Áp dụng cho toàn bộ bộ sưu tập NÉORA',
      discountValue: '30K',
      discountLabel: 'GIẢM',
      type: VoucherType.discount,
      minOrderValue: 299000,
      maxDiscount: 30000,
      expiryDate: _expiryInDays(now, 5),
      tag: 'BÁN CHẠY',
      isSaved: true,
    ),
    VoucherEntity(
      id: 'v_vip_80k',
      code: 'VIPNEORA',
      title: 'Độc quyền Hội viên Vàng',
      description: 'Giảm 10% tối đa 80.000₫ đơn từ 499.000₫',
      discountValue: '10%',
      discountLabel: 'GIẢM',
      type: VoucherType.vipOnly,
      minOrderValue: 499000,
      maxDiscount: 80000,
      expiryDate: _expiryInDays(now, 42),
      tag: 'ĐỘC QUYỀN VIP',
      isSaved: true,
    ),
    VoucherEntity(
      id: 'v_coin_5p',
      code: 'COINBACK5',
      title: 'Hoàn xu hội viên',
      description: 'Hoàn 5% xu NÉORA không giới hạn cho mọi đơn',
      discountValue: '5%',
      discountLabel: 'XU',
      type: VoucherType.coinReward,
      expiryDate: _expiryInDays(now, 15),
      isMint: true,
    ),
    VoucherEntity(
      id: 'v_freeship_299',
      code: 'SHIPFAST25',
      title: 'Freeship hoả tốc nội thành',
      description: 'Giảm 25.000₫ phí giao hỏa tốc',
      discountValue: '25K',
      discountLabel: 'SHIP',
      type: VoucherType.shipping,
      minOrderValue: 250000,
      maxDiscount: 25000,
      expiryDate: _expiryInDays(now, 7),
      isMint: true,
    ),
    VoucherEntity(
      id: 'v_order_50k',
      code: 'NEORA50K',
      title: 'Giảm 50K đơn từ 599K',
      description: 'Đơn từ 599K có sản phẩm NÉORA Collection',
      discountValue: '50K',
      discountLabel: 'GIẢM',
      type: VoucherType.discount,
      minOrderValue: 599000,
      maxDiscount: 50000,
      expiryDate: _expiryInDays(now, 10),
    ),
    VoucherEntity(
      id: 'v_vip_diamond',
      code: 'VIPDIAMOND',
      title: 'Đặc quyền VIP Kim Cương',
      description: 'Giảm 15% tối đa 150.000₫ cho đơn từ 999K',
      discountValue: '15%',
      discountLabel: 'GIẢM',
      type: VoucherType.vipOnly,
      minOrderValue: 999000,
      maxDiscount: 150000,
      expiryDate: _expiryInDays(now, 73),
      tag: 'ĐỘC QUYỀN VIP',
    ),
    VoucherEntity(
      id: 'v_freeship_max',
      code: 'FREESHIPMAX',
      title: 'Freeship đơn từ 500K',
      description: 'Miễn phí vận chuyển toàn quốc tối đa 50K',
      discountValue: '50K',
      discountLabel: 'SHIP',
      type: VoucherType.shipping,
      minOrderValue: 500000,
      maxDiscount: 50000,
      expiryDate: _expiryInDays(now, 12),
      isMint: true,
    ),
    VoucherEntity(
      id: 'v_order_100k',
      code: 'NEORA100K',
      title: 'Giảm 100K đơn từ 1.200K',
      description: 'Đơn từ 1.200K có sản phẩm Đầm',
      discountValue: '100K',
      discountLabel: 'GIẢM',
      type: VoucherType.discount,
      minOrderValue: 1200000,
      maxDiscount: 100000,
      expiryDate: _expiryInDays(now, 20),
    ),
    VoucherEntity(
      id: 'v_freeship_express',
      code: 'SHIPEXP',
      title: 'Freeship đơn đầu tiên',
      description: 'Áp dụng cho khách hàng mới của NÉORA',
      discountValue: 'FREE',
      discountLabel: 'SHIP',
      type: VoucherType.shipping,
      maxDiscount: 35000,
      expiryDate: _expiryInDays(now, 14),
      isMint: true,
    ),
    VoucherEntity(
      id: 'v_vip_gift',
      code: 'VIPGIFT',
      title: 'Quà tặng NÉORA Exclusive',
      description: 'Tặng khăn lụa tơ tằm NÉORA cho đơn từ 1.500K',
      discountValue: 'GIFT',
      discountLabel: 'TẶNG',
      type: VoucherType.vipOnly,
      minOrderValue: 1500000,
      expiryDate: _expiryInDays(now, 73),
      isMint: true,
      tag: 'ĐỘC QUYỀN VIP',
    ),
    VoucherEntity(
      id: 'v_order_new10',
      code: 'NEORANEW10',
      title: 'Giảm 10% bộ sưu tập mới',
      description: 'Đơn từ 399K có sản phẩm gắn nhãn MỚI',
      discountValue: '10%',
      discountLabel: 'GIẢM',
      type: VoucherType.discount,
      minOrderValue: 399000,
      maxDiscount: 70000,
      expiryDate: _expiryInDays(now, 30),
    ),
  ];

  static List<WalletTransactionEntity> _initialTransactions() => const [
    WalletTransactionEntity(
      id: 'tx_1',
      title: 'Tích xu đơn hàng #NEO-8821',
      coinDelta: 120,
      date: 'Hôm qua, 14:32',
      icon: '🛍️',
    ),
    WalletTransactionEntity(
      id: 'tx_2',
      title: 'Đổi mã freeship 40.000₫',
      coinDelta: -200,
      date: '12/10/2026',
      icon: '🎟️',
    ),
    WalletTransactionEntity(
      id: 'tx_3',
      title: 'Thưởng thăng hạng Hội viên Vàng',
      coinDelta: 500,
      date: '01/10/2026',
      icon: '👑',
    ),
  ];
}
