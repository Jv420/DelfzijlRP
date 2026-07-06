const $ = (id) => document.getElementById(id);
const logBox = $('logBox');
const statusBox = $('statusBox');

function log(msg) {
  if (!logBox) return;
  logBox.textContent = '[' + new Date().toLocaleTimeString() + '] ' + msg + '\n' + logBox.textContent;
}

function getSettings() {
  return {
    url: localStorage.getItem('drcc_api_url') || '/api',
    key: localStorage.getItem('drcc_api_key') || ''
  };
}

async function api(path, options = {}) {
  const s = getSettings();
  if (!s.key) throw new Error('Vul eerst API key in.');
  const res = await fetch(s.url.replace(/\/$/, '') + path, {
    method: options.method || 'GET',
    body: options.body,
    headers: { 'Content-Type': 'application/json', 'x-fanta-key': s.key }
  });
  const text = await res.text();
  try { return JSON.parse(text); } catch { return { ok: res.ok, text }; }
}

function openTab(name) {
  document.querySelectorAll('.tab').forEach((btn) => btn.classList.toggle('active', btn.dataset.tab === name));
  document.querySelectorAll('.page').forEach((page) => page.classList.toggle('active', page.id === name));
}

document.querySelectorAll('.tab').forEach((btn) => btn.addEventListener('click', () => openTab(btn.dataset.tab)));
document.querySelectorAll('[data-jump]').forEach((btn) => btn.addEventListener('click', () => openTab(btn.dataset.jump)));

if ($('apiUrl')) $('apiUrl').value = localStorage.getItem('drcc_api_url') || '/api';
if ($('apiKey')) $('apiKey').value = localStorage.getItem('drcc_api_key') || '';

if ($('saveSettings')) $('saveSettings').addEventListener('click', () => {
  localStorage.setItem('drcc_api_url', $('apiUrl').value.trim() || '/api');
  localStorage.setItem('drcc_api_key', $('apiKey').value.trim());
  log('Instellingen opgeslagen.');
});

function renderPlayers(list) {
  const box = $('playersList');
  if (!box) return;
  if (!list || list.length === 0) {
    box.textContent = 'Geen live spelers via database. Gebruik queue op identifier/playerName.';
    return;
  }
  box.innerHTML = list.map((p) => '<div class="player"><div><b>' + p.name + '</b><br><small>' + (p.job || 'unknown') + '</small></div><span>ID ' + p.id + '</span></div>').join('');
}

async function loadStatus() {
  try {
    const data = await api('/status');
    if (statusBox) statusBox.textContent = JSON.stringify(data, null, 2);
    if ($('statOnline')) $('statOnline').textContent = data.online ?? '-';
    if ($('statMax')) $('statMax').textContent = data.max ?? '-';
    if ($('statEsx')) $('statEsx').textContent = data.database || '-';
    if ($('statInv')) $('statInv').textContent = data.queue ? 'queue' : '-';
    renderPlayers(data.players || []);
    log('Database status opgehaald.');
  } catch (e) { log('Fout status: ' + e.message); }
}

if ($('loadStatus')) $('loadStatus').addEventListener('click', loadStatus);
if ($('quickStatus')) $('quickStatus').addEventListener('click', loadStatus);
if ($('refreshPlayers')) $('refreshPlayers').addEventListener('click', loadStatus);

if ($('sendAnnounce')) $('sendAnnounce').addEventListener('click', () => {
  log('Stadsbericht via database API volgt later. Gebruik tijdelijk /drcc in-game.');
});

if ($('sendMoney')) $('sendMoney').addEventListener('click', async () => {
  try {
    const identifier = prompt('Plak speler identifier/license:');
    const playerName = prompt('Spelernaam voor log:');
    const body = { identifier, playerName, account: $('moneyAccount').value, amount: Number($('moneyAmount').value) };
    const data = await api('/queue-money', { method: 'POST', body: JSON.stringify(body) });
    log('Geld queue aangemaakt: ' + JSON.stringify(data));
  } catch (e) { log('Fout geld queue: ' + e.message); }
});

if ($('sendItem')) $('sendItem').addEventListener('click', async () => {
  try {
    const identifier = prompt('Plak speler identifier/license:');
    const playerName = prompt('Spelernaam voor log:');
    const body = { identifier, playerName, item: $('itemName').value.trim(), count: Number($('itemCount').value || 1) };
    const data = await api('/queue-item', { method: 'POST', body: JSON.stringify(body) });
    log('Item queue aangemaakt: ' + JSON.stringify(data));
  } catch (e) { log('Fout item queue: ' + e.message); }
});

['sendCar','setWeather','setTime','startGiveaway'].forEach((id) => {
  const el = $(id);
  if (el) el.addEventListener('click', () => log(id + ' volgt in volgende API-build.'));
});

document.querySelectorAll('.eventBtn').forEach((btn) => btn.addEventListener('click', () => log('Event voorbereid: ' + btn.textContent)));
log('Fanta Control Center geladen.');
