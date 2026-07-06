import { db, requireKey, send } from './_db.js';

export default async function handler(req, res) {
  if (!requireKey(req)) return send(res, 401, { ok: false, error: 'unauthorized' });
  let conn;
  try {
    conn = await db();
    const [queueRows] = await conn.execute("SELECT status, COUNT(*) AS total FROM delfzijlrp_fanta_queue GROUP BY status");
    const [recentRows] = await conn.execute("SELECT id, player_name, reward_type, status, created_at FROM delfzijlrp_fanta_queue ORDER BY id DESC LIMIT 10");
    send(res, 200, {
      ok: true,
      database: 'connected',
      queue: queueRows,
      recent: recentRows,
      note: 'Live spelers via MySQL komt in volgende build zodra player heartbeat actief is.'
    });
  } catch (err) {
    send(res, 500, { ok: false, error: err.message });
  } finally {
    if (conn) await conn.end();
  }
}
