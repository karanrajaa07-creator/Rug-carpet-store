/**
 * RUG & CARPET STORE - ADMIN DASHBOARD CONTROLLER
 * Handles admin charts (Chart.js), mobile sidebar toggles, and mock CRUD interactions.
 */

(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', () => {

    // 1. MOBILE SIDEBAR TOGGLE
    const sidebar = document.querySelector('.admin-sidebar');
    const toggleBtn = document.getElementById('adminSidebarToggle');
    let backdrop = document.querySelector('.admin-sidebar-backdrop');

    if (!backdrop) {
      backdrop = document.createElement('div');
      backdrop.className = 'admin-sidebar-backdrop';
      document.body.appendChild(backdrop);
    }

    if (toggleBtn && sidebar) {
      toggleBtn.addEventListener('click', () => {
        sidebar.classList.toggle('show');
        backdrop.classList.toggle('show');
      });

      backdrop.addEventListener('click', () => {
        sidebar.classList.remove('show');
        backdrop.classList.remove('show');
      });
    }

    // 2. CHART.JS CONFIGURATION & THEME AWARENESS
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    const gridColor = isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.06)';
    const textColor = isDark ? '#A8A097' : '#726A62';

    // Revenue Overview Chart (admin/index.html & admin/analytics.html)
    const revenueCanvas = document.getElementById('revenueChart');
    if (revenueCanvas && window.Chart) {
      new Chart(revenueCanvas, {
        type: 'line',
        data: {
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
          datasets: [
            {
              label: '2026 Revenue ($)',
              data: [38500, 42000, 49800, 56000, 61200, 69000, 78500, 84000, 92000, 105000, 118000, 135000],
              borderColor: '#C26D53',
              backgroundColor: 'rgba(194, 109, 83, 0.12)',
              fill: true,
              tension: 0.4,
              borderWidth: 3,
              pointBackgroundColor: '#C26D53',
              pointRadius: 4
            },
            {
              label: '2025 Revenue ($)',
              data: [26000, 31000, 35000, 41000, 43000, 48000, 52000, 57000, 63000, 69000, 78000, 89000],
              borderColor: '#D8C5B4',
              backgroundColor: 'transparent',
              borderDash: [5, 5],
              tension: 0.4,
              borderWidth: 2,
              pointRadius: 0
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              labels: { color: textColor, font: { family: 'Plus Jakarta Sans' } }
            }
          },
          scales: {
            x: {
              grid: { color: gridColor },
              ticks: { color: textColor }
            },
            y: {
              grid: { color: gridColor },
              ticks: {
                color: textColor,
                callback: function (val) { return '$' + (val / 1000) + 'k'; }
              }
            }
          }
        }
      });
    }

    // Orders Bar Chart
    const ordersCanvas = document.getElementById('ordersChart');
    if (ordersCanvas && window.Chart) {
      new Chart(ordersCanvas, {
        type: 'bar',
        data: {
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          datasets: [{
            label: 'Orders',
            data: [24, 38, 29, 45, 52, 68, 74],
            backgroundColor: '#C5A880',
            borderRadius: 6
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false }
          },
          scales: {
            x: { grid: { display: false }, ticks: { color: textColor } },
            y: { grid: { color: gridColor }, ticks: { color: textColor } }
          }
        }
      });
    }

    // Material Distribution Doughnut Chart (admin/analytics.html)
    const materialCanvas = document.getElementById('materialDistributionChart');
    if (materialCanvas && window.Chart) {
      new Chart(materialCanvas, {
        type: 'doughnut',
        data: {
          labels: ['Pure Wool (42%)', 'Mulberry Silk (28%)', 'Organic Jute (18%)', 'Cotton & Linen (12%)'],
          datasets: [{
            data: [42, 28, 18, 12],
            backgroundColor: ['#C26D53', '#C5A880', '#D8C5B4', '#524136'],
            borderWidth: 0
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom',
              labels: { color: textColor, boxWidth: 12, padding: 15 }
            }
          },
          cutout: '70%'
        }
      });
    }

    // 3. ADMIN MOCK ACTIONS (Appointments, Orders, Users)
    window.updateAppointmentStatus = function (btn, newStatus) {
      const row = btn.closest('tr');
      const badge = row.querySelector('.status-badge');
      if (badge) {
        if (newStatus === 'Approved') {
          badge.className = 'status-badge badge bg-success';
          badge.textContent = 'Approved';
        } else if (newStatus === 'Rejected') {
          badge.className = 'status-badge badge bg-danger';
          badge.textContent = 'Declined';
        }
      }
      if (window.showToast) {
        window.showToast('Appointment Updated', `Booking has been marked as ${newStatus}.`, 'bi-calendar-check');
      }
    };

    window.updateOrderStatus = function (selectEl) {
      const status = selectEl.value;
      if (window.showToast) {
        window.showToast('Order Status Updated', `Order marked as "${status}". Customer notified.`, 'bi-box-seam');
      }
    };

    window.deleteTableRow = function (btn, itemName) {
      if (confirm(`Are you sure you want to delete ${itemName}?`)) {
        const row = btn.closest('tr');
        if (row) {
          row.style.opacity = '0';
          setTimeout(() => row.remove(), 250);
        }
        if (window.showToast) {
          window.showToast('Record Deleted', `${itemName} has been permanently removed.`, 'bi-trash');
        }
      }
    };

    window.sendAdminReply = function (event) {
      event.preventDefault();
      const modalEl = document.getElementById('replyMessageModal');
      if (modalEl && window.bootstrap) {
        bootstrap.Modal.getInstance(modalEl).hide();
      }
      if (window.showToast) {
        window.showToast('Reply Dispatched', 'Your email response has been transmitted to the client.', 'bi-send-check');
      }
    };

  });
})();
