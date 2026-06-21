import '../models/category.dart';
import '../models/product.dart';
import '../models/voucher.dart';

/// Seed data for the Summit App demo. Curated 20 products across 10
/// categories with real brand names, realistic specs, and Unsplash images
/// chosen to visually match the product type.
///
/// Reset via Admin Panel → "Reset Data ke Default" to re-apply after edits.
class SeedData {
  static List<Category> get categories => [
    Category(id: 1, name: 'Tenda', icon: 'camping', parentId: null),
    Category(id: 2, name: 'Sleeping Bag', icon: 'bedtime', parentId: null),
    Category(id: 3, name: 'Carrier / Tas Gunung', icon: 'backpack', parentId: null),
    Category(id: 4, name: 'Sepatu Gunung', icon: 'hiking', parentId: null),
    Category(id: 5, name: 'Jaket Outdoor', icon: 'style', parentId: null),
    Category(id: 6, name: 'Harness & Carabiner', icon: 'lock', parentId: null),
    Category(id: 7, name: 'Headlamp & Senter', icon: 'light', parentId: null),
    Category(id: 8, name: 'Matras', icon: 'airline_seat_flat', parentId: null),
    Category(id: 9, name: 'Cooking Set', icon: 'outdoor_grill', parentId: null),
    Category(id: 10, name: 'Aksesoris', icon: 'category', parentId: null),
  ];

