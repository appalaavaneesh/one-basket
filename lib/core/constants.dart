import '../models/product_model.dart';

class AppConstants {
  static const String appName = 'One Basket';
  static const String currency = '₹';

  // Web Client ID (serverClientId) for Google Sign-In on Android.
  // Retrieve this from your Firebase Console under Authentication -> Google -> Web SDK configuration.
  static const String googleServerClientId = '1002879002628-varl77d3fg5gf1uo6bmfvfs1vf5lqd6r.apps.googleusercontent.com';

  // Config flag for testing
  static const bool defaultUseFirebase = false;

  // Categories metadata
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'fashion',
      'name': 'Fashion',
      'subtitle': 'Sleek, Modern, Styled',
      'iconPath': 'assets/icons/fashion.png',
    },
    {
      'id': 'food',
      'name': 'Food Delivery',
      'subtitle': 'Hot, Fresh, Delicious',
      'iconPath': 'assets/icons/food.png',
    },
    {
      'id': 'grocery',
      'name': 'Groceries',
      'subtitle': 'Fresh, Organic, Daily',
      'iconPath': 'assets/icons/grocery.png',
    },
  ];

  // Procedural catalog generator to populate exactly 300 products (100 per department)
  static final List<Product> mockProducts = _generateAllProducts();

  static List<Product> _generateAllProducts() {
    final List<Product> list = [];
    list.addAll(_generateFashionProducts());
    list.addAll(_generateFoodProducts());
    list.addAll(_generateGroceryProducts());
    return list;
  }

  // --- FASHION CATALOG GENERATOR (100 Items: 50 Men, 50 Women) ---
  static List<Product> _generateFashionProducts() {
    final List<Product> list = [];
    
    // Curated high quality Unsplash fashion image URLs
    final menClothingImgs = [
      'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1516257984-b1b4d707412e?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1618886614638-80e3c103d31a?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=500&auto=format&fit=crop&q=60',
    ];
    final menOuterwearImgs = [
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1505022610485-0249ba5b3675?w=500&auto=format&fit=crop&q=60',
    ];
    final menFootwearImgs = [
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1531310197839-ccf54634509e?w=500&auto=format&fit=crop&q=60',
    ];
    final menAccessoryImgs = [
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1627124765111-f43d884794e5?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1624445305624-8a4030a7d86f?w=500&auto=format&fit=crop&q=60',
    ];

    final womenClothingImgs = [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1539008886364-70c509b2d8d8?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1554412933-714c733f1586?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1479064555552-3ef4979f8908?w=500&auto=format&fit=crop&q=60',
    ];
    final womenOuterwearImgs = [
      'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop&q=60',
    ];
    final womenFootwearImgs = [
      'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1596702994230-a00c9501d9f8?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1560343090-f0409e92791a?w=500&auto=format&fit=crop&q=60',
    ];
    final womenAccessoryImgs = [
      'https://images.unsplash.com/photo-1584917865442-de89df76abb3?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1566150905-4f0f35010ec7?w=500&auto=format&fit=crop&q=60',
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500&auto=format&fit=crop&q=60',
    ];

    final menBrands = ['Zara', 'H&M', 'Nike', 'Adidas', 'Levi\'s', 'Tommy Hilfiger', 'Calvin Klein', 'Puma', 'Jack & Jones', 'United Colors of Benetton'];
    final menClothingTypes = ['Slim Fit Shirt', 'Crewneck Cotton Tee', 'Strechy Denim Jeans', 'Premium Chino Trousers', 'Activewear Joggers', 'Oxford Cotton Shirt', 'Hooded Pullover', 'Classic Polo Shirt', 'Relaxed Fit Cargo', 'Linen Casual Shirt'];
    final menOuterwearTypes = ['Sleek Bomber Jacket', 'Distressed Denim Jacket', 'Classic Leather Jacket', 'Waterproof Windbreaker', 'Smart Wool Coat'];
    final menFootwearTypes = ['Minimalist Sneakers', 'Running Trainers', 'Leather Chelsea Boots', 'Suede Loafers', 'Classic Brogues'];
    final menAccessoryTypes = ['Leather Chronograph Watch', 'Polarized Sunglasses', 'Minimalist Card Holder', 'Reversible Leather Belt', 'Tech Utility Backpack'];

    final womenBrands = ['Zara', 'H&M', 'Mango', 'Nike', 'Forever 21', 'Only', 'Vero Moda', 'Michael Kors', 'Adidas', 'Coach'];
    final womenClothingTypes = ['Floral Summer Dress', 'Silk Wrap Blouse', 'High-Waist Mom Jeans', 'Linen Crop Top', 'Pleated Midi Skirt', 'Ribbed Knit Cardigan', 'High-Rise Leggings', 'Wide-Leg Jumpsuit', 'Cashmere Sweater', 'Tailored Blazer'];
    final womenOuterwearTypes = ['Classic Trench Coat', 'Suede Moto Jacket', 'Oversized Denim Jacket', 'Down Puffer Jacket', 'Fleece Zip-up Coat'];
    final womenFootwearTypes = ['Leather Ankle Boots', 'Stiletto Heels', 'Canvas Slip-on Sneakers', 'Strappy Block Sandals', 'Classic Ballet Flats'];
    final womenAccessoryTypes = ['Designer Tote Bag', 'Gold Chain Necklace', 'Oversized Sunglasses', 'Leather Crossbody Bag', 'Minimalist Ring Set'];

    // Generate 50 Men's items
    for (int i = 0; i < 50; i++) {
      String subcat;
      String name;
      String img;
      double price;
      
      if (i < 20) {
        subcat = 'Clothing';
        name = '${menBrands[i % menBrands.length]} ${menClothingTypes[i % menClothingTypes.length]}';
        img = menClothingImgs[i % menClothingImgs.length];
        price = 799.0 + (i * 90);
      } else if (i < 30) {
        subcat = 'Outerwear';
        name = '${menBrands[i % menBrands.length]} ${menOuterwearTypes[i % menOuterwearTypes.length]}';
        img = menOuterwearImgs[i % menOuterwearImgs.length];
        price = 1999.0 + (i * 150);
      } else if (i < 40) {
        subcat = 'Footwear';
        name = '${menBrands[i % menBrands.length]} ${menFootwearTypes[i % menFootwearTypes.length]}';
        img = menFootwearImgs[i % menFootwearImgs.length];
        price = 1499.0 + (i * 120);
      } else {
        subcat = 'Accessories';
        name = '${menBrands[i % menBrands.length]} ${menAccessoryTypes[i % menAccessoryTypes.length]}';
        img = menAccessoryImgs[i % menAccessoryImgs.length];
        price = 599.0 + (i * 110);
      }

      list.add(Product(
        id: 'f_m_${i + 1}',
        name: name,
        description: 'A premium-grade $name crafted with top-quality materials to deliver outstanding comfort, styling, and long-term durability.',
        price: price,
        imageUrl: img,
        rating: 4.0 + (i % 10) * 0.1,
        reviewsCount: 45 + (i * 3),
        category: 'fashion',
        subcategory: subcat,
        gender: 'men',
        options: {
          'sizes': subcat == 'Footwear' ? ['8', '9', '10', '11'] : ['S', 'M', 'L', 'XL'],
          'colors': ['Black', 'Navy Blue', 'Heather Grey'],
        },
      ));
    }

    // Generate 50 Women's items
    for (int i = 0; i < 50; i++) {
      String subcat;
      String name;
      String img;
      double price;
      
      if (i < 20) {
        subcat = 'Clothing';
        name = '${womenBrands[i % womenBrands.length]} ${womenClothingTypes[i % womenClothingTypes.length]}';
        img = womenClothingImgs[i % womenClothingImgs.length];
        price = 899.0 + (i * 85);
      } else if (i < 30) {
        subcat = 'Outerwear';
        name = '${womenBrands[i % womenBrands.length]} ${womenOuterwearTypes[i % womenOuterwearTypes.length]}';
        img = womenOuterwearImgs[i % womenOuterwearImgs.length];
        price = 2299.0 + (i * 180);
      } else if (i < 40) {
        subcat = 'Footwear';
        name = '${womenBrands[i % womenBrands.length]} ${womenFootwearTypes[i % womenFootwearTypes.length]}';
        img = womenFootwearImgs[i % womenFootwearImgs.length];
        price = 1299.0 + (i * 110);
      } else {
        subcat = 'Accessories';
        name = '${womenBrands[i % womenBrands.length]} ${womenAccessoryTypes[i % womenAccessoryTypes.length]}';
        img = womenAccessoryImgs[i % womenAccessoryImgs.length];
        price = 699.0 + (i * 130);
      }

      list.add(Product(
        id: 'f_w_${i + 1}',
        name: name,
        description: 'An elegant, contemporary $name that perfectly blends style, luxury, and day-long wearability.',
        price: price,
        imageUrl: img,
        rating: 4.1 + (i % 9) * 0.1,
        reviewsCount: 38 + (i * 4),
        category: 'fashion',
        subcategory: subcat,
        gender: 'women',
        options: {
          'sizes': subcat == 'Footwear' ? ['5', '6', '7', '8'] : ['XS', 'S', 'M', 'L'],
          'colors': ['Rose Pink', 'Off-White', 'Black'],
        },
      ));
    }

    return list;
  }

  // --- FOOD CATALOG GENERATOR (100 Items) ---
  static List<Product> _generateFoodProducts() {
    final List<Product> list = [];
    
    final subcategories = ['Burgers', 'Pizza', 'Japanese', 'Desserts', 'Indian Bowls', 'Rolls', 'Salads', 'Beverages'];
    
    final foodImgs = {
      'Burgers': [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1550547660-f9450f859349?w=500&auto=format&fit=crop&q=60',
      ],
      'Pizza': [
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1593560708865-adc372e8a053?w=500&auto=format&fit=crop&q=60',
      ],
      'Japanese': [
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&auto=format&fit=crop&q=60',
      ],
      'Desserts': [
        'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=500&auto=format&fit=crop&q=60',
      ],
      'Indian Bowls': [
        'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1585959195844-399fb1b4d707?w=500&auto=format&fit=crop&q=60',
      ],
      'Rolls': [
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=500&auto=format&fit=crop&q=60',
      ],
      'Salads': [
        'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1540420773-49667431e21b?w=500&auto=format&fit=crop&q=60',
      ],
      'Beverages': [
        'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1536935338774-76f31b03b8e4?w=500&auto=format&fit=crop&q=60',
      ]
    };

    final prefix = ['Classic', 'Gourmet', 'Spicy', 'Smoked', 'Crispy', 'Cheesy', 'Royal', 'House Special', 'Fresh', 'Organic', 'Loaded', 'Sweet'];
    
    final itemTemplates = {
      'Burgers': ['Angus Beef Burger', 'Cheese Hamburger', 'BBQ Chicken Burger', 'Crispy Fish Burger', 'Spicy Paneer Burger', 'Double Patty Stack', 'Mushroom Swiss Burger', 'Avocado Veggie Burger'],
      'Pizza': ['Pepperoni Pizza', 'Margherita Pizza', 'BBQ Chicken Pizza', 'Farmhouse Veg Pizza', 'Four Cheese Pizza', 'Fiery Jalapeno Pizza', 'Tikka Masala Pizza', 'Paneer Supreme Pizza'],
      'Japanese': ['Salmon Sushi Set', 'Tuna Maki Roll', 'California Avocado Roll', 'Chicken Katsu Curry', 'Tonkotsu Ramen Bowl', 'Veg Tempura Platter', 'Prawn Gyoza Plate', 'Yakitori Chicken Skewers'],
      'Desserts': ['Molten Lava Brownie', 'New York Cheesecake', 'Chocolate Mousse cup', 'Warm Apple Pie', 'Waffles with Syrup', 'Tiramisu Slice', 'Cardamom Kulfi Cup', 'Gulab Jamun Plate'],
      'Indian Bowls': ['Butter Chicken Bowl', 'Paneer Makhani Rice', 'Dal Makhani Combo', 'Chicken Biryani Plate', 'Chole Bhature Platter', 'Shahi Paneer Thali', 'Rajma Rice Bowl', 'Kadai Veg combo'],
      'Rolls': ['Paneer Tikka Roll', 'Spicy Chicken Wrap', 'Falafel Hummus Roll', 'Egg Masala Franky', 'Double Cheese Shawarma', 'Veg Schezwan Roll', 'Chicken Mayo Wrap', 'Paneer Kebab Roll'],
      'Salads': ['Chicken Caesar Salad', 'Greek Feta Salad', 'Quinoa Avocado Bowl', 'Italian Garden Toss', 'Fruit & Honey Mix', 'Crunchy Veg Salad', 'Sprout Protein Bowl', 'Asian Sesame Salad'],
      'Beverages': ['Mango Lassi Cup', 'Masala Chai Flask', 'Iced Caramel Macchiato', 'Fresh Lemon Mint', 'Strawberry Smoothie', 'Cold Brew Coffee', 'Sweet Lassi Tall', 'Watermelon Juice']
    };

    int idCount = 1;
    for (var subcat in subcategories) {
      final templates = itemTemplates[subcat]!;
      final imgs = foodImgs[subcat]!;
      
      // Each category gets 12 or 13 items to make exactly 100 in total
      int itemsCount = (subcat == 'Burgers' || subcat == 'Pizza' || subcat == 'Indian Bowls' || subcat == 'Beverages') ? 13 : 12;
      
      for (int i = 0; i < itemsCount; i++) {
        final name = '${prefix[(i + idCount) % prefix.length]} ${templates[i % templates.length]}';
        final price = 120.0 + ((i + idCount) % 15) * 40;
        
        list.add(Product(
          id: 'fd_$idCount',
          name: name,
          description: 'A delicious, fresh-cooked $name made with premium local ingredients. Features authentic seasoning and rich flavors, served hot and ready.',
          price: price,
          imageUrl: imgs[i % imgs.length],
          rating: 4.2 + ((i + idCount) % 8) * 0.1,
          reviewsCount: 110 + (idCount * 6),
          category: 'food',
          subcategory: subcat,
          options: {
            'customizations': ['Extra Cheese', 'Make it Spicy', 'Less Salt'],
          },
        ));
        idCount++;
      }
    }
    return list;
  }

  // --- GROCERY CATALOG GENERATOR (100 Items) ---
  static List<Product> _generateGroceryProducts() {
    final List<Product> list = [];
    
    final subcategories = ['Fruits & Vegetables', 'Dairy & Eggs', 'Bakery', 'Grains & Pasta', 'Oils & Spices', 'Snacks & Nuts'];
    
    final groceryImgs = {
      'Fruits & Vegetables': [
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500&auto=format&fit=crop&q=60',
      ],
      'Dairy & Eggs': [
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1516448424440-5dbf97779ced?w=500&auto=format&fit=crop&q=60',
      ],
      'Bakery': [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1549931318-a5a2d1f067f1?w=500&auto=format&fit=crop&q=60',
      ],
      'Grains & Pasta': [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1621961413000-845187766099?w=500&auto=format&fit=crop&q=60',
      ],
      'Oils & Spices': [
        'https://images.unsplash.com/photo-1622484211148-716499c43d04?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1596797038530-2c70721d73ab?w=500&auto=format&fit=crop&q=60',
      ],
      'Snacks & Nuts': [
        'https://images.unsplash.com/photo-1508061253366-f7da158b6d4f?w=500&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1568254183-f2c142c52517?w=500&auto=format&fit=crop&q=60',
      ]
    };

    final prefix = ['Organic', 'Fresh', 'Premium', 'Natural', 'Pure', 'Traditional', 'Select', 'Local Farm', 'Whole', 'Gold Label'];
    
    final itemTemplates = {
      'Fruits & Vegetables': ['Honeycrisp Apples', 'Hass Avocados', 'Bananas Bunch', 'Carrots pack', 'Baby Spinach bag', 'Red Tomatoes', 'Citrus Lemons', 'Blueberries box'],
      'Dairy & Eggs': ['Whole Milk 3%', 'Cage-Free Brown Eggs', 'Salted Butter', 'Greek Yogurt', 'Cheddar Cheese block', 'Heavy Whipping Cream', 'Organic Tofu', 'Mozzarella Shredded'],
      'Bakery': ['Sourdough Bread', 'Multigrain Loaf', 'Butter Croissants', 'Chocolate Muffins', 'Bagels Pack of 4', 'Whole Wheat Pita', 'Gluten-Free Bread', 'Garlic Naan pack'],
      'Grains & Pasta': ['Premium Basmati Rice', 'Organic Quinoa', 'Rolled Oats bag', 'Spaghetti Pasta', 'Whole Wheat Atta', 'Macaroni pack', 'Brown Rice bag', 'Penne Rigate'],
      'Oils & Spices': ['Cold Pressed Coconut Oil', 'Extra Virgin Olive Oil', 'Ground Turmeric', 'Chili Flakes sprinkler', 'Black Pepper Whole', 'Himalayan Pink Salt', 'Mustard Oil bottle', 'Cumin Seeds powder'],
      'Snacks & Nuts': ['Roasted Almonds', 'Premium Whole Cashews', 'Dark Chocolate 70%', 'Sea Salt Potato Chips', 'Pretzels Bag', 'Roasted Pistachios', 'Granola Oats Bar', 'Salted Peanuts']
    };

    final units = {
      'Fruits & Vegetables': ['1 kg bag', 'Pack of 4', '500g pack'],
      'Dairy & Eggs': ['1 Liter carton', 'Pack of 12', '500g tub', '250g pack'],
      'Bakery': ['800g sliced loaf', 'Pack of 4', '250g pack'],
      'Grains & Pasta': ['5 kg bag', '1 kg pack', '500g box'],
      'Oils & Spices': ['500ml bottle', '1L bottle', '100g sprinkler', '200g pouch'],
      'Snacks & Nuts': ['250g pack', '500g pack', '100g bar']
    };

    int idCount = 1;
    for (var subcat in subcategories) {
      final templates = itemTemplates[subcat]!;
      final imgs = groceryImgs[subcat]!;
      final unitOptions = units[subcat]!;
      
      // We distribute 100 items among 6 categories (17, 17, 16, 16, 17, 17)
      int itemsCount = (subcat == 'Fruits & Vegetables' || subcat == 'Dairy & Eggs' || subcat == 'Oils & Spices' || subcat == 'Snacks & Nuts') ? 17 : 16;
      
      for (int i = 0; i < itemsCount; i++) {
        final name = '${prefix[(i + idCount) % prefix.length]} ${templates[i % templates.length]}';
        final price = 50.0 + ((i + idCount) % 12) * 50;
        
        list.add(Product(
          id: 'g_$idCount',
          name: name,
          description: 'High-quality $name sourced directly from trusted growers and sustainable farms. Perfect for healthy everyday cooking and nutritious meals.',
          price: price,
          imageUrl: imgs[i % imgs.length],
          rating: 4.3 + ((i + idCount) % 7) * 0.1,
          reviewsCount: 30 + (idCount * 3),
          category: 'grocery',
          subcategory: subcat,
          options: {
            'unit': [unitOptions[i % unitOptions.length], unitOptions[(i + 1) % unitOptions.length]],
          },
        ));
        idCount++;
      }
    }
    return list;
  }
}
