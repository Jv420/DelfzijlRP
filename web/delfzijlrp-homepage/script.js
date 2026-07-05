const navToggle = document.querySelector('#navToggle');
const navLinks = document.querySelector('#navLinks');
const year = document.querySelector('#year');

if (year) year.textContent = new Date().getFullYear();

if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
}

function copyIp(button) {
  const ip = button.dataset.ip || 'play.delfzijlrp.nl';
  navigator.clipboard?.writeText(ip).then(() => {
    const old = button.textContent;
    button.textContent = 'Gekopieerd: ' + ip;
    setTimeout(() => (button.textContent = old), 1800);
  });
}

document.querySelectorAll('[data-ip]').forEach((button) => {
  button.addEventListener('click', () => copyIp(button));
});
