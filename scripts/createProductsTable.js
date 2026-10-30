import "dotenv/config";
import db from "../config/db.js";

/**
 * Standalone Database Migration Script: Products
 * Accurately creates the `products` table in Microsoft SQL Server (rhs_db).
 */
async function createProductsTable() {
    let pool;
    try {
        pool = await db;

        const query = `
            IF OBJECT_ID('dbo.products', 'U') IS NULL
            BEGIN
                CREATE TABLE dbo.products (
                    id INT IDENTITY(1,1) NOT NULL,
                    name NVARCHAR(255) NOT NULL,
                    color_palette NVARCHAR(50) NOT NULL DEFAULT (N'medical-teal'),
                    image_url NVARCHAR(2048) NULL,
                    cloudinary_public_id NVARCHAR(255) NULL,
                    is_active BIT NOT NULL DEFAULT ((1)),
                    created_at DATETIME2 NULL,
                    updated_at DATETIME2 NULL,
                    deleted_at DATETIME2 NULL,
                    CONSTRAINT PK_products PRIMARY KEY CLUSTERED (id ASC)
                );

                CREATE NONCLUSTERED INDEX idx_products_deleted_active
                    ON dbo.products (deleted_at, is_active)
                    INCLUDE (id, name, color_palette, image_url, cloudinary_public_id, created_at, updated_at);
            END
        `;

        await pool.request().query(query);
        console.log("products table created or verified successfully.");
    } catch (error) {
        console.error("Failed to create products table:", error.message);
        process.exitCode = 1;
    } finally {
        if (pool && typeof pool.close === "function") {
            await pool.close();
        }
    }
}

// Export for programmatic use or run directly
export default createProductsTable;
if (process.argv[1] && process.argv[1].endsWith("createProductsTable.js")) {
    createProductsTable();
}