import "dotenv/config";
import db from "../config/db.js";

/**
 * Database Migration Script: Create Blogs Table in MSSQL
 */
async function createBlogsTable() {
    try {
        const pool = await db;
        const query = `
            IF OBJECT_ID(N'dbo.blogs', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.blogs (
                    id INT IDENTITY(1,1) NOT NULL,
                    title NVARCHAR(255) NOT NULL,
                    slug NVARCHAR(255) NOT NULL,
                    thumbnail_url NVARCHAR(MAX) NULL,
                    thumbnail_public_id NVARCHAR(255) NULL,
                    category NVARCHAR(255) NULL,
                    excerpt NVARCHAR(MAX) NOT NULL,
                    article_subtitle NVARCHAR(MAX) NULL,
                    key_takeaways NVARCHAR(MAX) NULL,
                    article_content NVARCHAR(MAX) NULL,
                    article_sections NVARCHAR(MAX) NULL,
                    benchmark_specs NVARCHAR(MAX) NULL,
                    enquiry_cta NVARCHAR(MAX) NULL,
                    author_name NVARCHAR(255) NULL,
                    author_role NVARCHAR(255) NULL,
                    author_avatar_url NVARCHAR(MAX) NULL,
                    author_avatar_public_id NVARCHAR(255) NULL,
                    published_at DATETIME2(7) NULL,
                    reading_time NVARCHAR(100) NULL,
                    read_count INT NOT NULL CONSTRAINT DF_blogs_read_count DEFAULT 0,
                    is_featured BIT NOT NULL CONSTRAINT DF_blogs_is_featured DEFAULT 0,
                    is_active BIT NOT NULL CONSTRAINT DF_blogs_is_active DEFAULT 0,
                    created_at DATETIME2(7) NOT NULL CONSTRAINT DF_blogs_created_at DEFAULT SYSDATETIME(),
                    updated_at DATETIME2(7) NULL,
                    deleted_at DATETIME2(7) NULL,
                    CONSTRAINT PK_blogs PRIMARY KEY CLUSTERED (id ASC),
                    CONSTRAINT UQ_blogs_slug UNIQUE NONCLUSTERED (slug ASC)
                );

                CREATE NONCLUSTERED INDEX idx_blogs_deleted_active
                    ON dbo.blogs (deleted_at, is_active)
                    INCLUDE (is_featured, created_at, id, title, slug, category);

                CREATE NONCLUSTERED INDEX idx_blogs_featured_created
                    ON dbo.blogs (is_featured DESC, created_at DESC, id DESC);

                PRINT 'Blogs table created successfully.';
            END
            ELSE
            BEGIN
                PRINT 'Blogs table already exists.';
            END
        `;

        await pool.request().query(query);
        console.log("Blogs table verified successfully in MSSQL.");
    } catch (error) {
        console.error("Failed to create blogs table:", error.message);
        process.exitCode = 1;
    }
}

createBlogsTable();
