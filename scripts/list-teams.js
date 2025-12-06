#!/usr/bin/env node
require('dotenv').config();
const { Client } = require('pg');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

async function listTeams() {
  const client = new Client(dbConfig);
  await client.connect();
  const res = await client.query('SELECT id, name, division_id FROM teams ORDER BY name');
  console.log('Teams:');
  res.rows.forEach(r => console.log(`${r.id} | ${r.name}`));
  await client.end();
}

listTeams();
