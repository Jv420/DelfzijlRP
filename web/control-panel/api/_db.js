import mysql from 'mysql2/promise';

export function requireKey(req) {
  const key = req.headers['x-fanta-key'] || req.headers['x-drcc-key'];
  return Boolean(key && process.env.FANTA_API_KEY && key === process.env.FANTA_API_KEY);
}

export async function db() {
  return mysql.createConnection({
    host: process.env.MYSQL_HOST,
    port: Number(process.env.MYSQL_PORT || 3306),
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    charset: 'utf8mb4'
  });
}

export function send(res, code, data) {
  res.status(code).json(data);
}
