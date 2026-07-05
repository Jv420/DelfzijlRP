const $ = (id) => document.getElementById(id);
const logBox = $('logBox');
const statusBox = $('statusBox');

function log(msg) {
  logBox.textContent = `[${new Date().toLocaleTimeString()}] ${msg}\n` + logBox.textContent;
}

function settings() {
  return {
    url: localStorage.getItem('drcc_api_url') || '',
    key: localStorage.getItem('drcc_api_key') || ''
  };
}

async function api(path, options = {}) {
  const s = settings();
  if (!s.url || !s.key) throw new Error('Vul eerst API URL en API key in.');
  const res = await fetch(s.url.replace(/\/$/, '') + path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'x-drcc-key': s.key,
      ...(options.headers || {})
    }
  });
  const text = await res.text();
  try { return JSON.parse(text); } catch { return { ok: res.ok, text }; }
}

$('apiUrl').value = localStorage.getItem('drcc_api_url') || '';
$('apiKey').value = localStorage.getItem('drcc_api_key') || '';

$('saveSettings').onclick = () => {
  localStorage.setItem('drcc_api_url', $('apiUrl').value.trim());
  localStorage.setItem('drcc_api_key', $('apiKey').value.trim());
  log('Instellingen opgeslagen.');
};

$('loadStatus').onclick = async () => {
  try {
    const data = await api('/status');
    statusBox.textContent = JSON.stringify(data, null, 2);
    log('Status opgehaald.');
  } catch (e) { log('Fout: ' + e.message); }
};

$('sendAnnounce').onclick = async () => {
  try {
    const message = $('announceText').value.trim();
    const data = await api('/announce', { method: 'POST', body: JSON.stringify({ message }) });
    log('Stadsbericht verstuurd: ' + JSON.stringify(data));
  } catch (e) { log('Fout: ' + e.message); }
};

$('sendMoney').onclick = async () => {
  try {
    const body = {
      targetId: Number($('moneyTarget').value),
      account: $('moneyAccount').value,
      amount: Number($('moneyAmount').value)
    };
    const data = await api('/gift/money', { method: 'POST', body: JSON.stringify(body) });
    log('Geldactie: ' + JSON.stringify(data));
  } catch (e) { log('Fout: ' + e.message); }
};