  static List<Product> get products => [
    // ========================================================================
    // 1. TENDA (2)
    // ========================================================================
    Product(
      id: 1, categoryId: 1,
      name: 'Eiger Siger 4P Dome Tent',
      description:
        'Tenda dome kapasitas 4 orang. Material polyester 210T dengan '
        'coating PU 3000mm tahan hujan deras, 2 pintu, vestibule, dan '
        'rainfly full coverage. Dilengkapi 4 tie-out point untuk extra '
        'ventilasi. Cocok untuk camping keluarga dan basecamp.',
      brand: 'Eiger', weight: 4800,
      price: 1850000, discountPrice: 1599000,
      stock: 12, rating: 4.6, reviewCount: 142, soldCount: 320,
      images: ['https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600'],
      sizeGuide: 'Dimensi 240x210x130 cm | Cocok untuk 3-4 orang | Packing 60x20 cm',
      createdAt: '2026-01-15',
    ),
    Product(
      id: 2, categoryId: 1,
      name: 'Naturehike Cloud Up 2 Ultralight',
      description:
        'Tenda 2 orang ultralight 1.9 kg. Material 20D nylon silicone-'
        'coated double layer, freestanding dengan 2 trekking pole. '
        'Pilihan favorit pendaki ultralight untuk thru-hike dan fastpack.',
      brand: 'Naturehike', weight: 1900,
      price: 1250000, discountPrice: 1099000,
      stock: 18, rating: 4.7, reviewCount: 89, soldCount: 215,
      images: ['https://images.unsplash.com/photo-1478827536114-da961b7f86d2?w=600'],
      sizeGuide: 'Dimensi 210x130x105 cm | Packing 45x15 cm | 2 pintu',
      createdAt: '2026-01-20',
    ),

    // ========================================================================
    // 2. SLEEPING BAG (2)
    // ========================================================================
    Product(
      id: 3, categoryId: 2,
      name: 'Eiger Amazonite Sleeping Bag 0°C',
      description:
        'Sleeping bag envelope synthetic, suhu nyaman 0°C. Isi hollow '
        'fiber 1500 g, shell polyester 190T breathable. Tersedia warna '
        'hijau army dan biru navy. Cocok untuk camping dataran tinggi.',
      brand: 'Eiger', weight: 1600,
      price: 650000,
      stock: 25, rating: 4.4, reviewCount: 178, soldCount: 480,
      images: ['https://images.unsplash.com/photo-1520256780061-e2a7b67a2a04?w=600'],
      sizeGuide: 'Panjang 200 cm | Bahu 80 cm | Suhu nyaman 0°C',
      createdAt: '2026-02-01',
    ),
    Product(
      id: 4, categoryId: 2,
      name: 'Naturehike CW280 -5°C Down',
      description:
        'Sleeping bag mummy goose down 800 fill power, suhu ekstrim -5°C. '
        'Kompresibel jadi sangat kecil, cocok untuk pendakian gunung '
        'tinggi dan alpine climbing. Termasuk stuff sack compression.',
      brand: 'Naturehike', weight: 1100,
      price: 1850000, discountPrice: 1599000,
      stock: 15, rating: 4.8, reviewCount: 234, soldCount: 560,
      images: ['https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=600'],
      sizeGuide: 'Panjang 200 cm | Bahu 80 cm | Suhu ekstrim -5°C',
      createdAt: '2026-02-10',
    ),

    // ========================================================================
    // 3. CARRIER (2)
    // ========================================================================
    Product(
      id: 5, categoryId: 3,
      name: 'Deuter Aircontact Core 60+10',
      description:
        'Carrier premium 60+10 L untuk ekspedisi panjang. Sistem punggung '
        'Aircontact dengan ventilasi aktif, frame aluminium, dan hipbelt '
        'ergonomis. Banyak kompartemen termasuk bottom compartment untuk '
        'sleeping bag. Pilihan profesional mountain guide.',
      brand: 'Deuter', weight: 2400,
      price: 3850000,
      stock: 8, rating: 4.9, reviewCount: 76, soldCount: 145,
      images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600'],
      sizeGuide: '60+10 L | Cocok torso 45-55 cm | Beban max 25 kg',
      createdAt: '2026-03-01',
    ),
    Product(
      id: 6, categoryId: 3,
      name: 'Eiger Fastwalker 40L',
      description:
        'Carrier 40 L untuk day-hike dan pendakian 1-2 hari. Ringan 1.4 '
        'kg, banyak kompartemen termasuk sleeve hydration, rain cover '
        'built-in di bagian bawah. Cocok untuk pemula dan pendaki kasual.',
      brand: 'Eiger', weight: 1400,
      price: 1100000, discountPrice: 899000,
      stock: 22, rating: 4.5, reviewCount: 198, soldCount: 420,
      images: ['https://images.unsplash.com/photo-1622260614153-03223fb72052?w=600'],
      sizeGuide: '40 L | Cocok torso 45-50 cm | Rain cover included',
      createdAt: '2026-03-05',
    ),

    // ========================================================================
    // 4. SEPATU GUNUNG (2)
    // ========================================================================
    Product(
      id: 7, categoryId: 4,
      name: 'Salomon X Ultra 4 Mid GTX',
      description:
        'Sepatu hiking mid-cut waterproof Gore-Tex. Sol Contagrip All-'
        'Terrain untuk traksi maksimal, chassis Advanced untuk stabilitas '
        'di medan teknis. Quicklace system untuk fit presisi.',
      brand: 'Salomon', weight: 460,
      price: 2650000, discountPrice: 2299000,
      stock: 14, rating: 4.9, reviewCount: 287, soldCount: 680,
      images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600'],
      sizeGuide: 'EU 39-46 | True to size | Half size up untuk kaus kaki tebal',
      createdAt: '2026-03-10',
    ),
    Product(
      id: 8, categoryId: 4,
      name: 'Eiger Liberty 5 Low',
      description:
        'Sepatu hiking low-cut ringan 380 g, sol Vibram EcoStep, toe '
        'protection. Cocok untuk trek ringan, fast-hiking, dan travel. '
        'Breathable mesh upper untuk iklim tropis.',
      brand: 'Eiger', weight: 380,
      price: 1100000,
      stock: 28, rating: 4.4, reviewCount: 156, soldCount: 380,
      images: ['https://images.unsplash.com/photo-1542838132-92c53300491e?w=600'],
      sizeGuide: 'EU 39-44 | True to size | Low cut',
      createdAt: '2026-03-15',
    ),

    // ========================================================================
    // 5. JAKET OUTDOOR (2)
    // ========================================================================
    Product(
      id: 9, categoryId: 5,
      name: 'The North Face Resolve Jacket 2',
      description:
        'Jaket rain shell waterproof DryVent 2L. Jahitan sealed fully '
        'taped, adjustable hood, breathable. Pilihan untuk hujan ringan '
        'sampai sedang, lipat jadi kecil masuk saku.',
      brand: 'The North Face', weight: 380,
      price: 1850000, discountPrice: 1599000,
      stock: 20, rating: 4.7, reviewCount: 198, soldCount: 450,
      images: ['https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=600'],
      sizeGuide: 'S-XXL | Regular fit, layered friendly',
      createdAt: '2026-04-01',
    ),
    Product(
      id: 10, categoryId: 5,
      name: 'Consina Breezer Softshell',
      description:
        'Jaket softshell breathable dengan teknologi stretch 4-way. '
        'Water repellent DWR, windproof ringan, cocok untuk aktivitas '
        'dinamis seperti hiking dan climbing. 2 hand pocket + 1 chest.',
      brand: 'Consina', weight: 450,
      price: 950000, discountPrice: 799000,
      stock: 30, rating: 4.5, reviewCount: 145, soldCount: 380,
      images: ['https://images.unsplash.com/photo-1544923246-77307dd270b5?w=600'],
      sizeGuide: 'S-XL | Slim fit | Stretch 4-way',
      createdAt: '2026-04-05',
    ),

    // ========================================================================
    // 6. HARNESS & CARABINER (2)
    // ========================================================================
    Product(
      id: 11, categoryId: 6,
      name: 'Black Diamond Momentum Harness',
      description:
        'Harness all-around untuk panjat tebing, via ferrata, dan '
        'climbing gym. Dual Core Construction, 4 gear loops, adjustable '
        'waist belt dengan buckle speed.',
      brand: 'Black Diamond', weight: 360,
      price: 1350000,
      stock: 10, rating: 4.8, reviewCount: 67, soldCount: 165,
      images: ['https://images.unsplash.com/photo-1551442959-804204a214a7?w=600'],
      sizeGuide: 'S/M/L/XL | Waist 71-91 cm | Leg 51-66 cm',
      createdAt: '2026-04-10',
    ),
    Product(
      id: 12, categoryId: 6,
      name: 'Petzl Sm\'D Screw-Lock Carabiner',
      description:
        'Carabiner HMS screw-lock untuk belay dan rappel. Aluminum '
        'alloy, compact, auto-lock ganda. UIAA certified, gate 25 mm '
        'untuk kompatibilitas berbagai aplikasi.',
      brand: 'Petzl', weight: 85,
      price: 425000, discountPrice: 365000,
      stock: 40, rating: 4.9, reviewCount: 234, soldCount: 620,
      images: ['https://images.unsplash.com/photo-1566623876159-0a4c6e067ddb?w=600'],
      createdAt: '2026-04-15',
    ),

    // ========================================================================
    // 7. HEADLAMP & SENTER (2)
    // ========================================================================
    Product(
      id: 13, categoryId: 7,
      name: 'Petzl Actik Core 600',
      description:
        'Headlamp hybrid 600 lumen, rechargeable via USB-C (baterai '
        'included) dan kompatibel baterai AAA. 3 brightness levels, red '
        'light mode untuk night vision, reflective strap untuk visibilitas.',
      brand: 'Petzl', weight: 75,
      price: 1100000, discountPrice: 949000,
      stock: 35, rating: 4.8, reviewCount: 198, soldCount: 540,
      images: ['https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=600'],
      createdAt: '2026-04-20',
    ),
    Product(
      id: 14, categoryId: 7,
      name: 'Black Diamond Spot 400',
      description:
        'Headlamp compact 400 lumen, waterproof IPX8, PowerTap '
        'brightness adjustment di temple. Cocok untuk trail running, '
        'camping, dan caving entry-level.',
      brand: 'Black Diamond', weight: 86,
      price: 850000,
      stock: 28, rating: 4.6, reviewCount: 167, soldCount: 420,
      images: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600'],
      createdAt: '2026-04-25',
    ),

    // ========================================================================
    // 8. MATRAS (2)
    // ========================================================================
    Product(
      id: 15, categoryId: 8,
      name: 'Naturehike Self-Inflating Mat 5cm',
      description:
        'Matras self-inflating 5 cm tebal, R-value 3.2 (cocok 3-season). '
        'Foam density 19 kg/m³, anti-slip top, ringan, easy packing. '
        'Pilihan tepat untuk camping keluarga dan pendakian ringan.',
      brand: 'Naturehike', weight: 850,
      price: 580000, discountPrice: 489000,
      stock: 24, rating: 4.5, reviewCount: 134, soldCount: 380,
      images: ['https://images.unsplash.com/photo-1508873696983-2dfd5898f08b?w=600'],
      sizeGuide: '180x60 cm | Packing 30x15 cm | R-value 3.2',
      createdAt: '2026-05-01',
    ),
    Product(
      id: 16, categoryId: 8,
      name: 'Klymit Static V Insulated',
      description:
        'Matras inflatable ultra-ringkas, R-value 4.4 (cocok 4-season). '
        'Body mapping V-chamber design, synthetic insulation, berat '
        'hanya 700 g. Inflatable 10-15 kali hembusan nafas.',
      brand: 'Klymit', weight: 700,
      price: 1450000,
      stock: 12, rating: 4.7, reviewCount: 89, soldCount: 195,
      images: ['https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600'],
      sizeGuide: '182x58 cm | Packing 22x10 cm | R-value 4.4',
      createdAt: '2026-05-05',
    ),

    // ========================================================================
    // 9. COOKING SET (2)
    // ========================================================================
    Product(
      id: 17, categoryId: 9,
      name: 'MSR PocketRocket Deluxe',
      description:
        'Kompor canister ultra-ringkas dengan pressure regulator. Stabil '
        'di angin, simmer control presisi, hanya 83 g. Kompatibel '
        'dengan canister threaded EN417.',
      brand: 'MSR', weight: 83,
      price: 1450000,
      stock: 18, rating: 4.8, reviewCount: 156, soldCount: 340,
      images: ['https://images.unsplash.com/photo-1597074866923-dc0589150358?w=600'],
      createdAt: '2026-05-10',
    ),
    Product(
      id: 18, categoryId: 9,
      name: 'Trangia 25-5 HA Cookset',
      description:
        'Cookset 4 orang: 2 panci (1.5 & 1.75 L), 1 wajan, tutup, dan '
        'handle removable. Hard-anodized aluminium, ringan, distribusi '
        'panas merata. Ideal untuk camping keluarga atau basecamp.',
      brand: 'Trangia', weight: 1100,
      price: 1850000, discountPrice: 1650000,
      stock: 10, rating: 4.7, reviewCount: 78, soldCount: 195,
      images: ['https://images.unsplash.com/photo-1521302200778-33500795e128?w=600'],
      createdAt: '2026-05-15',
    ),

    // ========================================================================
    // 10. AKSESORIS (2)
    // ========================================================================
    Product(
      id: 19, categoryId: 10,
      name: 'Leki Makalu FX Carbon Pole',
      description:
        'Trekking pole carbon fiber, 3-section adjustable 65-135 cm. '
        'Grip Aergon ergonomis, strap adjustable, twist-lock untuk '
        'keamanan. Berat 250 g per pair, kuat untuk beban berat.',
      brand: 'Leki', weight: 250,
      price: 1350000, discountPrice: 1150000,
      stock: 20, rating: 4.7, reviewCount: 134, soldCount: 280,
      images: ['https://images.unsplash.com/photo-1579247304232-a9bc207fdfab?w=600'],
      createdAt: '2026-05-20',
    ),
    Product(
      id: 20, categoryId: 10,
      name: 'Oakley Holbrook Sunglasses',
      description:
        'Kacamata outdoor UV400 polarized, frame O-Matter ringan dan '
        'tahan lama. Lensa Plutonite dengan kejernahan optik tinggi '
        'dan tahan benturan. Cocok untuk hiking, driving, dan harian.',
      brand: 'Oakley', weight: 50,
      price: 1850000,
      stock: 25, rating: 4.6, reviewCount: 198, soldCount: 380,
      images: ['https://images.unsplash.com/photo-1577803645773-f96470509666?w=600'],
      createdAt: '2026-05-25',
    ),
  ];

  static List<Voucher> get vouchers => [
    Voucher(
      id: 1, code: 'SUMMIT10', type: 'persen', value: 10,
      minPurchase: 200000, maxDiscount: 50000,
      validFrom: '2026-01-01', validUntil: '2026-12-31',
      quota: 100, usedCount: 0,
    ),
    Voucher(
      id: 2, code: 'HEMAT50', type: 'nominal', value: 50000,
      minPurchase: 300000, maxDiscount: null,
      validFrom: '2026-01-01', validUntil: '2026-12-31',
      quota: 50, usedCount: 0,
    ),
    Voucher(
      id: 3, code: 'NEWUSER', type: 'persen', value: 15,
      minPurchase: null, maxDiscount: 75000,
      validFrom: '2026-01-01', validUntil: '2026-12-31',
      quota: 200, usedCount: 0,
    ),
  ];
}
