const $ = (id) => document.getElementById(id);
const logBox = $('logBox');
const statusBox = $('statusBox');

function log(msg) {
  if (!logBox) return;
  logBox.textContent = '[' + new Date().toLocaleTimeString() + '] ' + msg + '\n' + logBox.textContent;
}

function getSettings() {
  return {
    url: localStorage.getItem('drcc_api_url') || '',
    key: localStorage.getItem('drcc_api_key') || ''
  };
}

async function api(path, options = {}) {
  const s = getSettings();
  if (!s.url || !s.key) throw new Error('Vul eerst API URL en API key in.');
  const res = await fetch(s.url.replace(/\/$/, '') + path, {
    method: options.method || 'GET',
    body: options.body,
    headers: {
      'Content-Type': 'application/json',
      'x-drcc-key': s.key
    }
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

if ($('apiUrl')) $('apiUrl').value = localStorage.getItem('drcc_api_url') || '';
if ($('apiKey')) $('apiKey').value = localStorage.getItem('drcc_api_key') || '';

if ($('saveSettings')) $('saveSettings').addEventListener('click', () => {
  localStorage.setItem('drcc_api_url', $('apiUrl').value.trim());
  localStorage.setItem('drcc_api_key', $('apiKey').value.trim());
  log('Instellingen opgeslagen.');
});

function renderPlayers(list) {
  const box = $('playersList');
  if (!box) return;
  if (!list || list.length === 0) {
    box.textContent = 'Geen spelers online of status nog niet geladen.';
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
    if ($('statEsx')) $('statEsx').textContent = data.resources?.es_extended || '-';
    if ($('statInv')) $('statInv').textContent = data.resources?.ox_inventory || '-';
    renderPlayers(data.players || []);
    log('Status opgehaald.');
  } catch (e) {
    log('Fout status: ' + e.message);
  }
}

if ($('loadStatus')) $('loadStatus').addEventListener('click', loadStatus);
if ($('quickStatus')) $('quickStatus').addEventListener('click', loadStatus);
if ($('refreshPlayers')) $('refreshPlayers').addEventListener('click', loadStatus);

if ($('sendAnnounce')) $('sendAnnounce').addEventListener('click', async () => {
  try {
    const message = $('announceText').value.trim();
    const data = await api('/announce', { method: 'POST', body: JSON.stringify({ message }) });
    log('Stadsbericht verstuurd: ' + JSON.stringify(data));
  } catch (e) {
    log('Fout bericht: ' + e.message);
  }
});

['sendMoney','sendItem','sendCar','setWeather','setTime','startGiveaway'].forEach((id) => {
  const el = $(id);
  if (el) el.addEventListener('click', () => log(id + ' staat klaar in de UI. API-koppeling volgt veilig via de server.'));
});

document.querySelectorAll('.eventBtn').forEach((btn) => btn.addEventListener('click', () => log('Event voorbereid: ' + btn.textContent)));
log('Fanta Control Center geladen.');
