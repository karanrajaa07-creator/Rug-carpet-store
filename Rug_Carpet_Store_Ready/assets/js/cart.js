/**
 * RUG & CARPET STORE - CART & WISHLIST CONTROLLER
 * Full localStorage e-commerce cart drawer, wishlist counters, and toast notifications.
 */

(function () {
  'use strict';

  const CART_STORAGE_KEY = 'rug_store_cart';
  const WISHLIST_STORAGE_KEY = 'rug_store_wishlist';
  const FREE_SHIPPING_THRESHOLD = 500;

  // Initial demo cart items if empty
  const defaultCart = [
    {
      id: 1,
      name: 'Isfahan Silk Medallion Rug',
      price: 850,
      size: "8' x 10'",
      image: 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?auto=format&fit=crop&w=600&q=80',
      quantity: 1
    }
  ];

  window.RugStore = window.RugStore || {};

  // 1. Get & Save State
  function getCart() {
    try {
      const stored = localStorage.getItem(CART_STORAGE_KEY);
      return stored ? JSON.parse(stored) : defaultCart;
    } catch (e) {
      return defaultCart;
    }
  }

  function saveCart(cart) {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
    updateCartUI();
  }

  function getWishlist() {
    try {
      const stored = localStorage.getItem(WISHLIST_STORAGE_KEY);
      if (stored !== null) {
        return JSON.parse(stored);
      }
      const defaultWishlist = [1, 3];
      localStorage.setItem(WISHLIST_STORAGE_KEY, JSON.stringify(defaultWishlist));
      return defaultWishlist;
    } catch (e) {
      return [1, 3];
    }
  }

  function saveWishlist(wishlist) {
    localStorage.setItem(WISHLIST_STORAGE_KEY, JSON.stringify(wishlist));
    updateWishlistUI();
  }

  // 2. Cart Operations
  window.addToCart = function (product, size = null, qty = 1, customPrice = null, customImage = null, sizeTier = null, customOriginalPrice = null, customDiscount = null) {
    const cart = getCart();

    // Determine tier
    let targetTier = sizeTier;
    if (!targetTier && product.sizesData) {
      const normSize = (size || '').replace(/x/g, '×').trim().toLowerCase();
      for (const t of ['small', 'medium', 'large']) {
        const d = product.sizesData[t];
        if (d && (d.dimensions.replace(/x/g, '×').trim().toLowerCase() === normSize || d.size.replace(/x/g, '×').trim().toLowerCase() === normSize || t === normSize)) {
          targetTier = t;
          break;
        }
      }
    }
    if (!targetTier) targetTier = 'medium';

    const tierData = (product.sizesData && product.sizesData[targetTier]) ? product.sizesData[targetTier] : null;

    const targetDimensions = (size ? size.replace(/x/g, '×').trim() : (tierData ? tierData.dimensions : (product.size ? product.size.replace(/x/g, '×') : "8' × 10'")));
    const targetPrice = (customPrice !== null && customPrice !== undefined) ? Number(customPrice) : (tierData ? tierData.price : product.price);
    const targetOriginalPrice = (customOriginalPrice !== null && customOriginalPrice !== undefined) ? Number(customOriginalPrice) : (tierData ? tierData.originalPrice : (product.oldPrice || null));
    const targetDiscount = (customDiscount !== null && customDiscount !== undefined) ? Number(customDiscount) : (tierData ? tierData.discount : (targetOriginalPrice && targetOriginalPrice > targetPrice ? Math.round((1 - targetPrice / targetOriginalPrice) * 100) : 0));
    const targetImage = (customImage !== null && customImage !== undefined) ? customImage : (tierData ? tierData.image : product.image);
    const targetTierLabel = targetTier.charAt(0).toUpperCase() + targetTier.slice(1);

    const existingIndex = cart.findIndex(item => item.id === product.id && (item.sizeTier === targetTier || item.dimensions === targetDimensions || item.size === targetDimensions));

    if (existingIndex > -1) {
      cart[existingIndex].quantity += qty;
      cart[existingIndex].price = targetPrice;
      cart[existingIndex].originalPrice = targetOriginalPrice;
      cart[existingIndex].discount = targetDiscount;
      cart[existingIndex].image = targetImage;
      cart[existingIndex].dimensions = targetDimensions;
      cart[existingIndex].size = targetDimensions;
      cart[existingIndex].sizeTier = targetTier;
      cart[existingIndex].tierLabel = targetTierLabel;
    } else {
      cart.push({
        id: product.id,
        name: product.name,
        sizeTier: targetTier,
        tierLabel: targetTierLabel,
        dimensions: targetDimensions,
        size: targetDimensions,
        price: targetPrice,
        originalPrice: targetOriginalPrice,
        discount: targetDiscount,
        image: targetImage,
        quantity: qty
      });
    }

    saveCart(cart);
    showToast('Added to Cart', `${product.name} (${targetTierLabel}: ${targetDimensions}) was added to your bag.`, 'bi-bag-check-fill');

    // Open Offcanvas Drawer
    const cartOffcanvasEl = document.getElementById('cartDrawer');
    if (cartOffcanvasEl && window.bootstrap) {
      const bsOffcanvas = bootstrap.Offcanvas.getInstance(cartOffcanvasEl) || new bootstrap.Offcanvas(cartOffcanvasEl);
      bsOffcanvas.show();
    }
  };

  window.removeFromCart = function (index) {
    const cart = getCart();
    if (index >= 0 && index < cart.length) {
      const removed = cart.splice(index, 1)[0];
      saveCart(cart);
      showToast('Removed Item', `${removed.name} was removed from your bag.`, 'bi-trash3');
    }
  };

  window.updateCartQty = function (index, delta) {
    const cart = getCart();
    if (cart[index]) {
      cart[index].quantity += delta;
      if (cart[index].quantity <= 0) {
        cart.splice(index, 1);
      }
      saveCart(cart);
    }
  };

  // 3. Wishlist Operations
  window.toggleWishlist = function (productId, buttonEl = null) {
    const id = parseInt(productId, 10);
    const wishlist = getWishlist();
    const index = wishlist.indexOf(id);
    let isAdded = false;

    if (index > -1) {
      wishlist.splice(index, 1);
      showToast('Removed from Wishlist', 'Item removed from your saved list.', 'bi-heart');
    } else {
      wishlist.push(id);
      isAdded = true;
      showToast('Saved to Wishlist', 'Item added to your favorite rugs.', 'bi-heart-fill');
    }

    saveWishlist(wishlist);

    // If wishlist page is active, notify it to re-render
    if (typeof window.renderWishlistPage === 'function') {
      window.renderWishlistPage();
    }
  };

  window.removeFromWishlist = function (productId) {
    const id = parseInt(productId, 10);
    const wishlist = getWishlist();
    const index = wishlist.indexOf(id);
    if (index > -1) {
      wishlist.splice(index, 1);
      saveWishlist(wishlist);
      showToast('Removed from Wishlist', 'Item removed from your saved list.', 'bi-heart');
      if (typeof window.renderWishlistPage === 'function') {
        window.renderWishlistPage();
      }
    }
  };

  window.clearWishlist = function () {
    saveWishlist([]);
    showToast('Wishlist Cleared', 'All items have been removed from your saved list.', 'bi-trash3');
    if (typeof window.renderWishlistPage === 'function') {
      window.renderWishlistPage();
    }
  };

  // 4. Update UI Components
  function updateCartUI() {
    const cart = getCart();
    const count = cart.reduce((total, item) => total + item.quantity, 0);
    const subtotal = cart.reduce((total, item) => total + (item.price * item.quantity), 0);

    // Update Badges
    document.querySelectorAll('.cart-count-badge').forEach(el => {
      el.textContent = count;
      el.style.display = count > 0 ? 'flex' : 'none';
    });

    // Update Subtotal Elements
    document.querySelectorAll('.cart-subtotal-amount').forEach(el => {
      el.textContent = `$${subtotal.toLocaleString()}`;
    });

    // Update Free Shipping Bar
    const progressPercent = Math.min(100, Math.round((subtotal / FREE_SHIPPING_THRESHOLD) * 100));
    document.querySelectorAll('.free-shipping-progress').forEach(el => {
      el.style.width = `${progressPercent}%`;
    });

    const shippingTextEl = document.getElementById('shippingRemainingText');
    if (shippingTextEl) {
      if (subtotal >= FREE_SHIPPING_THRESHOLD) {
        shippingTextEl.innerHTML = '<span class="text-success fw-bold"><i class="bi bi-check-circle-fill me-1"></i> You unlocked Free Insured White-Glove Delivery!</span>';
      } else {
        const remaining = FREE_SHIPPING_THRESHOLD - subtotal;
        shippingTextEl.textContent = `Add $${remaining.toLocaleString()} more to qualify for Free White-Glove Delivery!`;
      }
    }

    // Render Drawer Items
    const drawerContainer = document.getElementById('cartDrawerItems');
    if (drawerContainer) {
      if (cart.length === 0) {
        drawerContainer.innerHTML = `
          <div class="text-center py-5">
            <i class="bi bi-bag-x display-4 text-muted mb-3 d-block"></i>
            <h5 class="fw-bold">Your Bag is Empty</h5>
            <p class="text-muted small">Explore our handwoven artisan rugs and add timeless elegance to your space.</p>
            <a href="products.html" class="btn btn-luxury-primary btn-sm mt-2">Browse Catalog</a>
          </div>
        `;
      } else {
        drawerContainer.innerHTML = cart.map((item, index) => `
          <div class="cart-item-row align-items-center">
            <a href="product-details.html?id=${item.id}&size=${item.sizeTier || 'medium'}"><img src="${item.image}" alt="${item.name}" class="cart-item-thumb"></a>
            <div class="flex-grow-1">
              <h6 class="mb-1 font-serif fw-bold"><a href="product-details.html?id=${item.id}&size=${item.sizeTier || 'medium'}" class="text-heading text-decoration-none">${item.name}</a></h6>
              <div class="text-muted small mb-2 d-flex align-items-center gap-1">
                <span class="badge bg-secondary-subtle text-secondary text-uppercase fw-semibold" style="font-size: 0.7rem;">${item.tierLabel || item.sizeTier || 'Medium'}</span>
                <span>${(item.dimensions || item.size).replace(/x/g, '×')}</span>
              </div>
              <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center gap-2">
                  <button class="cart-qty-btn" onclick="updateCartQty(${index}, -1)">-</button>
                  <span class="fw-bold px-1">${item.quantity}</span>
                  <button class="cart-qty-btn" onclick="updateCartQty(${index}, 1)">+</button>
                </div>
                <div>
                  <div class="fw-bold text-terracotta">$${(item.price * item.quantity).toLocaleString()}</div>
                  ${item.originalPrice && item.originalPrice > item.price ? `<div class="smaller text-muted text-decoration-line-through text-end">$${(item.originalPrice * item.quantity).toLocaleString()}</div>` : ''}
                </div>
              </div>
            </div>
            <button class="btn btn-link text-muted p-1 ms-2" onclick="removeFromCart(${index})" title="Remove item">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>
        `).join('');
      }
    }

    // Ensure all checkout buttons in cart drawers link to checkout.html
    document.querySelectorAll('#cartDrawer a.btn-luxury-primary, #cartDrawer a[href="products.html"]').forEach(btn => {
      if (btn.textContent.toLowerCase().includes('checkout')) {
        btn.setAttribute('href', 'checkout.html');
        btn.onclick = function (e) {
          const currentCart = getCart();
          if (!currentCart || currentCart.length === 0) {
            e.preventDefault();
            showToast('Shopping Bag Empty', 'Please add an artisan rug to your bag before proceeding to checkout.', 'bi-bag-x');
          }
        };
      }
    });
  }

  // Clear Cart helper
  window.clearCart = function () {
    localStorage.removeItem(CART_STORAGE_KEY);
    updateCartUI();
  };

  window.getCart = getCart;
  window.saveCart = saveCart;
  window.updateCartUI = updateCartUI;

  function updateWishlistUI() {
    const wishlist = getWishlist();
    document.querySelectorAll('.wishlist-count-badge').forEach(el => {
      el.textContent = wishlist.length;
      el.style.display = wishlist.length > 0 ? 'flex' : 'none';
    });

    // Highlight wishlist icons in cards
    document.querySelectorAll('[data-wishlist-id]').forEach(btn => {
      const id = parseInt(btn.getAttribute('data-wishlist-id'), 10);
      const icon = btn.querySelector('i');
      if (icon) {
        if (wishlist.includes(id)) {
          icon.className = 'bi bi-heart-fill text-danger';
          btn.setAttribute('title', 'Remove from Wishlist');
        } else {
          icon.className = 'bi bi-heart';
          btn.setAttribute('title', 'Add to Wishlist');
        }
      }
    });

    // Ensure all navbar wishlist buttons link to wishlist.html
    document.querySelectorAll('a[title="Saved Wishlist"], a:has(.wishlist-count-badge)').forEach(btn => {
      btn.setAttribute('href', 'wishlist.html');
    });
  }

  window.getWishlist = getWishlist;
  window.saveWishlist = saveWishlist;
  window.updateWishlistUI = updateWishlistUI;

  // 5. Toast Notification Engine
  function showToast(title, message, iconClass = 'bi-check-circle-fill') {
    let container = document.querySelector('.toast-container');
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = 'custom-toast';
    toast.innerHTML = `
      <i class="bi ${iconClass} fs-4 text-terracotta"></i>
      <div class="flex-grow-1">
        <div class="fw-bold small text-heading">${title}</div>
        <div class="small text-muted">${message}</div>
      </div>
      <button type="button" class="btn-close ms-2" style="font-size: 0.75rem;" onclick="this.parentElement.remove()"></button>
    `;

    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(50px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 4000);
  }
  window.showToast = showToast;

  // Initialize on DOM load
  document.addEventListener('DOMContentLoaded', () => {
    updateCartUI();
    updateWishlistUI();
  });
})();
