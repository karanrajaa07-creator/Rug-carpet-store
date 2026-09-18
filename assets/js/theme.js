/**
 * RUG & CARPET STORE - THEME & RTL CONTROLLER
 * Manages Dark Mode and RTL switching with localStorage persistence
 */

(function () {
  'use strict';

  const THEME_KEY = 'rug_store_theme';
  const DIR_KEY = 'rug_store_direction_v2';

  // 1. Initialize Theme from localStorage or system preference
  function initTheme() {
    const savedTheme = localStorage.getItem(THEME_KEY);
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const activeTheme = savedTheme ? savedTheme : (prefersDark ? 'dark' : 'light');

    document.documentElement.setAttribute('data-theme', activeTheme);
    updateThemeIcon(activeTheme);
  }

  // 2. Toggle Theme function
  window.toggleTheme = function () {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem(THEME_KEY, newTheme);
    updateThemeIcon(newTheme);

    // Notify any charts or UI listeners
    window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: newTheme } }));
  };

  function updateThemeIcon(theme) {
    const icons = document.querySelectorAll('.theme-toggle-icon');
    icons.forEach(icon => {
      if (theme === 'dark') {
        icon.classList.remove('bi-moon', 'bi-moon-stars');
        icon.classList.add('bi-sun');
      } else {
        icon.classList.remove('bi-sun');
        icon.classList.add('bi-moon-stars');
      }
    });
  }

  // 3. Initialize Direction (RTL / LTR)
  function initDirection() {
    // Clear legacy stuck rtl value if present
    if (localStorage.getItem('rug_store_direction')) {
      localStorage.removeItem('rug_store_direction');
    }

    const savedDir = localStorage.getItem(DIR_KEY) || 'ltr';
    document.documentElement.setAttribute('dir', savedDir);
    updateRtlBadge(savedDir);
  }

  // 4. Toggle RTL function
  window.toggleRTL = function () {
    const currentDir = document.documentElement.getAttribute('dir') || 'ltr';
    const newDir = currentDir === 'rtl' ? 'ltr' : 'rtl';

    document.documentElement.setAttribute('dir', newDir);
    localStorage.setItem(DIR_KEY, newDir);
    updateRtlBadge(newDir);

    window.dispatchEvent(new CustomEvent('directionChanged', { detail: { direction: newDir } }));
  };

  function updateRtlBadge(dir) {
    const labels = document.querySelectorAll('.rtl-toggle-text');
    labels.forEach(el => {
      // In LTR mode, indicate 'LTR'; in RTL mode, indicate 'RTL'
      el.textContent = dir === 'rtl' ? 'RTL' : 'LTR';
    });

    const rtlButtons = document.querySelectorAll('[data-action="toggle-rtl"]');
    rtlButtons.forEach(btn => {
      if (dir === 'rtl') {
        btn.setAttribute('title', 'Current layout: RTL (Right-to-Left). Click to switch to LTR');
        btn.setAttribute('aria-label', 'Switch to Left-to-Right layout');
      } else {
        btn.setAttribute('title', 'Current layout: LTR (Left-to-Right). Click to switch to RTL');
        btn.setAttribute('aria-label', 'Switch to Right-to-Left layout');
      }
    });
  }

  // Run on initial script load
  initTheme();
  initDirection();

  // Listen for DOM ready
  document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initDirection();

    // Bind event listeners to theme toggles if present
    document.querySelectorAll('[data-action="toggle-theme"]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        window.toggleTheme();
      });
    });

    // Bind event listeners to RTL toggles if present
    document.querySelectorAll('[data-action="toggle-rtl"]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        window.toggleRTL();
      });
    });
  });
})();
