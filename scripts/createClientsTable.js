import "dotenv/config";
import db from "../config/db.js";

/**
 * Database Migration Script: Create Clients Table in MSSQL
 */
async function createClientsTable() {
    try {
        const pool = await db;
        const query = `
            IF OBJECT_ID(N'dbo.clients', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.clients (
                    id INT IDENTITY(1,1) NOT NULL,
                    name NVARCHAR(255) NOT NULL,
                    logo_url NVARCHAR(MAX) NULL,
                    cloudinary_public_id NVARCHAR(255) NULL,
                    bg_theme NVARCHAR(100) NOT NULL CONSTRAINT DF_clients_bg_theme DEFAULT N'soft-blue',
                    is_active BIT NOT NULL CONSTRAINT DF_clients_is_active DEFAULT 1,
                    display_order INT NOT NULL CONSTRAINT DF_clients_display_order DEFAULT 0,
                    created_at DATETIME2(7) NOT NULL CONSTRAINT DF_clients_created_at DEFAULT SYSDATETIME(),
                    updated_at DATETIME2(7) NULL,
                    deleted_at DATETIME2(7) NULL,
                    CONSTRAINT PK_clients PRIMARY KEY CLUSTERED (id ASC)
                );

                CREATE NONCLUSTERED INDEX idx_clients_filter_order
                    ON dbo.clients (deleted_at, is_active, display_order ASC, created_at DESC);

                PRINT 'Clients table created successfully.';
            END
            ELSE
            BEGIN
                PRINT 'Clients table already exists.';
            END
        `;

        await pool.request().query(query);
        console.log("Clients table verified successfully in MSSQL.");
    } catch (error) {
        console.error("Failed to create clients table:", error.message);
        process.exitCode = 1;
    }
}

createClientsTable();
