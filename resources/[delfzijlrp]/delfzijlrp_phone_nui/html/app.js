let phoneData = null;

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'delfzijlrp_phone_nui';
const phone = document.getElementById('phone');
const apps = document.getElementById('apps');

function post(name, data = {}) {
    return fetch(`https://${resource}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    });
}

function setView(view) {
    document.querySelectorAll('.view').forEach(el => el.classList.remove('active'));
    document.getElementById(view)?.classList.add('active');
}

function money(value) {
    return `€${Number(value || 0).toLocaleString('nl-NL')}`;
}

function renderApps() {
    apps.innerHTML = '';
    (phoneData.apps || []).forEach(app => {
        const button = document.createElement('button');
        button.className = 'app';
        button.innerHTML = `<span class="icon">${app.icon}</span><span class="label">${app.label}</span>`;
        button.addEventListener('click', () => {
            if (app.id === 'identity' || app.id === 'bank') return setView(app.id);
            if (app.command) post('runCommand', { command: app.command });
        });
        apps.appendChild(button);
    });
}

function renderIdentity() {
    const p = phoneData.profile;
    const card = document.getElementById('identityCard');
    if (!p) {
        card.innerHTML = 'Geen Delfzijl ID gevonden. Ga naar het gemeentehuis.';
        return;
    }
    card.innerHTML = `
        <strong>${p.firstname} ${p.lastname}</strong><br>
        Delfzijl ID: ${p.delfzijl_id}<br>
        Geboren: ${p.dateofbirth}<br>
        Nationaliteit: ${p.nationality || 'Nederlands'}<br>
        Geboorteplaats: ${p.birthplace || 'Delfzijl'}
    `;
}

function renderBank() {
    const b = phoneData.bankAccount;
    const card = document.getElementById('bankCard');
    card.innerHTML = `
        <strong>${b?.account_name || phoneData.player.name}</strong><br>
        IBAN: ${b?.iban || 'Geen IBAN'}<br>
        Bank: ${money(phoneData.player.bank)}<br>
        Contant: ${money(phoneData.player.cash)}
    `;

    const list = document.getElementById('transactions');
    list.innerHTML = '';
    (phoneData.transactions || []).forEach(tx => {
        const item = document.createElement('div');
        item.className = 'item';
        item.innerHTML = `<strong>${tx.type}</strong> ${money(tx.amount)}<br>${tx.description || ''}`;
        list.appendChild(item);
    });
    if (!phoneData.transactions || phoneData.transactions.length === 0) {
        list.innerHTML = '<div class="item">Geen transacties</div>';
    }
}

function render(data) {
    phoneData = data;
    document.getElementById('welcome').textContent = `Welkom, ${data.profile?.firstname || data.player.name}`;
    document.getElementById('iban').textContent = data.bankAccount?.iban || 'Geen IBAN gevonden';
    document.getElementById('accent').value = data.settings?.accent || 'yellow';
    document.getElementById('wallpaper').value = data.settings?.wallpaper || 'delfzijl';
    document.body.className = `accent-${data.settings?.accent || 'yellow'}`;
    renderApps();
    renderIdentity();
    renderBank();
}

window.addEventListener('message', event => {
    const payload = event.data;
    if (payload.action === 'setVisible') {
        phone.classList.toggle('hidden', !payload.visible);
    }
    if (payload.action === 'setData') {
        render(payload.data);
    }
});

document.querySelectorAll('[data-view]').forEach(btn => {
    btn.addEventListener('click', () => setView(btn.dataset.view));
});

document.querySelectorAll('[data-command]').forEach(btn => {
    btn.addEventListener('click', () => post('runCommand', { command: btn.dataset.command }));
});

document.getElementById('saveSettings').addEventListener('click', () => {
    const accent = document.getElementById('accent').value;
    const wallpaper = document.getElementById('wallpaper').value;
    document.body.className = `accent-${accent}`;
    post('saveSettings', { accent, wallpaper });
});

document.addEventListener('keydown', event => {
    if (event.key === 'Escape') post('close');
});

setInterval(() => {
    const now = new Date();
    document.getElementById('time').textContent = now.toLocaleTimeString('nl-NL', { hour: '2-digit', minute: '2-digit' });
}, 1000);
