const switcher = document.querySelector('.lang-switcher');

function setLang(lang) {
  document.documentElement.lang = lang;
  localStorage.setItem('lang', lang);
  switcher.querySelectorAll('button').forEach(btn => {
    btn.setAttribute('aria-current', btn.dataset.lang === lang ? 'true' : 'false');
  });
}

switcher.addEventListener('click', (e) => {
  const btn = e.target.closest('button[data-lang]');
  if (btn) setLang(btn.dataset.lang);
});

setLang(localStorage.getItem('lang') || 'fr');
