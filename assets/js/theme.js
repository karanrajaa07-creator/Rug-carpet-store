/**
 * RUG & CARPET STORE - THEME & RTL CONTROLLER
 * Manages Dark Mode and RTL switching with localStorage persistence
 */

(function () {
  'use strict';

  const THEME_KEY = 'rug_store_theme';
  const DIR_KEY = 'rug_store_direction';

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
    const savedDir = localStorage.getItem(DIR_KEY);
    if (savedDir) {
      document.documentElement.setAttribute('dir', savedDir);
      updateRtlBadge(savedDir);
    }
  }

  // 4. Toggle RTL function
  window.toggleRTL = function () {
    const currentDir = document.documentElement.getAttribute('dir') || 'ltr';
    const newDir = currentDir === 'rtl' ? 'ltr' : 'rtl';

    document.documentElement.setAttribute('dir', newDir);
    localStorage.setItem(DIR_KEY, newDir);
    updateRtlBadge(newDir);
  };

  function updateRtlBadge(dir) {
    const labels = document.querySelectorAll('.rtl-toggle-text');
    labels.forEach(el => {
      el.textContent = dir === 'rtl' ? 'LTR' : 'RTL';
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
