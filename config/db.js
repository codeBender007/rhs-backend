import sql from "mssql";
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import path from "path";

// 1. Force load .env from the project root regardless of how or where PM2 starts the process
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, "../.env") });
dotenv.config(); // Fallback to process.env (system environment / PM2 ecosystem)

// 2. Parse MSSQL connection parameters cleanly
const dbServer = process.env.DB_SERVER ? process.env.DB_SERVER.trim() : "localhost";
const dbPort = parseInt(process.env.DB_PORT || "1433", 10);
const dbDatabase = process.env.DB_NAME ? process.env.DB_NAME.trim() : "rhs";
const dbUser = process.env.DB_USER ? process.env.DB_USER.trim() : "sa";
const dbPassword = process.env.DB_PASSWORD ? process.env.DB_PASSWORD.trim() : "";

// CRITICAL FOR REMOTE VPS & PM2 DEPLOYMENTS:
// When connecting via IP (e.g. 31.97.229.146) or specifying a TCP port (e.g. 1433),
// NEVER pass `options.instanceName` (e.g. SQLEXPRESS). 
// In tedious, passing instanceName forces it to query the SQL Server Browser on UDP port 1434
// to look up a dynamic port. On remote hosts and cloud firewalls, UDP 1434 is blocked,
// causing tedious to hang and crash with 'ETIMEOUT (Failed to connect in 15000ms)'.
const isIp = /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/.test(dbServer);
const instanceName = (!isIp && process.env.DB_INSTANCE && !process.env.DB_PORT) 
    ? process.env.DB_INSTANCE.trim() 
    : undefined;

const options = {
    encrypt: process.env.DB_ENCRYPT === "true", // false by default for standard remote MSSQL
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERT !== "false", // true to allow self-signed / cloud certificates
    enableArithAbort: true,
    connectTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT || "30000", 10), // 30s timeout
    requestTimeout: parseInt(process.env.DB_REQUEST_TIMEOUT || "30000", 10),
};

if (instanceName) {
    options.instanceName = instanceName;
}

const config = {
    user: dbUser,
    password: dbPassword,
    server: dbServer,
    port: dbPort,
    database: dbDatabase,
    options,
    pool: {
        max: parseInt(process.env.DB_POOL_MAX || "10", 10),
        min: parseInt(process.env.DB_POOL_MIN || "0", 10),
        idleTimeoutMillis: parseInt(process.env.DB_POOL_IDLE_TIMEOUT || "30000", 10),
    },
};

// Singleton connection pool management
let poolPromise = null;

export async function getPool() {
    if (!poolPromise) {
        poolPromise = new sql.ConnectionPool(config)
            .connect()
            .then((pool) => {
                console.log(`[MSSQL] Successfully connected to ${dbServer}:${dbPort}/${dbDatabase}`);

                // Handle pool-level network drops
                pool.on("error", (err) => {
                    console.error("[MSSQL] Unexpected Connection Pool Error:", err.message);
                    poolPromise = null; // Reset to allow automatic re-connection
                });

                return pool;
            })
            .catch((error) => {
                poolPromise = null;
                console.error("=================================================");
                console.error("[MSSQL] DATABASE CONNECTION FAILED!");
                console.error(`Target Server:   ${dbServer}:${dbPort}`);
                console.error(`Target Database: ${dbDatabase}`);
                console.error(`User:            ${dbUser}`);
                console.error(`Error Code:      ${error.code || "UNKNOWN"}`);
                console.error(`Error Message:   ${error.message}`);
                console.error("=================================================");
                throw error;
            });
    }
    return poolPromise;
}

// Export default pool promise for backward-compatibility with all existing models
const db = getPool();

export { sql, db };
export default db;
