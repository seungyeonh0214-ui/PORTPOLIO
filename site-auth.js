// 모든 페이지 공통: Supabase 연결을 만들고, 관리자로 로그인된 상태면 상단 메뉴에 "예약하기 관리" 탭을 붙입니다.
(function () {
  var cfg = window.SUPABASE_CONFIG || {};
  var configured = /^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(cfg.url || '') && !!cfg.anonKey && cfg.anonKey.indexOf('YOUR_') !== 0;
  window.db = configured && window.supabase ? window.supabase.createClient(cfg.url, cfg.anonKey) : null;
  if (!window.db) return;

  var style = document.createElement('style');
  style.textContent =
    '.nav-links a.admin-tab{white-space:nowrap;padding:.25rem .6rem;border:1px solid currentColor;border-radius:99px}' +
    '.nav-links a.admin-tab::after{display:none}' +
    '@media (max-width:640px){.nav.has-admin .nav-links a:not(.admin-tab):not([href$="location.html"]){display:none}}';
  document.head.appendChild(style);

  function syncNav(session) {
    var nav = document.querySelector('.nav'), links = document.querySelector('.nav-links');
    if (!nav || !links) return;
    var tab = links.querySelector('.admin-tab');
    if (session && !tab) {
      tab = document.createElement('a');
      tab.className = 'admin-tab';
      tab.href = 'admin.html';
      tab.textContent = '예약하기 관리';
      if (/admin\.html$/.test(location.pathname)) tab.setAttribute('aria-current', 'page');
      links.appendChild(tab);
    } else if (!session && tab) {
      tab.remove();
    }
    nav.classList.toggle('has-admin', !!session);
  }

  window.db.auth.getSession().then(function (res) { syncNav(res.data.session); });
  window.db.auth.onAuthStateChange(function (_event, session) { syncNav(session); });
})();
