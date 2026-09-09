/**
 * RUG & CARPET STORE - PRODUCT CATALOG & FILTER ENGINE
 * Contains product dataset, search, filter, sort algorithms, and Quick View modal logic.
 */

(function () {
  'use strict';

  const PRODUCTS_DATA = [
    {
      id: 1,
      name: 'Isfahan Silk Medallion Rug',
      category: 'Traditional Rugs',
      material: 'Silk',
      color: 'Terracotta',
      price: 850,
      oldPrice: 1100,
      rating: 4.9,
      reviewsCount: 42,
      style: 'Heritage',
      size: "8' x 10'",
      availableSizes: ["5' x 8'", "8' x 10'", "9' x 12'", "10' x 14'"],
      image: 'assets/images/products/isfahan-silk-rug.jpg',
      gallery: [
        'assets/images/products/isfahan-silk-rug.jpg',
        'assets/images/products/isfahan-silk-detail-1.jpg',
        'assets/images/products/isfahan-silk-detail-2.jpg'
      ],
      badge: 'Best Seller',
      badgeColor: 'badge-luxury-terracotta',
      description: 'Hand-knotted by master artisans using pure Mulberry silk and high-twist wool yarn. Features classic symmetrical Persian floral medallions with soft terracotta and champagne borders.'
    },
    {
      id: 2,
      name: 'Atlas Mountain Berber Wool Rug',
      category: 'Handwoven Rugs',
      material: 'Wool',
      color: 'Cream',
      price: 620,
      oldPrice: null,
      rating: 4.8,
      reviewsCount: 38,
      style: 'Tribal',
      size: "8' x 10'",
      availableSizes: ["6' x 9'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/atlas-berber-rug.jpg',
      gallery: [
        'assets/images/products/atlas-berber-rug.jpg',
        'assets/images/products/atlas-berber-detail-1.jpg',
        'assets/images/products/atlas-berber-detail-2.jpg'
      ],
      badge: 'Artisan Crafted',
      badgeColor: 'badge-luxury-gold',
      description: 'Plush high-pile Moroccan wool rug spun from unbleached organic virgin sheep wool. Characteristic diamond talisman patterns that imbue warmth and grounding texture.'
    },
    {
      id: 3,
      name: 'Nordic Geometric Wool Flatweave',
      category: 'Modern Rugs',
      material: 'Wool',
      color: 'Sand',
      price: 490,
      oldPrice: 580,
      rating: 4.8,
      reviewsCount: 34,
      style: 'Geometric',
      size: "8' x 10'",
      availableSizes: ["5' x 8'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/nordic-geometric-rug.jpg',
      gallery: [
        'assets/images/products/nordic-geometric-rug.jpg',
        'assets/images/products/nordic-geometric-detail-1.jpg',
        'assets/images/products/nordic-geometric-detail-2.jpg'
      ],
      badge: 'Sale',
      badgeColor: 'badge-luxury-terracotta',
      description: 'Architectural Scandinavian geometric flatweave featuring rhythmic arch reliefs and earthy geometric blocks in warm terracotta, biscuit, and cream. Handcrafted from 100% pure organic wool.'
    },
    {
      id: 4,
      name: 'Oushak Heritage Botanical Runner',
      category: 'Runner Rugs',
      material: 'Wool',
      color: 'Terracotta',
      price: 480,
      oldPrice: 560,
      rating: 4.9,
      reviewsCount: 19,
      style: 'Heritage',
      size: "2.5' x 12'",
      availableSizes: ["2.5' x 8'", "2.5' x 10'", "2.5' x 12'"],
      image: 'assets/images/products/oushak-runner-rug.jpg',
      gallery: [
        'assets/images/products/oushak-runner-rug.jpg',
        'assets/images/products/oushak-runner-detail-1.jpg',
        'assets/images/products/oushak-runner-detail-2.jpg'
      ],
      badge: 'Popular',
      badgeColor: 'badge-luxury-gold',
      description: 'Turkish Oushak runner bathed in soft terracotta and celadon tones. Low sheared pile with muted abrash color variations ideal for hallways and grand foyers.'
    },
    {
      id: 5,
      name: 'Kyoto Organic Jute Braided Carpet',
      category: 'Luxury Carpets',
      material: 'Jute',
      color: 'Sand',
      price: 340,
      oldPrice: null,
      rating: 4.6,
      reviewsCount: 24,
      style: 'Natural',
      size: "8' x 10'",
      availableSizes: ["6' x 9'", "8' x 10'", "9' x 12'", "Round 8'"],
      image: 'assets/images/products/braided-jute-carpet.jpg',
      gallery: [
        'assets/images/products/braided-jute-carpet.jpg',
        'assets/images/products/kyoto-jute-detail-1.jpg',
        'assets/images/products/kyoto-jute-detail-2.jpg'
      ],
      badge: 'Eco-Friendly',
      badgeColor: 'badge-luxury-gold',
      description: 'Hand-braided thick natural golden jute with organic cotton warp. Imparts rich coastal or wabi-sabi tactile depth while remaining durable for high-traffic zones.'
    },
    {
      id: 6,
      name: 'Bauhaus Modern Geometric Wool Rug',
      category: 'Modern Rugs',
      material: 'Wool',
      color: 'Charcoal',
      price: 720,
      oldPrice: 890,
      rating: 4.8,
      reviewsCount: 31,
      style: 'Abstract',
      size: "9' x 12'",
      availableSizes: ["8' x 10'", "9' x 12'", "10' x 14'"],
      image: 'assets/images/products/bauhaus-geometric-rug.jpg',
      gallery: [
        'assets/images/products/bauhaus-geometric-rug.jpg',
        'assets/images/products/bauhaus-geometric-detail-1.jpg',
        'assets/images/products/bauhaus-geometric-detail-2.jpg'
      ],
      badge: 'Architectural',
      badgeColor: 'badge-luxury-terracotta',
      description: 'Sculpted high-low cut and loop wool construction. Architectural balance of earthy charcoal, warm biscuit, and toasted sand tones.'
    },
    {
      id: 7,
      name: 'Caspian Hand-Knotted Silk Rug',
      category: 'Traditional Rugs',
      material: 'Silk',
      color: 'Charcoal',
      price: 1250,
      oldPrice: 1500,
      rating: 5.0,
      reviewsCount: 15,
      style: 'Heritage',
      size: "9' x 12'",
      availableSizes: ["8' x 10'", "9' x 12'", "10' x 14'"],
      image: 'assets/images/products/caspian-silk-rug.jpg',
      gallery: [
        'assets/images/products/caspian-silk-rug.jpg',
        'assets/images/products/caspian-silk-detail-1.jpg',
        'assets/images/products/caspian-silk-detail-2.jpg'
      ],
      badge: 'Masterpiece',
      badgeColor: 'badge-luxury-gold',
      description: 'Exquisite 600 KPSI hand-knotted collector rug. Pure natural silk weft catches room light dynamically, creating shifting tones throughout the day.'
    },
    {
      id: 8,
      name: 'Santorini Terrace Diamond Outdoor Rug',
      category: 'Outdoor Rugs',
      material: 'Natural Fibers',
      color: 'Terracotta',
      price: 320,
      oldPrice: null,
      rating: 4.8,
      reviewsCount: 24,
      style: 'Geometric',
      size: "8' x 10'",
      availableSizes: ["5' x 8'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/santorini-outdoor-terrace-rug.jpg',
      gallery: [
        'assets/images/products/santorini-outdoor-terrace-rug.jpg',
        'assets/images/products/santorini-outdoor-detail-1.jpg',
        'assets/images/products/santorini-outdoor-detail-2.jpg'
      ],
      badge: 'Weatherproof',
      badgeColor: 'badge-luxury-terracotta',
      description: 'UV-stabilized, mold-resistant woven polypropylene terrace rug with textured diamond reliefs and warm terracotta borders. Designed for luxury pool terraces, verandas, and sunrooms.'
    },
    {
      id: 9,
      name: 'Anatolian Vintage Distressed Rug',
      category: 'Traditional Rugs',
      material: 'Wool',
      color: 'Terracotta',
      price: 580,
      oldPrice: 690,
      rating: 4.7,
      reviewsCount: 18,
      style: 'Vintage',
      size: "8' x 10'",
      availableSizes: ["6' x 9'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/anatolian-vintage-rug.jpg',
      gallery: [
        'assets/images/products/anatolian-vintage-rug.jpg',
        'assets/images/products/anatolian-vintage-detail-1.jpg',
        'assets/images/products/anatolian-vintage-detail-2.jpg'
      ],
      badge: 'Vintage Wash',
      badgeColor: 'badge-luxury-gold',
      description: 'Authentic Turkish semi-antique rug gently stonewashed and sun-faded to reveal soft botanical motifs in warm terracotta and sandy ecru.'
    },
    {
      id: 11,
      name: 'Moroccan Tribal Diamond Runner',
      category: 'Runner Rugs',
      material: 'Wool',
      color: 'Cream',
      price: 420,
      oldPrice: 490,
      rating: 4.8,
      reviewsCount: 26,
      style: 'Tribal',
      size: "2.5' x 10'",
      availableSizes: ["2.5' x 8'", "2.5' x 10'", "2.5' x 14'"],
      image: 'assets/images/products/moroccan-diamond-runner.jpg',
      gallery: [
        'assets/images/products/moroccan-diamond-runner.jpg',
        'assets/images/products/moroccan-runner-detail-1.jpg',
        'assets/images/products/moroccan-runner-detail-2.jpg'
      ],
      badge: 'Hand Spun',
      badgeColor: 'badge-luxury-gold',
      description: 'Long hallway runner handwoven by Berber women in the Middle Atlas. Braided fringe endpoints with natural undyed dark wool geometric lines.'
    },
    {
      id: 12,
      name: 'Solstice Organic Jute Loop Rug',
      category: 'Handwoven Rugs',
      material: 'Jute',
      color: 'Sand',
      price: 310,
      oldPrice: null,
      rating: 4.6,
      reviewsCount: 21,
      style: 'Natural',
      size: "6' x 9'",
      availableSizes: ["5' x 8'", "6' x 9'", "8' x 10'"],
      image: 'assets/images/products/jute-loop-rug.jpg',
      gallery: [
        'assets/images/products/jute-loop-rug.jpg',
        'assets/images/products/solstice-jute-detail-1.jpg',
        'assets/images/products/solstice-jute-detail-2.jpg'
      ],
      badge: 'Artisan Looped',
      badgeColor: 'badge-luxury-gold',
      description: 'Chunky knotted loop construction using golden Bengal jute. Offers therapeutic foot reflexology sensation and relaxed, organic visual serenity.'
    },
    {
      id: 13,
      name: 'Amalfi Veranda Striped Outdoor Rug',
      category: 'Outdoor Rugs',
      material: 'Natural Fibers',
      color: 'Cream',
      price: 340,
      oldPrice: null,
      rating: 4.7,
      reviewsCount: 19,
      style: 'Minimalist',
      size: "8' x 10'",
      availableSizes: ["6' x 9'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/amalfi-veranda-outdoor-rug.jpg',
      gallery: [
        'assets/images/products/amalfi-veranda-outdoor-rug.jpg',
        'assets/images/products/amalfi-veranda-detail-1.jpg',
        'assets/images/products/amalfi-veranda-detail-2.jpg'
      ],
      badge: 'All-Weather',
      badgeColor: 'badge-luxury-gold',
      description: 'Sophisticated coastal veranda rug with understated linear frame accents in oat and subtle sage. Engineered to withstand high humidity, direct sunlight, and outdoor entertaining.'
    },
    {
      id: 10,
      name: 'Jaipur Hand-Block Printed Cotton Dhurrie',
      category: 'Handwoven Rugs',
      material: 'Cotton',
      color: 'Terracotta',
      price: 360,
      oldPrice: 420,
      rating: 4.8,
      reviewsCount: 22,
      style: 'Block Print',
      size: "8' x 10'",
      availableSizes: ["5' x 8'", "8' x 10'", "9' x 12'"],
      image: 'assets/images/products/handwoven-kilim-rug.jpg',
      gallery: [
        'assets/images/products/handwoven-kilim-rug.jpg',
        'assets/images/products/jaipur-cotton-detail-1.jpg',
        'assets/images/products/jaipur-cotton-detail-2.jpg'
      ],
      badge: 'Pure Cotton',
      badgeColor: 'badge-luxury-gold',
      description: 'Handwoven pure organic Indian cotton dhurrie flatweave using carved teakwood stamps and botanical pigments. Reversible, lightweight, and effortlessly washable.'
    },
    {
      id: 14,
      name: 'Scandinavian Ribbed Cotton Flatweave',
      category: 'Modern Rugs',
      material: 'Cotton',
      color: 'Cream',
      price: 300,
      oldPrice: 360,
      rating: 4.7,
      reviewsCount: 16,
      style: 'Minimalist',
      size: "6' × 9'",
      availableSizes: ["5' × 8'", "6' × 9'", "8' × 10'"],
      image: 'assets/images/products/nordic-flatweave-rug.jpg',
      gallery: [
        'assets/images/products/scandinavian-cotton-medium.jpg',
        'assets/images/products/scandinavian-cotton-detail-1.jpg',
        'assets/images/products/scandinavian-cotton-detail-2.jpg'
      ],
      badge: 'Organic Cotton',
      badgeColor: 'badge-luxury-gold',
      description: 'Crisp woven organic combed cotton with rhythmic textural ribs. Breathable, relaxed coastal sensibility, and easily maintained.'
    },
    {
      id: 15,
      name: 'Manhattan Velvet Plush Broadloom Carpet',
      category: 'Luxury Carpets',
      material: 'Wool',
      color: 'Charcoal',
      price: 980,
      oldPrice: 1200,
      rating: 4.9,
      reviewsCount: 27,
      style: 'Contemporary',
      size: "10' x 14'",
      availableSizes: ["8' x 10'", "10' x 14'", "12' x 16'"],
      image: 'assets/images/products/manhattan-velvet-carpet.jpg',
      gallery: [
        'assets/images/products/manhattan-velvet-carpet.jpg',
        'assets/images/products/manhattan-velvet-detail-1.jpg',
        'assets/images/products/manhattan-velvet-detail-2.jpg'
      ],
      badge: 'Ultra Plush',
      badgeColor: 'badge-luxury-terracotta',
      description: 'Deep sheared high-density New Zealand wool broadloom carpet engineered for luxurious penthouse sanctuaries and bespoke acoustic warmth.'
    }
  ];

  window.PRODUCTS_DATA = PRODUCTS_DATA;

  // Helper to construct structured dimension tiers for each product
  function buildProductSizesData(product) {
    if (product.sizesData) {
      return product.sizesData;
    }

    const gallery = (product.gallery && product.gallery.length === 3)
      ? product.gallery
      : [product.image, product.image, product.image];

    // Special custom values for Scandinavian Ribbed Cotton Flatweave (Product 14)
    if (product.id === 14) {
      return {
        small: {
          tier: 'small',
          label: 'Small',
          dimensions: "5' × 8'",
          size: "5' × 8'",
          price: 200,
          originalPrice: 240,
          oldPrice: 240,
          discount: 17,
          image: gallery[1],
          desc: 'Compact Room Scale'
        },
        medium: {
          tier: 'medium',
          label: 'Medium',
          dimensions: "6' × 9'",
          size: "6' × 9'",
          price: 300,
          originalPrice: 360,
          oldPrice: 360,
          discount: 17,
          image: gallery[0],
          desc: 'Standard Room Scale'
        },
        large: {
          tier: 'large',
          label: 'Large',
          dimensions: "8' × 10'",
          size: "8' × 10'",
          price: 440,
          originalPrice: 530,
          oldPrice: 530,
          discount: 17,
          image: gallery[2],
          desc: 'Expansive Room Scale'
        }
      };
    }

    const sizes = (product.availableSizes && product.availableSizes.length > 0)
      ? product.availableSizes
      : ["5' × 8'", "8' × 10'", "10' × 14'"];

    const smallDim = sizes[0].replace(/x/g, '×').trim();
    const medDim = ((sizes.length >= 2) ? sizes[1] : sizes[0]).replace(/x/g, '×').trim();
    const largeDim = sizes[sizes.length - 1].replace(/x/g, '×').trim();

    // Medium base price
    const medPrice = product.price;
    const medOldPrice = product.oldPrice || Math.round((medPrice * 1.22) / 10) * 10;
    const medDiscount = Math.max(0, Math.round((1 - medPrice / medOldPrice) * 100));

    // Small tier
    const smallPrice = Math.round((medPrice * 0.70) / 10) * 10;
    const smallOldPrice = Math.round((medOldPrice * 0.70) / 10) * 10;
    const smallDiscount = Math.max(0, Math.round((1 - smallPrice / smallOldPrice) * 100));

    // Large tier
    const largePrice = Math.round((medPrice * 1.48) / 10) * 10;
    const largeOldPrice = Math.round((medOldPrice * 1.48) / 10) * 10;
    const largeDiscount = Math.max(0, Math.round((1 - largePrice / largeOldPrice) * 100));

    return {
      small: {
        tier: 'small',
        label: 'Small',
        dimensions: smallDim,
        size: smallDim,
        price: smallPrice,
        originalPrice: smallOldPrice,
        oldPrice: smallOldPrice,
        discount: smallDiscount,
        image: gallery[1],
        desc: 'Compact Room Scale'
      },
      medium: {
        tier: 'medium',
        label: 'Medium',
        dimensions: medDim,
        size: medDim,
        price: medPrice,
        originalPrice: medOldPrice,
        oldPrice: medOldPrice,
        discount: medDiscount,
        image: gallery[0],
        desc: 'Standard Room Scale'
      },
      large: {
        tier: 'large',
        label: 'Large',
        dimensions: largeDim,
        size: largeDim,
        price: largePrice,
        originalPrice: largeOldPrice,
        oldPrice: largeOldPrice,
        discount: largeDiscount,
        image: gallery[2],
        desc: 'Expansive Room Scale'
      }
    };
  }

  // Attach sizesData to every product
  PRODUCTS_DATA.forEach(p => {
    p.sizesData = buildProductSizesData(p);
  });

  // Track selected size tier per product: { [productId]: 'small' | 'medium' | 'large' }
  const selectedSizesByProduct = {};

  window.getSelectedCardTier = function (productId) {
    return selectedSizesByProduct[productId] || 'medium';
  };

  window.setSelectedCardTier = function (productId, tier) {
    selectedSizesByProduct[productId] = tier;
  };

  // Render a Single Product Card HTML with Dynamic Size Selectors
  window.renderProductCard = function (product) {
    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }

    const selectedTier = window.getSelectedCardTier(product.id);
    const activeTier = product.sizesData[selectedTier] || product.sizesData.medium;

    const discountPercent = activeTier.discount || 0;
    const hasDiscount = (activeTier.originalPrice && activeTier.originalPrice > activeTier.price);

    const isWishlisted = typeof window.getWishlist === 'function' && window.getWishlist().includes(product.id);

    return `
      <div class="col-lg-4 col-md-6 col-sm-6 mb-4">
        <div class="product-card" id="productCard-${product.id}">
          <div class="product-thumb-box">
            <a href="product-details.html?id=${product.id}&size=${activeTier.tier}" id="cardThumbLink-${product.id}" class="product-thumb-link" title="View ${product.name}">
              <img id="cardImg-${product.id}" src="${activeTier.image}" alt="${product.name} — ${activeTier.label} (${activeTier.dimensions})" loading="lazy">
            </a>
            <div class="product-badge-group">
              ${product.badge ? `<span class="badge-luxury ${product.badgeColor}">${product.badge}</span>` : ''}
            </div>
            <div class="product-actions-bar">
              <button class="product-action-btn" title="Quick View" onclick="openQuickViewWithTier(${product.id}, event)">
                <i class="bi bi-eye"></i>
              </button>
              <button class="product-action-btn ${isWishlisted ? 'is-wishlisted' : ''}" title="${isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist'}" data-wishlist-id="${product.id}" onclick="toggleWishlist(${product.id}, this)">
                <i class="bi ${isWishlisted ? 'bi-heart-fill text-danger' : 'bi-heart'}"></i>
              </button>
              <button class="product-action-btn card-add-to-cart-btn" id="cardAddToCartBtn-${product.id}" data-product-id="${product.id}" title="Add to Bag" onclick="addCardProductToCart(${product.id}, event)">
                <i class="bi bi-bag-plus"></i>
              </button>
            </div>
          </div>
          <div class="product-info-box">
            <div class="product-category-tag">${product.category} • ${product.material}</div>
            <h5 class="product-name">
              <a href="product-details.html?id=${product.id}&size=${activeTier.tier}" id="cardTitleLink-${product.id}">${product.name}</a>
            </h5>
            
            <!-- Dynamic Small, Medium, Large Size Selector -->
            <div class="card-size-selector-group">
              <div class="card-size-selector-label">
                <span>Select Dimension:</span>
                <span class="card-size-val" id="cardSizeLabel-${product.id}">${activeTier.label} (${activeTier.dimensions})</span>
              </div>
              <div class="card-size-pills" id="cardSizePills-${product.id}" role="group" aria-label="Rug dimension selection">
                <button type="button" 
                        class="card-size-pill ${selectedTier === 'small' ? 'active' : ''}" 
                        data-product-id="${product.id}"
                        data-tier="small" 
                        onclick="selectCardSize(${product.id}, 'small', event)"
                        aria-pressed="${selectedTier === 'small' ? 'true' : 'false'}"
                        title="Small: ${product.sizesData.small.dimensions}">
                  Small
                </button>
                <button type="button" 
                        class="card-size-pill ${selectedTier === 'medium' ? 'active' : ''}" 
                        data-product-id="${product.id}"
                        data-tier="medium" 
                        onclick="selectCardSize(${product.id}, 'medium', event)"
                        aria-pressed="${selectedTier === 'medium' ? 'true' : 'false'}"
                        title="Medium: ${product.sizesData.medium.dimensions}">
                  Medium
                </button>
                <button type="button" 
                        class="card-size-pill ${selectedTier === 'large' ? 'active' : ''}" 
                        data-product-id="${product.id}"
                        data-tier="large" 
                        onclick="selectCardSize(${product.id}, 'large', event)"
                        aria-pressed="${selectedTier === 'large' ? 'true' : 'false'}"
                        title="Large: ${product.sizesData.large.dimensions}">
                  Large
                </button>
              </div>
            </div>

            <div class="product-meta d-flex justify-content-between align-items-center">
              <span id="cardMetaSize-${product.id}">Size: <strong>${activeTier.dimensions}</strong> <small class="text-muted">(${activeTier.label})</small></span>
              <div class="rating-stars">
                <i class="bi bi-star-fill"></i>
                <span class="ms-1 fw-bold text-heading small">${product.rating}</span>
                <span class="text-muted small">(${product.reviewsCount})</span>
              </div>
            </div>
            
            <div class="product-price-box d-flex align-items-center flex-wrap gap-2">
              <span class="product-current-price" id="cardPrice-${product.id}">$${activeTier.price.toLocaleString()}</span>
              <span class="product-old-price" id="cardOldPrice-${product.id}" style="${hasDiscount ? '' : 'display:none'}">${hasDiscount ? `$${activeTier.originalPrice.toLocaleString()}` : ''}</span>
              <span class="badge bg-danger-subtle text-danger small fw-semibold px-2 py-0.5 rounded-pill card-discount-badge" id="cardDiscount-${product.id}" style="${discountPercent > 0 ? '' : 'display:none'}">Save ${discountPercent}%</span>
            </div>
          </div>
        </div>
      </div>
    `;
  };

  // Real-time Size Selector Handler for Product Cards
  window.selectCardSize = function (productId, tier, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }

    const product = PRODUCTS_DATA.find(p => p.id === productId);
    if (!product) return;
    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }
    if (!product.sizesData[tier]) return;

    const tierData = product.sizesData[tier];
    selectedSizesByProduct[productId] = tier;

    // 1. Smoothly update product card image with fade
    const imgEl = document.getElementById(`cardImg-${productId}`);
    if (imgEl) {
      imgEl.style.transition = 'opacity 0.22s ease';
      imgEl.style.opacity = '0.35';
      imgEl.src = tierData.image;
      imgEl.alt = `${product.name} — ${tierData.label} (${tierData.dimensions})`;
      setTimeout(() => {
        imgEl.style.opacity = '1';
      }, 40);
    }

    // 2. Update size label in selector & meta text
    const sizeLabelEl = document.getElementById(`cardSizeLabel-${productId}`);
    if (sizeLabelEl) {
      sizeLabelEl.textContent = `${tierData.label} (${tierData.dimensions})`;
    }

    const metaSizeEl = document.getElementById(`cardMetaSize-${productId}`);
    if (metaSizeEl) {
      metaSizeEl.innerHTML = `Size: <strong>${tierData.dimensions}</strong> <small class="text-muted">(${tierData.label})</small>`;
    }

    // 3. Update active pill highlight & aria-pressed
    const pillGroup = document.getElementById(`cardSizePills-${productId}`);
    if (pillGroup) {
      pillGroup.querySelectorAll('.card-size-pill').forEach(pill => {
        const isMatch = pill.getAttribute('data-tier') === tier;
        pill.classList.toggle('active', isMatch);
        pill.setAttribute('aria-pressed', isMatch ? 'true' : 'false');
      });
    }

    // 4. Update displayed price, old price, and discount badge
    const priceEl = document.getElementById(`cardPrice-${productId}`);
    if (priceEl) {
      priceEl.textContent = `$${tierData.price.toLocaleString()}`;
    }

    const oldPriceEl = document.getElementById(`cardOldPrice-${productId}`);
    const discountEl = document.getElementById(`cardDiscount-${productId}`);
    if (tierData.originalPrice && tierData.originalPrice > tierData.price) {
      if (oldPriceEl) {
        oldPriceEl.textContent = `$${tierData.originalPrice.toLocaleString()}`;
        oldPriceEl.style.display = 'inline';
      }
      if (discountEl) {
        discountEl.textContent = `Save ${tierData.discount}%`;
        discountEl.style.display = 'inline-block';
      }
    } else {
      if (oldPriceEl) oldPriceEl.style.display = 'none';
      if (discountEl) discountEl.style.display = 'none';
    }

    // 5. Update detail page links
    const thumbLink = document.getElementById(`cardThumbLink-${productId}`);
    if (thumbLink) {
      thumbLink.href = `product-details.html?id=${productId}&size=${tier}`;
    }
    const titleLink = document.getElementById(`cardTitleLink-${productId}`);
    if (titleLink) {
      titleLink.href = `product-details.html?id=${productId}&size=${tier}`;
    }
  };

  // Add to Cart from Product Card using Active Size Tier
  window.addCardProductToCart = function (productId, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    const product = PRODUCTS_DATA.find(p => p.id === productId);
    if (!product) return;
    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }
    const tier = window.getSelectedCardTier(productId);
    const tierData = product.sizesData[tier] || product.sizesData.medium;
    if (typeof window.addToCart === 'function') {
      window.addToCart(
        product, 
        tierData.dimensions, 
        1, 
        tierData.price, 
        tierData.image, 
        tierData.tier, 
        tierData.originalPrice, 
        tierData.discount
      );
    }
  };

  // Global Delegated Event Listener for Card Size Pills and Add-to-Cart Buttons
  document.addEventListener('click', function (e) {
    const sizePill = e.target.closest('.card-size-pill');
    if (sizePill) {
      e.preventDefault();
      e.stopPropagation();
      const pid = parseInt(sizePill.getAttribute('data-product-id'), 10);
      const tier = sizePill.getAttribute('data-tier');
      if (pid && tier && typeof window.selectCardSize === 'function') {
        window.selectCardSize(pid, tier);
      }
      return;
    }

    const addBtn = e.target.closest('.card-add-to-cart-btn');
    if (addBtn) {
      e.preventDefault();
      e.stopPropagation();
      const pid = parseInt(addBtn.getAttribute('data-product-id'), 10);
      if (pid && typeof window.addCardProductToCart === 'function') {
        window.addCardProductToCart(pid);
      }
      return;
    }
  });

  // Open Quick View with selected tier
  window.openQuickViewWithTier = function (productId, event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    const tier = window.getSelectedCardTier(productId);
    window.openQuickView(productId, tier);
  };

  // Quick View Modal Opener with Tier Support
  window.openQuickView = function (productId, initialTier = null) {
    const product = PRODUCTS_DATA.find(p => p.id === productId);
    if (!product) return;

    const modalEl = document.getElementById('quickViewModal');
    if (!modalEl) return;

    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }

    const activeTierName = initialTier || window.getSelectedCardTier(productId) || 'medium';
    const activeTier = product.sizesData[activeTierName] || product.sizesData.medium;

    // Fill Modal Data
    document.getElementById('qvTitle').textContent = product.name;
    document.getElementById('qvPrice').textContent = `$${activeTier.price.toLocaleString()}`;
    const oldPriceEl = document.getElementById('qvOldPrice');
    if (oldPriceEl) {
      oldPriceEl.textContent = (activeTier.originalPrice && activeTier.originalPrice > activeTier.price) ? `$${activeTier.originalPrice.toLocaleString()}` : '';
      oldPriceEl.style.display = (activeTier.originalPrice && activeTier.originalPrice > activeTier.price) ? 'inline' : 'none';
    }
    document.getElementById('qvImage').src = activeTier.image;
    document.getElementById('qvCategory').textContent = product.category;
    document.getElementById('qvMaterial').textContent = product.material;
    document.getElementById('qvRating').textContent = product.rating;
    document.getElementById('qvReviews').textContent = `(${product.reviewsCount} customer reviews)`;
    document.getElementById('qvDesc').textContent = product.description;

    // Sizes buttons for Small, Medium, Large tiers
    const sizesContainer = document.getElementById('qvSizes');
    if (sizesContainer) {
      const tiersList = [product.sizesData.small, product.sizesData.medium, product.sizesData.large];
      sizesContainer.innerHTML = tiersList.map(t => {
        const isAct = t.tier === activeTierName;
        return `
          <button type="button" 
                  class="btn btn-sm ${isAct ? 'active' : ''} me-2 mb-2 qv-size-pill" 
                  data-tier="${t.tier}"
                  data-size="${t.dimensions.replace(/"/g, '&quot;')}" 
                  data-price="${t.price}"
                  data-oldprice="${t.originalPrice || ''}"
                  data-image="${t.image}"
                  onclick="selectQuickViewSize(this, ${product.id})">
            ${t.label} (${t.dimensions})
          </button>
        `;
      }).join('');
    }

    // Set Add to Cart action button
    const qvAddBtn = document.getElementById('qvAddToCartBtn');
    if (qvAddBtn) {
      qvAddBtn.onclick = function () {
        const activeSizePill = document.querySelector('.qv-size-pill.active');
        const chosenTier = activeSizePill ? activeSizePill.getAttribute('data-tier') : activeTierName;
        const tierData = product.sizesData[chosenTier] || activeTier;
        const qtyInput = document.getElementById('qvQuantity');
        const qty = qtyInput ? parseInt(qtyInput.value, 10) || 1 : 1;
        addToCart(
          product, 
          tierData.dimensions, 
          qty, 
          tierData.price, 
          tierData.image, 
          tierData.tier, 
          tierData.originalPrice, 
          tierData.discount
        );
        bootstrap.Modal.getInstance(modalEl).hide();
      };
    }

    const bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
    bsModal.show();
  };

  window.selectQuickViewSize = function (btn, productId) {
    if (!btn) return;
    document.querySelectorAll('.qv-size-pill').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    const price = btn.getAttribute('data-price');
    const oldPrice = btn.getAttribute('data-oldprice');
    const img = btn.getAttribute('data-image');
    const tier = btn.getAttribute('data-tier');

    if (price) {
      const qvPriceEl = document.getElementById('qvPrice');
      if (qvPriceEl) qvPriceEl.textContent = `$${parseInt(price, 10).toLocaleString()}`;
    }
    const oldPriceEl = document.getElementById('qvOldPrice');
    if (oldPriceEl) {
      if (oldPrice) {
        oldPriceEl.textContent = `$${parseInt(oldPrice, 10).toLocaleString()}`;
        oldPriceEl.style.display = 'inline';
      } else {
        oldPriceEl.style.display = 'none';
      }
    }
    if (img) {
      const qvImgEl = document.getElementById('qvImage');
      if (qvImgEl) qvImgEl.src = img;
    }

    // Also sync the card if visible
    if (productId && tier) {
      selectCardSize(productId, tier);
    }
  };

  // Filter and Sorting Logic for products.html
  window.filterAndRenderProducts = function () {
    const container = document.getElementById('productsGridContainer');
    if (!container) return;

    let filtered = [...PRODUCTS_DATA];

    // Filter by Category
    const selectedCategory = document.querySelector('input[name="filterCategory"]:checked')?.value;
    if (selectedCategory && selectedCategory !== 'all') {
      filtered = filtered.filter(p => p.category.toLowerCase().includes(selectedCategory.toLowerCase()));
    }

    // Filter by Material
    const selectedMaterials = Array.from(document.querySelectorAll('input[name="filterMaterial"]:checked')).map(cb => cb.value.toLowerCase());
    if (selectedMaterials.length > 0 && !selectedMaterials.includes('all')) {
      filtered = filtered.filter(p => {
        const pMat = p.material.toLowerCase();
        return selectedMaterials.some(m => pMat.includes(m) || m.includes(pMat));
      });
    }

    // Filter by Color
    const selectedColor = document.querySelector('.color-swatch.active')?.getAttribute('data-color');
    if (selectedColor && selectedColor !== 'all') {
      filtered = filtered.filter(p => p.color.toLowerCase() === selectedColor.toLowerCase());
    }

    // Filter by Price Range (evaluating against currently selected tier price or base price)
    const priceMaxInput = document.getElementById('priceRangeSlider');
    if (priceMaxInput) {
      const maxVal = parseFloat(priceMaxInput.value);
      filtered = filtered.filter(p => {
        const tier = window.getSelectedCardTier(p.id);
        const curPrice = (p.sizesData && p.sizesData[tier]) ? p.sizesData[tier].price : p.price;
        return curPrice <= maxVal;
      });
    }

    // Filter by URL Search Query (e.g. ?q=silk)
    const urlParams = new URLSearchParams(window.location.search);
    const searchParam = urlParams.get('q');
    if (searchParam && searchParam.trim()) {
      const q = searchParam.trim().toLowerCase();
      filtered = filtered.filter(p => 
        p.name.toLowerCase().includes(q) ||
        p.category.toLowerCase().includes(q) ||
        p.material.toLowerCase().includes(q) ||
        p.description.toLowerCase().includes(q) ||
        p.style.toLowerCase().includes(q)
      );
    }

    // Sorting (respecting active tier price)
    const sortSelect = document.getElementById('sortSelect');
    if (sortSelect) {
      const sortVal = sortSelect.value;
      if (sortVal === 'price-low') {
        filtered.sort((a, b) => {
          const aTier = window.getSelectedCardTier(a.id);
          const bTier = window.getSelectedCardTier(b.id);
          const aPrice = (a.sizesData && a.sizesData[aTier]) ? a.sizesData[aTier].price : a.price;
          const bPrice = (b.sizesData && b.sizesData[bTier]) ? b.sizesData[bTier].price : b.price;
          return aPrice - bPrice;
        });
      } else if (sortVal === 'price-high') {
        filtered.sort((a, b) => {
          const aTier = window.getSelectedCardTier(a.id);
          const bTier = window.getSelectedCardTier(b.id);
          const aPrice = (a.sizesData && a.sizesData[aTier]) ? a.sizesData[aTier].price : a.price;
          const bPrice = (b.sizesData && b.sizesData[bTier]) ? b.sizesData[bTier].price : b.price;
          return bPrice - aPrice;
        });
      } else if (sortVal === 'rating') {
        filtered.sort((a, b) => b.rating - a.rating);
      } else if (sortVal === 'popularity') {
        filtered.sort((a, b) => b.reviewsCount - a.reviewsCount);
      }
    }

    // Update Result Count
    const countDisplay = document.getElementById('productsFoundCount');
    if (countDisplay) {
      countDisplay.textContent = filtered.length;
    }

    // Render Grid
    if (filtered.length === 0) {
      container.innerHTML = `
        <div class="col-12 text-center py-5">
          <i class="bi bi-funnel display-4 text-muted mb-3 d-block"></i>
          <h4 class="font-serif">No Rugs Match Your Criteria</h4>
          <p class="text-muted">Try clearing some of your selected filters or price slider.</p>
          <button class="btn btn-luxury-primary btn-sm mt-2" onclick="resetFilters()">Reset All Filters</button>
        </div>
      `;
    } else {
      container.innerHTML = filtered.map(renderProductCard).join('');
    }
  };

  window.resetFilters = function () {
    document.querySelectorAll('input[name="filterCategory"]').forEach(r => r.checked = r.value === 'all');
    document.querySelectorAll('input[name="filterMaterial"]').forEach(cb => cb.checked = false);
    document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
    const slider = document.getElementById('priceRangeSlider');
    if (slider) {
      slider.value = 1500;
      const display = document.getElementById('priceSliderValue');
      if (display) display.textContent = '$1,500';
    }
    // Remove query params from URL without reload
    if (window.history.pushState) {
      const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
      window.history.pushState({ path: cleanUrl }, '', cleanUrl);
    }
    const banner = document.getElementById('activeFilterBanner');
    if (banner) banner.style.display = 'none';
    filterAndRenderProducts();
  };

  // =========================================================================
  // PRODUCT DETAILS PAGE CONTROLLER
  // =========================================================================
  let currentDetailProduct = null;
  let currentDetailSelectedTier = 'medium';

  window.getCurrentDetailProduct = function() {
    return currentDetailProduct;
  };

  window.setCurrentDetailProduct = function(p) {
    currentDetailProduct = p;
  };

  window.getCurrentDetailSelectedTier = function() {
    return currentDetailSelectedTier;
  };

  window.selectProductDetailTier = function (tier, updateUrl = true) {
    const product = currentDetailProduct || window.currentProduct || (window.PRODUCTS_DATA ? window.PRODUCTS_DATA[0] : null);
    if (!product) return;
    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }

    const normTier = (tier || 'medium').toLowerCase();
    const tierData = product.sizesData[normTier] || product.sizesData.medium || product.sizesData[Object.keys(product.sizesData)[0]];
    if (!tierData) return;

    currentDetailSelectedTier = normTier;
    product.size = tierData.dimensions;
    window.currentSelectedSize = tierData.dimensions;
    window.currentSelectedTier = normTier;

    // 1. Smoothly update main image
    const mainImg = document.getElementById('mainProductImage');
    if (mainImg) {
      mainImg.style.transition = 'opacity 0.22s ease';
      mainImg.style.opacity = '0.35';
      mainImg.src = tierData.image;
      mainImg.alt = `${product.name} — ${tierData.label} (${tierData.dimensions})`;
      setTimeout(() => {
        mainImg.style.opacity = '1';
      }, 40);
    }

    // 2. Update floating badge
    const tagText = document.getElementById('pdCurrentDimensionText');
    if (tagText) {
      tagText.textContent = `${tierData.label}: ${tierData.dimensions}`;
    }

    // 3. Highlight room scale buttons
    document.querySelectorAll('#pdRoomScaleBar .room-scale-btn').forEach(btn => {
      const isMatch = btn.getAttribute('data-tier') === normTier;
      btn.classList.toggle('active', isMatch);
    });

    // 4. Highlight thumbnail cards
    document.querySelectorAll('#pdThumbnailsRow .dimension-thumb-card').forEach(card => {
      const isMatch = card.getAttribute('data-tier') === normTier;
      card.classList.toggle('active', isMatch);
    });

    // 5. Highlight size pills under Select Dimensions
    document.querySelectorAll('#pdSizeOptions .size-pill').forEach(pill => {
      const isMatch = pill.getAttribute('data-tier') === normTier;
      pill.classList.toggle('active', isMatch);
      pill.setAttribute('aria-pressed', isMatch ? 'true' : 'false');
    });

    // 6. Update size labels & spec table
    const displayEl = document.getElementById('pdSelectedSizeDisplay');
    if (displayEl) {
      displayEl.textContent = `${tierData.label} (${tierData.dimensions})`;
    }

    const specSizeEl = document.getElementById('pdSpecSize');
    if (specSizeEl) {
      specSizeEl.textContent = `${tierData.dimensions} (${tierData.label})`;
    }

    // 7. Update price, original price, and discount badge
    const priceEl = document.getElementById('pdPrice');
    if (priceEl) {
      priceEl.textContent = `$${tierData.price.toLocaleString()} USD`;
    }

    const oldPriceEl = document.getElementById('pdOldPrice');
    const saveBadgeEl = document.getElementById('pdSaveBadge');
    if (tierData.originalPrice && tierData.originalPrice > tierData.price) {
      if (oldPriceEl) {
        oldPriceEl.textContent = `$${tierData.originalPrice.toLocaleString()} USD`;
        oldPriceEl.style.display = 'inline';
      }
      if (saveBadgeEl) {
        saveBadgeEl.textContent = `Save ${tierData.discount}%`;
        saveBadgeEl.style.display = 'inline-block';
      }
    } else {
      if (oldPriceEl) oldPriceEl.style.display = 'none';
      if (saveBadgeEl) saveBadgeEl.style.display = 'none';
    }

    // 8. Update browser URL without reload
    if (updateUrl && window.history && window.history.replaceState) {
      const newUrl = new URL(window.location.href);
      newUrl.searchParams.set('id', product.id);
      newUrl.searchParams.set('size', normTier);
      window.history.replaceState({ id: product.id, size: normTier }, '', newUrl.toString());
    }
  };

  // Backwards compatibility aliases
  window.selectDimensionView = function(viewId) {
    window.selectProductDetailTier(viewId);
  };

  window.selectSize = function(btn) {
    if (!btn) return;
    if (typeof btn === 'string') {
      window.selectProductDetailTier(btn);
      return;
    }
    const tier = btn.getAttribute('data-tier');
    if (tier) {
      window.selectProductDetailTier(tier);
      return;
    }
    const rawText = (btn.getAttribute('data-size') || btn.textContent || '').trim().toLowerCase();
    if (rawText.includes('small') || rawText.includes('5\'') || rawText.includes('2.5\' x 8') || rawText.includes('6\' x 9\'')) {
      window.selectProductDetailTier('small');
    } else if (rawText.includes('large') || rawText.includes('9\'') || rawText.includes('10\'') || rawText.includes('12\'')) {
      window.selectProductDetailTier('large');
    } else {
      window.selectProductDetailTier('medium');
    }
  };

  window.handleAddToCartFromDetails = function() {
    const product = currentDetailProduct || window.currentProduct || (window.PRODUCTS_DATA ? window.PRODUCTS_DATA[0] : null);
    if (!product) return;
    const qtyInput = document.getElementById('pdQuantity');
    const qty = qtyInput ? parseInt(qtyInput.value, 10) || 1 : 1;
    const tierData = (product.sizesData && product.sizesData[currentDetailSelectedTier]) 
      ? product.sizesData[currentDetailSelectedTier] 
      : (product.sizesData ? product.sizesData.medium : null);

    if (tierData && typeof window.addToCart === 'function') {
      window.addToCart(
        product, 
        tierData.dimensions, 
        qty, 
        tierData.price, 
        tierData.image, 
        tierData.tier, 
        tierData.originalPrice, 
        tierData.discount
      );
    } else if (typeof window.addToCart === 'function') {
      window.addToCart(product, product.size, qty);
    }
  };

  window.handleBuyNow = function() {
    window.handleAddToCartFromDetails();
    setTimeout(() => {
      window.location.href = 'checkout.html';
    }, 250);
  };

  window.handleToggleWishlistFromDetails = function() {
    const product = currentDetailProduct;
    if (!product) return;
    const btn = document.getElementById('pdWishlistBtn');
    if (typeof window.toggleWishlist === 'function') {
      window.toggleWishlist(product.id, btn);
    }
  };

  window.loadProductDetails = function() {
    const urlParams = new URLSearchParams(window.location.search);
    const idParam = parseInt(urlParams.get('id'), 10);
    
    const product = (window.PRODUCTS_DATA && window.PRODUCTS_DATA.find(p => p.id === idParam)) 
      || (window.PRODUCTS_DATA ? window.PRODUCTS_DATA[0] : null);
    
    if (!product) return;
    currentDetailProduct = product;
    window.currentProduct = product;

    // Ensure sizesData exists
    if (!product.sizesData) {
      product.sizesData = buildProductSizesData(product);
    }

    // Check if size parameter is passed in URL (e.g. ?id=1&size=small)
    const urlSizeParam = (urlParams.get('size') || '').toLowerCase();
    const initialTier = (['small', 'medium', 'large'].includes(urlSizeParam)) 
      ? urlSizeParam 
      : 'medium';

    currentDetailSelectedTier = initialTier;
    window.currentSelectedTier = initialTier;

    // Document Title
    document.title = `${product.name} — Atelier Rugs`;

    // Breadcrumbs
    const breadcrumbCategory = document.getElementById('breadcrumbCategoryLink');
    if (breadcrumbCategory) {
      breadcrumbCategory.textContent = product.category;
      const cleanCat = product.category.replace(' Rugs', '').replace(' Luxury', '').trim();
      breadcrumbCategory.href = `products.html?category=${encodeURIComponent(cleanCat)}`;
    }
    const breadcrumbName = document.getElementById('breadcrumbProductName');
    if (breadcrumbName) breadcrumbName.textContent = product.name;

    // Populate Room Scale Quick-Bar with Small, Medium, Large
    const scaleBar = document.getElementById('pdRoomScaleBar');
    if (scaleBar && product.sizesData) {
      const tiers = ['small', 'medium', 'large'];
      scaleBar.innerHTML = tiers.map(tierKey => {
        const t = product.sizesData[tierKey];
        const isAct = tierKey === initialTier;
        return `
          <button type="button" 
                  id="scaleBtn-${t.tier}"
                  class="room-scale-btn ${isAct ? 'active' : ''}" 
                  data-tier="${t.tier}"
                  onclick="selectProductDetailTier('${t.tier}')">
            <span class="scale-label">${t.label}</span>
            <span class="scale-size">${t.dimensions}</span>
          </button>
        `;
      }).join('');
    }

    // Populate Thumbnails Row (Small, Medium, Large Dimension Cards)
    const thumbsRow = document.getElementById('pdThumbnailsRow');
    if (thumbsRow && product.sizesData) {
      const tiers = ['small', 'medium', 'large'];
      thumbsRow.innerHTML = tiers.map(tierKey => {
        const t = product.sizesData[tierKey];
        const isAct = tierKey === initialTier;
        return `
          <div class="col-4">
            <div class="dimension-thumb-card ${isAct ? 'active' : ''}" 
                 id="dimThumbCard-${t.tier}"
                 data-tier="${t.tier}"
                 onclick="selectProductDetailTier('${t.tier}')"
                 title="View ${t.label} (${t.dimensions})">
              <img src="${t.image}" alt="${product.name} ${t.label}">
              <div class="dimension-thumb-tag">${t.label.toUpperCase()}: ${t.dimensions}</div>
            </div>
          </div>
        `;
      }).join('');
    }

    // Title & Badge
    const titleEl = document.getElementById('pdTitle');
    if (titleEl) titleEl.textContent = product.name;

    const badgeEl = document.getElementById('pdBadge');
    if (badgeEl) {
      badgeEl.textContent = product.badge ? `${product.badge} • Handcrafted Masterpiece` : 'Curated Artisan Piece';
    }

    // Rating & Reviews
    const ratingEl = document.getElementById('pdRating');
    if (ratingEl) ratingEl.textContent = product.rating;
    const reviewsEl = document.getElementById('pdReviewsCount');
    if (reviewsEl) reviewsEl.textContent = `(${product.reviewsCount} verified collector reviews)`;
    const reviewsTab = document.getElementById('reviews-tab');
    if (reviewsTab) reviewsTab.textContent = `Reviews (${product.reviewsCount})`;

    // Description
    const descEl = document.getElementById('pdDescription');
    if (descEl) descEl.textContent = product.description;

    // Specs Summary
    const matEl = document.getElementById('pdMaterial');
    if (matEl) matEl.textContent = `${product.material} (${product.style})`;
    const knotEl = document.getElementById('pdKnotDensity');
    if (knotEl) {
      if (product.material.toLowerCase().includes('silk')) knotEl.textContent = '600 Knots / Sq Inch (KPSI)';
      else if (product.material.toLowerCase().includes('wool')) knotEl.textContent = '350 KPSI Hand-Knotted';
      else if (product.material.toLowerCase().includes('cotton')) knotEl.textContent = 'Tight Flatweave Ribbed';
      else knotEl.textContent = 'High-Density Chunky Braid';
    }
    let originText = 'Atelier Heritage Looms';
    if (product.name.includes('Isfahan') || product.name.includes('Caspian')) originText = 'Isfahan Atelier, Persia';
    else if (product.name.includes('Berber') || product.name.includes('Moroccan') || product.name.includes('Atlas')) originText = 'Atlas Mountains, Morocco';
    else if (product.name.includes('Nordic') || product.name.includes('Scandinavian')) originText = 'Copenhagen Guild, Scandinavia';
    else if (product.name.includes('Oushak') || product.name.includes('Anatolian')) originText = 'Anatolia & Usak, Turkey';
    else if (product.name.includes('Kyoto') || product.name.includes('Bengal') || product.name.includes('Solstice')) originText = 'Bengal Weavers, India';
    else if (product.name.includes('Jaipur')) originText = 'Jaipur Artisan Cluster, India';
    else if (product.name.includes('Santorini') || product.name.includes('Amalfi')) originText = 'Mediterranean Atelier, Italy/Greece';

    const originEl = document.getElementById('pdOrigin');
    if (originEl) originEl.textContent = originText;

    const styleEl = document.getElementById('pdStyle');
    if (styleEl) styleEl.textContent = `${product.style} Design`;

    // Populate Size Pills under Select Dimensions
    const sizesContainer = document.getElementById('pdSizeOptions');
    if (sizesContainer && product.sizesData) {
      const tiers = ['small', 'medium', 'large'];
      sizesContainer.innerHTML = tiers.map(tierKey => {
        const t = product.sizesData[tierKey];
        const isAct = tierKey === initialTier;
        return `
          <button type="button" 
                  id="sizeBtn-${t.tier}"
                  class="btn size-pill ${isAct ? 'active' : ''}" 
                  data-tier="${t.tier}" 
                  aria-pressed="${isAct ? 'true' : 'false'}"
                  onclick="selectProductDetailTier('${t.tier}')">
            <span class="fw-bold">${t.label}</span> <span class="size-pill-dim text-muted">(${t.dimensions})</span>
          </button>
        `;
      }).join('');
    }

    // Activate Initial Size Tier
    window.selectProductDetailTier(initialTier, false);

    // Wishlist Button
    const wishBtn = document.getElementById('pdWishlistBtn');
    if (wishBtn) {
      wishBtn.setAttribute('data-wishlist-id', product.id);
      const isWishlisted = typeof window.getWishlist === 'function' && window.getWishlist().includes(product.id);
      const icon = wishBtn.querySelector('i');
      if (icon) {
        icon.className = `bi ${isWishlisted ? 'bi-heart-fill text-danger' : 'bi-heart'}`;
      }
    }

    // Artisan Story Tab Pane
    const descTabPane = document.getElementById('desc-tab-pane');
    if (descTabPane) {
      descTabPane.innerHTML = `
        <h4 class="font-serif fw-bold mb-3">${product.name} — Craftsmanship & Heritage</h4>
        <p class="text-muted leading-relaxed mb-4">
          ${product.description}
        </p>
        <p class="text-muted leading-relaxed">
          Every thread in this piece undergoes meticulous sorting, hand-spinning, and natural botanical dying before being anchored onto upright timber looms. The tactile interaction between organic ${product.material} and ambient lighting infuses architectural residences with warmth, depth, and unmistakable character.
        </p>
      `;
    }

    // Specs Table Tab Pane
    const specsTabPane = document.getElementById('specs-tab-pane');
    if (specsTabPane) {
      specsTabPane.innerHTML = `
        <table class="table table-bordered">
          <tbody>
            <tr><th class="w-25 bg-subtle">Product Name</th><td>${product.name}</td></tr>
            <tr><th class="bg-subtle">Category</th><td>${product.category}</td></tr>
            <tr><th class="bg-subtle">Primary Material</th><td>${product.material} (100% Organic & Ethically Sourced)</td></tr>
            <tr><th class="bg-subtle">Weaving Style</th><td>${product.style} Weave</td></tr>
            <tr><th class="bg-subtle">Artisan Origin</th><td>${originText}</td></tr>
            <tr><th class="bg-subtle">Selected Dimensions</th><td id="pdSpecSize">${(product.sizesData[initialTier] || product.sizesData.medium).dimensions} (${(product.sizesData[initialTier] || product.sizesData.medium).label})</td></tr>
            <tr><th class="bg-subtle">Underfloor Heating</th><td>Compatible with all hydronic and electric radiant floor heating systems</td></tr>
            <tr><th class="bg-subtle">Care Instructions</th><td>Professional rug cleaning recommended; vacuum without beater bar</td></tr>
          </tbody>
        </table>
      `;
    }

    // Related Products (excluding current product)
    const relatedRow = document.getElementById('relatedProductsRow');
    if (relatedRow && window.PRODUCTS_DATA && window.renderProductCard) {
      const related = window.PRODUCTS_DATA
        .filter(p => p.id !== product.id)
        .slice(0, 3);
      relatedRow.innerHTML = related.map(renderProductCard).join('');
    }
  };
})();
