import "dotenv/config";
import db from "../config/db.js";

/**
 * Database Migration Script: Create Testimonials Table in MSSQL
 */
async function createTestimonialsTable() {
    try {
        const pool = await db;
        const query = `
            IF OBJECT_ID(N'dbo.testimonials', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.testimonials (
                    id INT IDENTITY(1,1) NOT NULL,
                    author_name NVARCHAR(255) NOT NULL,
                    quote NVARCHAR(MAX) NOT NULL,
                    bg_theme NVARCHAR(100) NOT NULL CONSTRAINT DF_testimonials_bg_theme DEFAULT N'lavender',
                    image_url NVARCHAR(MAX) NULL,
                    cloudinary_public_id NVARCHAR(255) NULL,
                    is_active BIT NOT NULL CONSTRAINT DF_testimonials_is_active DEFAULT 1,
                    created_at DATETIME2(7) NOT NULL CONSTRAINT DF_testimonials_created_at DEFAULT SYSDATETIME(),
                    updated_at DATETIME2(7) NULL,
                    deleted_at DATETIME2(7) NULL,
                    CONSTRAINT PK_testimonials PRIMARY KEY CLUSTERED (id ASC)
                );

                CREATE NONCLUSTERED INDEX idx_testimonials_deleted_active
                    ON dbo.testimonials (deleted_at, is_active, created_at DESC)
                    INCLUDE (id, author_name, bg_theme, image_url, cloudinary_public_id, updated_at);

                PRINT 'Testimonials table created successfully.';
            END
            ELSE
            BEGIN
                PRINT 'Testimonials table already exists.';
            END
        `;

        await pool.request().query(query);
        console.log("Testimonials table verified successfully in MSSQL.");
    } catch (error) {
        console.error("Failed to create testimonials table:", error.message);
        process.exitCode = 1;
    }
}

createTestimonialsTable();
