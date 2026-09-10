/**
 * RUG & CARPET STORE - MAIN UI CONTROLLER
 * Handles navigation, sticky header, before/after slider, stat counters, countdown timer, and tooltips.
 */

(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', () => {

    // 1. STICKY HEADER & BACK-TO-TOP BUTTON
    const header = document.querySelector('.site-header');
    const backToTopBtn = document.getElementById('backToTopBtn');

    window.addEventListener('scroll', () => {
      const scrollY = window.scrollY;
      if (header) {
        if (scrollY > 60) {
          header.classList.add('is-scrolled');
        } else {
          header.classList.remove('is-scrolled');
        }
      }

      if (backToTopBtn) {
        if (scrollY > 300) {
          backToTopBtn.classList.add('show');
        } else {
          backToTopBtn.classList.remove('show');
        }
      }
    });

    if (backToTopBtn) {
      backToTopBtn.addEventListener('click', (e) => {
        e.preventDefault();
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

    // 2. BEFORE & AFTER INTERACTION SLIDER
    const beforeAfterContainers = document.querySelectorAll('.before-after-box');
    beforeAfterContainers.forEach(container => {
      const overlay = container.querySelector('.before-after-overlay');
      const slider = container.querySelector('.before-after-slider');
      if (!overlay || !slider) return;

      let isDragging = false;

      function updateSliderPosition(clientX) {
        const rect = container.getBoundingClientRect();
        let xPos = clientX - rect.left;
        if (xPos < 0) xPos = 0;
        if (xPos > rect.width) xPos = rect.width;

        const percent = (xPos / rect.width) * 100;
        overlay.style.width = `${percent}%`;
        slider.style.left = `${percent}%`;
      }

      slider.addEventListener('mousedown', () => isDragging = true);
      window.addEventListener('mouseup', () => isDragging = false);
      window.addEventListener('mousemove', (e) => {
        if (isDragging) updateSliderPosition(e.clientX);
      });

      // Touch events for mobile
      slider.addEventListener('touchstart', () => isDragging = true);
      window.addEventListener('touchend', () => isDragging = false);
      window.addEventListener('touchmove', (e) => {
        if (isDragging && e.touches[0]) updateSliderPosition(e.touches[0].clientX);
      });
    });

    // 3. STAT COUNTERS ANIMATION
    const counterElements = document.querySelectorAll('.counter-value');
    if (counterElements.length > 0 && 'IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const el = entry.target;
            const target = parseInt(el.getAttribute('data-target'), 10) || 0;
            const duration = 1600;
            const stepTime = 20;
            const steps = duration / stepTime;
            const increment = target / steps;
            let current = 0;

            const timer = setInterval(() => {
              current += increment;
              if (current >= target) {
                el.textContent = target.toLocaleString();
                clearInterval(timer);
              } else {
                el.textContent = Math.floor(current).toLocaleString();
              }
            }, stepTime);

            obs.unobserve(el);
          }
        });
      }, { threshold: 0.5 });

      counterElements.forEach(el => observer.observe(el));
    }

    // 4. COUNTDOWN TIMER (FOR COMING SOON PAGE)
    const countdownContainer = document.getElementById('launchCountdown');
    if (countdownContainer) {
      // Set target launch 45 days into future
      const targetDate = new Date();
      targetDate.setDate(targetDate.getDate() + 45);

      function updateCountdown() {
        const now = new Date().getTime();
        const diff = targetDate.getTime() - now;

        if (diff <= 0) return;

        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        const dEl = document.getElementById('countDays');
        const hEl = document.getElementById('countHours');
        const mEl = document.getElementById('countMinutes');
        const sEl = document.getElementById('countSeconds');

        if (dEl) dEl.textContent = String(days).padStart(2, '0');
        if (hEl) hEl.textContent = String(hours).padStart(2, '0');
        if (mEl) mEl.textContent = String(minutes).padStart(2, '0');
        if (sEl) sEl.textContent = String(seconds).padStart(2, '0');
      }

      setInterval(updateCountdown, 1000);
      updateCountdown();
    }

    // 5. BOOTSTRAP TOOLTIPS INITIALIZATION
    if (window.bootstrap && bootstrap.Tooltip) {
      const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
      tooltipTriggerList.map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
    }

    // 6. SEARCH FORM DEMO
    const searchForm = document.getElementById('siteSearchForm');
    if (searchForm) {
      searchForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const query = document.getElementById('siteSearchInput')?.value.trim();
        if (query) {
          window.location.href = `products.html?search=${encodeURIComponent(query)}`;
        }
      });
    }

    // 7. DESKTOP NAV DROPDOWN CLICK NAVIGATION
    document.querySelectorAll('.navbar-nav .nav-item.dropdown > a.nav-link').forEach(link => {
      link.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (window.innerWidth >= 992 && href && href !== '#') {
          window.location.href = href;
        }
      });
    });

    // 8. FOOTER NEWSLETTER SUBSCRIPTION CONTROLLER
    const SUBSCRIBERS_STORAGE_KEY = 'atelier_rugs_subscribers';

    function getSubscribersList() {
      try {
        const stored = localStorage.getItem(SUBSCRIBERS_STORAGE_KEY);
        return stored ? JSON.parse(stored) : [];
      } catch (e) {
        return [];
      }
    }

    function saveSubscriberEmail(email) {
      const list = getSubscribersList();
      const normalized = email.toLowerCase();
      if (!list.includes(normalized)) {
        list.push(normalized);
        localStorage.setItem(SUBSCRIBERS_STORAGE_KEY, JSON.stringify(list));
      }
      localStorage.setItem('atelier_rugs_last_subscribed', normalized);
    }

    function isAlreadySubscribed(email) {
      const list = getSubscribersList();
      return list.includes(email.toLowerCase());
    }

    const newsletterForms = document.querySelectorAll('.footer-newsletter-form');
    newsletterForms.forEach(form => {
      const emailInput = form.querySelector('.footer-newsletter-input');
      const messageEl = form.querySelector('.footer-newsletter-message');
      const submitBtn = form.querySelector('.footer-newsletter-btn');

      form.addEventListener('submit', function (e) {
        e.preventDefault();
        if (!emailInput || !messageEl) return;

        const email = emailInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        messageEl.style.display = 'block';

        // Empty validation
        if (!email) {
          messageEl.className = 'footer-newsletter-message mt-2 text-danger fw-semibold';
          messageEl.innerHTML = '<i class="bi bi-exclamation-circle-fill me-1"></i> Please enter your email address.';
          emailInput.classList.add('is-invalid');
          emailInput.focus();
          return;
        }

        // Format validation
        if (!emailRegex.test(email)) {
          messageEl.className = 'footer-newsletter-message mt-2 text-danger fw-semibold';
          messageEl.innerHTML = '<i class="bi bi-exclamation-circle-fill me-1"></i> Please enter a valid email address (e.g., name@domain.com).';
          emailInput.classList.add('is-invalid');
          emailInput.focus();
          return;
        }

        emailInput.classList.remove('is-invalid');

        // Already subscribed check
        if (isAlreadySubscribed(email)) {
          messageEl.className = 'footer-newsletter-message mt-2 text-warning fw-semibold';
          messageEl.innerHTML = '<i class="bi bi-info-circle-fill me-1"></i> You’re already subscribed.';
          if (window.showToast) {
            window.showToast('Already Subscribed', 'This email is already part of the Atelier Rugs circle.', 'bi-info-circle-fill');
          }
          return;
        }

        // Successful new subscription
        saveSubscriberEmail(email);
        messageEl.className = 'footer-newsletter-message mt-2 text-success fw-semibold';
        messageEl.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i> Thank you for subscribing to Atelier Rugs.';
        emailInput.value = '';

        if (window.showToast) {
          window.showToast('Subscribed Successfully', 'Thank you for subscribing to Atelier Rugs curated stories.', 'bi-envelope-check-fill');
        }
      });
    });

    // 9. FAQ ACCORDION INTERACTION ENHANCEMENTS
    const accordionElements = document.querySelectorAll('.accordion');
    accordionElements.forEach(accordion => {
      // Synchronize .is-open class on parent accordion-item
      accordion.addEventListener('show.bs.collapse', (e) => {
        const item = e.target.closest('.accordion-item');
        if (item) item.classList.add('is-open');
      });
      accordion.addEventListener('hide.bs.collapse', (e) => {
        const item = e.target.closest('.accordion-item');
        if (item) item.classList.remove('is-open');
      });

      // Ensure entire header row triggers button click reliably
      accordion.querySelectorAll('.accordion-header').forEach(header => {
        header.style.cursor = 'pointer';
        header.addEventListener('click', (e) => {
          if (!e.target.closest('.accordion-button')) {
            const btn = header.querySelector('.accordion-button');
            if (btn) btn.click();
          }
        });
      });
    });

  });
})();
