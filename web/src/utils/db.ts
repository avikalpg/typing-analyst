import { Pool } from 'pg';

const conn = new Pool({
	user: process.env.POSTGRES_USER,
	password: process.env.POSTGRES_PASSWORD,
	host: process.env.POSTGRES_HOST,
	port: parseInt(process.env.POSTGRES_PORT ?? "0"),
	database: process.env.POSTGRES_DATABASE,
	max: 20,
	idleTimeoutMillis: 30000,
	connectionTimeoutMillis: 2000,
})

export default conn;