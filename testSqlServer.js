import dotenv from "dotenv";
import sql from "mssql";

dotenv.config();

const dbServer = process.env.DB_SERVER ? process.env.DB_SERVER.trim() : "localhost";
const dbPort = parseInt(process.env.DB_PORT || "1433", 10);
const dbDatabase = process.env.DB_NAME ? process.env.DB_NAME.trim() : "rhs";
const dbUser = process.env.DB_USER ? process.env.DB_USER.trim() : "sa";
const dbPassword = process.env.DB_PASSWORD ? process.env.DB_PASSWORD.trim() : "";

const config = {
    user: dbUser,
    password: dbPassword,
    server: dbServer,
    port: dbPort,
    database: dbDatabase,
    options: {
        encrypt: process.env.DB_ENCRYPT === "true",
        trustServerCertificate: true,
        connectTimeout: 15000,
    },
};

console.log(`Attempting connection to ${dbServer}:${dbPort} [DB: ${dbDatabase}] as user '${dbUser}'...`);

try {
    const pool = await sql.connect(config);

    const result = await pool.request().query(
        "SELECT DB_NAME() AS databaseName, @@SERVERNAME AS serverName, @@VERSION AS version"
    );

    console.log("=========================================");
    console.log("SQL Server connection SUCCESSFUL!");
    console.log("Database:", result.recordset[0].databaseName);
    console.log("Server Name:", result.recordset[0].serverName);
    console.log("=========================================");

    await pool.close();
} catch (error) {
    console.error("=========================================");
    console.error("SQL Server connection FAILED!");
    console.error("Error Code:", error.code);
    console.error("Error Message:", error.message);
    console.error("=========================================");
    process.exitCode = 1;
}
