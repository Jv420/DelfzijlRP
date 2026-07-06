import { db, requireKey, send } from './_db.js';

export default async function handler(req, res) {
  if (req.method !== 'POST') return send(res, 405, { ok: false, error: 'method not allowed' });
  if (!requireKey(req)) return send(res, 401, { ok: false, error: 'unauthorized' });

  const { identifier, playerName, item, count } = req.body || {};
  const cleanCount = Number(count || 1);
  if (!identifier || !playerName || !item || cleanCount < 1) return send(res, 400, { ok: false, error: 'invalid data' });

  let conn;
  try {
    conn = await db();
    const payload = JSON.stringify({ item, count: cleanCount });
    const [result] = await conn.execute(
      "INSERT INTO delfzijlrp_fanta_queue (identifier, player_name, reward_type, reward_data, status, created_by) VALUES (?, ?, ?, ?, ?, ?)",
      [identifier, playerName, 'item', payload, 'pending', 'fanta-web']
    );
    send(res, 200, { ok: true, queue_id: result.insertId, status: 'pending' });
  } catch (err) {
    send(res, 500, { ok: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
}
