/**
 * RUG & CARPET STORE - FORM VALIDATION & INTERACTIVE SERVICES
 * Handles Showroom Appointments, Custom Sizing Calculator, and Auth Validation.
 */

(function () {
  'use strict';

  // 1. SHOWROOM APPOINTMENT BOOKING
  window.handleShowroomBooking = function (event) {
    event.preventDefault();
    const form = event.target;
    const phoneInput = form.querySelector('#apptPhone');
    if (phoneInput) {
      const phoneVal = phoneInput.value.trim();
      const digitsOnly = phoneVal.replace(/\D/g, '');
      const hasLetters = /[a-zA-Z]/.test(phoneVal);

      if (!phoneVal || hasLetters || digitsOnly.length < 7) {
        phoneInput.setCustomValidity('Please enter a valid phone number (digits only, e.g. +1 (212) 555-0199).');
        phoneInput.classList.add('is-invalid');
        event.stopPropagation();
        form.classList.add('was-validated');
        phoneInput.focus();
        return;
      } else {
        phoneInput.setCustomValidity('');
        phoneInput.classList.remove('is-invalid');
      }
    }

    if (!form.checkValidity()) {
      event.stopPropagation();
      form.classList.add('was-validated');
      return;
    }

    const name = form.querySelector('#apptName')?.value || 'Valued Guest';
    const email = form.querySelector('#apptEmail')?.value || '';
    const phone = form.querySelector('#apptPhone')?.value || '';
    const date = form.querySelector('#apptDate')?.value || 'Upcoming Date';
    const time = form.querySelector('#apptTime')?.value || '11:00 AM';
    const guests = form.querySelector('#apptVisitors')?.value || '1 Person';
    const service = form.querySelector('#apptService')?.value || 'Bespoke Rug Consultation';

    // Generate Booking Reference
    const refCode = 'RCS-' + Math.floor(100000 + Math.random() * 900000);

    // Populate Confirmation Modal
    const refEl = document.getElementById('bookingRefCode');
    if (refEl) refEl.textContent = refCode;

    const summaryEl = document.getElementById('bookingSummaryDetails');
    if (summaryEl) {
      summaryEl.innerHTML = `
        <div class="row g-2 text-start">
          <div class="col-sm-6"><strong>Guest:</strong> ${name}</div>
          <div class="col-sm-6"><strong>Guests:</strong> ${guests}</div>
          <div class="col-sm-6"><strong>Date:</strong> ${date}</div>
          <div class="col-sm-6"><strong>Time:</strong> ${time}</div>
          <div class="col-12"><strong>Service:</strong> ${service}</div>
          <div class="col-12 text-muted small mt-2">A confirmation email and SMS appointment reminder have been dispatched to ${email || phone}.</div>
        </div>
      `;
    }

    // Show Confirmation Modal
    const modalEl = document.getElementById('bookingConfirmationModal');
    if (modalEl && window.bootstrap) {
      const modal = new bootstrap.Modal(modalEl);
      modal.show();
    }

    form.reset();
    form.classList.remove('was-validated');
    if (window.showToast) {
      window.showToast('Appointment Reserved', `We look forward to hosting you on ${date}.`, 'bi-calendar-check-fill');
    }
  };

  // 2. CONTACT FORM SUBMISSION
  window.handleContactSubmit = function (event) {
    event.preventDefault();
    const form = event.target;
    if (!form.checkValidity()) {
      event.stopPropagation();
      form.classList.add('was-validated');
      return;
    }

    if (window.showToast) {
      window.showToast('Message Received', 'Our design concierge will get in touch within 24 hours.', 'bi-envelope-check-fill');
    }
    form.reset();
    form.classList.remove('was-validated');
  };

  // 3. NEWSLETTER SUBSCRIPTION
  window.handleNewsletterSubmit = function (event) {
    event.preventDefault();
    const input = event.target.querySelector('input[type="email"]');
    if (input && input.value) {
      if (window.showToast) {
        window.showToast('Welcome to Our Circle', 'Enjoy $50 off your first bespoke handwoven rug.', 'bi-gift-fill');
      }
      input.value = '';
    }
  };

  // 4. CUSTOM RUG SIZING CALCULATOR
  window.calculateRugPrice = function () {
    const widthInput = document.getElementById('calcWidth');
    const lengthInput = document.getElementById('calcLength');
    const unitSelect = document.getElementById('calcUnit');
    const materialSelect = document.getElementById('calcMaterial');
    const shapeActive = document.querySelector('.shape-picker-btn.active')?.getAttribute('data-shape') || 'rectangular';
    const borderSelect = document.getElementById('calcBorder');

    if (!widthInput || !lengthInput) return;

    let width = parseFloat(widthInput.value) || 8;
    let length = parseFloat(lengthInput.value) || 10;
    const unit = unitSelect ? unitSelect.value : 'feet';

    // Convert to Square Feet for standardized pricing base
    let sqFeet = 0;
    if (unit === 'meters') {
      sqFeet = (width * 3.28084) * (length * 3.28084);
    } else if (unit === 'inches') {
      sqFeet = (width / 12) * (length / 12);
    } else {
      sqFeet = width * length;
    }

    // Adjust for circular or runner shape
    if (shapeActive === 'round') {
      const radius = width / 2;
      sqFeet = Math.PI * (unit === 'meters' ? radius * 3.28084 : radius) ** 2;
    }

    // Material Rate per sq ft
    let ratePerSqFt = 12.5; // Base wool
    const material = materialSelect ? materialSelect.value : 'wool';
    if (material === 'silk') ratePerSqFt = 28.0;
    if (material === 'wool-silk') ratePerSqFt = 22.0;
    if (material === 'jute') ratePerSqFt = 7.5;
    if (material === 'cotton') ratePerSqFt = 6.0;

    // Border upgrade
    let borderExtra = 0;
    if (borderSelect && borderSelect.value === 'fringe') borderExtra = 65;
    if (borderSelect && borderSelect.value === 'leather-binding') borderExtra = 110;

    const estimatedTotal = Math.round((sqFeet * ratePerSqFt) + borderExtra);

    // Update UI Displays
    const sqFtEl = document.getElementById('calcSqFtDisplay');
    if (sqFtEl) sqFtEl.textContent = `${Math.round(sqFeet)} sq ft`;

    const priceEl = document.getElementById('calcPriceDisplay');
    if (priceEl) priceEl.textContent = `$${estimatedTotal.toLocaleString()}`;

    const leadTimeEl = document.getElementById('calcLeadTimeDisplay');
    if (leadTimeEl) {
      if (material === 'silk') leadTimeEl.textContent = '8 - 12 Weeks (Hand-Knotted)';
      else if (material === 'jute') leadTimeEl.textContent = '3 - 4 Weeks (Hand-Braided)';
      else leadTimeEl.textContent = '6 - 8 Weeks (Artisan Loomed)';
    }

    // Store in global for quote modal
    window.lastCalculatedRug = {
      width, length, unit, shape: shapeActive, material, estimatedTotal, sqFeet: Math.round(sqFeet)
    };
  };

  // Shape Picker Button Handler
  window.selectRugShape = function (btn, shape) {
    document.querySelectorAll('.shape-picker-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    calculateRugPrice();
  };

  // Open Custom Quote Modal with pre-filled specs
  window.openCustomQuoteModal = function () {
    const calc = window.lastCalculatedRug || {
      width: 9, length: 12, unit: 'feet', shape: 'Rectangle', material: 'Highland New Zealand Wool', estimatedTotal: 1350, sqFeet: 108
    };

    const quoteSpecsEl = document.getElementById('quoteSpecsSummary');
    if (quoteSpecsEl) {
      const formattedPrice = typeof calc.estimatedTotal === 'number' ? calc.estimatedTotal.toLocaleString() : calc.estimatedTotal;
      const formattedShape = typeof calc.shape === 'string' ? calc.shape.charAt(0).toUpperCase() + calc.shape.slice(1) : 'Rectangle';
      quoteSpecsEl.innerHTML = `
        <div class="quote-specs-box p-3 rounded-3 mb-3 border">
          <div class="row g-2 small">
            <div class="col-6"><strong class="specs-label">Dimensions:</strong> <span class="specs-value">${calc.width} × ${calc.length} ${calc.unit}</span></div>
            <div class="col-6"><strong class="specs-label">Total Area:</strong> <span class="specs-value">${calc.sqFeet} sq ft</span></div>
            <div class="col-6"><strong class="specs-label">Shape & Material:</strong> <span class="specs-value">${formattedShape} · ${calc.material.toUpperCase()}</span></div>
            <div class="col-6"><strong class="specs-label">Est. Price:</strong> <span class="text-terracotta fw-bold fs-6">$${formattedPrice}</span></div>
          </div>
        </div>
      `;
    }

    const modalEl = document.getElementById('customQuoteModal');
    if (modalEl && window.bootstrap) {
      const modal = new bootstrap.Modal(modalEl);
      modal.show();
    }
  };

  window.handleCustomQuoteSubmit = function (event) {
    event.preventDefault();
    const modalEl = document.getElementById('customQuoteModal');
    if (modalEl && window.bootstrap) {
      bootstrap.Modal.getInstance(modalEl).hide();
    }
    if (window.showToast) {
      window.showToast('Quote Request Submitted', 'Our bespoke rug atelier will email your complimentary CAD rendering within 48 hours.', 'bi-patch-check-fill');
    }
  };

  // 5. PASSWORD VISIBILITY TOGGLER
  window.togglePasswordVisibility = function (inputId, iconEl) {
    const input = document.getElementById(inputId);
    if (!input) return;
    if (input.type === 'password') {
      input.type = 'text';
      iconEl.className = 'bi bi-eye-slash';
    } else {
      input.type = 'password';
      iconEl.className = 'bi bi-eye';
    }
  };

  // Init on Load
  document.addEventListener('DOMContentLoaded', () => {
    // Sizing calculator auto-listeners
    ['calcWidth', 'calcLength', 'calcUnit', 'calcMaterial', 'calcBorder'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.addEventListener('input', calculateRugPrice);
    });
    // Phone number inputs: strictly accept numbers & phone symbols only (block alphabets)
    const phoneInputs = document.querySelectorAll('input[type="tel"], #apptPhone, #checkoutPhone, #regPhone');
    phoneInputs.forEach(input => {
      // Prevent typing any letters (a-z, A-Z)
      input.addEventListener('keydown', (e) => {
        if (e.ctrlKey || e.metaKey || e.altKey) return;
        if (e.key && e.key.length === 1 && !/[0-9+\s()\-]/i.test(e.key)) {
          e.preventDefault();
        }
      });

      // Strip any alphabets or invalid characters immediately on input
      input.addEventListener('input', function () {
        const cleaned = this.value.replace(/[^0-9+\s()\-]/g, '');
        if (this.value !== cleaned) {
          this.value = cleaned;
        }
        if (this.id === 'apptPhone') {
          const digitsOnly = this.value.replace(/\D/g, '');
          if (/[a-zA-Z]/.test(this.value) || (this.value.length > 0 && digitsOnly.length < 7)) {
            this.setCustomValidity('Please enter a valid phone number with digits only.');
          } else {
            this.setCustomValidity('');
          }
        }
      });

      // Prevent pasting text containing alphabets without sanitization
      input.addEventListener('paste', function (e) {
        e.preventDefault();
        const clipboard = (e.clipboardData || window.clipboardData).getData('text') || '';
        const cleaned = clipboard.replace(/[^0-9+\s()\-]/g, '');
        if (document.queryCommandSupported && document.queryCommandSupported('insertText')) {
          document.execCommand('insertText', false, cleaned);
        } else {
          const start = this.selectionStart || 0;
          const end = this.selectionEnd || 0;
          this.value = this.value.substring(0, start) + cleaned + this.value.substring(end);
          this.setSelectionRange(start + cleaned.length, start + cleaned.length);
        }
      });
    });

    calculateRugPrice();
  });
})();
