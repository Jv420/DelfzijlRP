import { db, requireKey, send } from './_db.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') return send(res, 405, { ok: false, error: 'method not allowed' });
  if (!requireKey(req)) return send(res, 401, { ok: false, error: 'unauthorized' });

  const { identifier, playerName, amount, account } = req.body || {};
  const cleanAmount = Number(amount || 0);
  const cleanAccount = account === 'cash' ? 'cash' : 'bank';
  if (!identifier || !playerName || cleanAmount <= 0) return send(res, 400, { ok: false, error: 'invalid data' });

  let conn;
  try {
    conn = await db();
    const payload = JSON.stringify({ amount: cleanAmount, account: cleanAccount });
    const [result] = await conn.execute(
      "INSERT INTO delfzijlrp_fanta_queue (identifier, player_name, reward_type, reward_data, status, created_by) VALUES (?, ?, ?, ?, ?, ?)",
      [identifier, playerName, 'money', payload, 'pending', 'fanta-web']
    );
    send(res, 200, { ok: true, queue_id: result.insertId, status: 'pending' });
  } catch (err) {
    send(res, 500, { ok: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
}
