-- =====================================================================================
-- RHS Medical Platform - Complete MSSQL Database Migration & Setup Script
-- Target Database: [rhs]
-- Engine: Microsoft SQL Server (2016+ / Azure SQL / MSSQL Express)
-- Author: Full-Stack & Database Architect
-- =====================================================================================

-- 1. Create Database if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'rhs')
BEGIN
    PRINT '>>> Database [rhs] does not exist. Creating database...';
    CREATE DATABASE [rhs];
    PRINT '>>> Database [rhs] created successfully.';
END
ELSE
BEGIN
    PRINT '>>> Database [rhs] already exists.';
END
GO

-- 2. Switch to [rhs] context
USE [rhs];
GO

PRINT '>>> Connected to active database: ' + DB_NAME();
GO

-- Ensure schema [dbo] exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo')
BEGIN
    EXEC('CREATE SCHEMA [dbo]');
END
GO

-- =====================================================================================
-- TABLE 1: [dbo].[admins]
-- Purpose: System administrator accounts for RHS Admin Portal authentication
-- Backend: models/admin.model.js, controllers/admin.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.admins', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[admins]...';
    CREATE TABLE dbo.admins (
        id INT IDENTITY(1,1) NOT NULL,
        username NVARCHAR(255) NOT NULL,
        password NVARCHAR(255) NOT NULL,
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_admins_created_at DEFAULT SYSDATETIME(),
        updated_at DATETIME2(7) NULL,
        CONSTRAINT PK_admins PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT UQ_admins_username UNIQUE NONCLUSTERED (username ASC)
    );
    PRINT 'Table [dbo].[admins] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[admins] already exists.';
END
GO

-- Default Admin Seeding (Password: admin@123 with bcrypt 10 rounds)
IF NOT EXISTS (SELECT 1 FROM dbo.admins WHERE username = 'admin')
BEGIN
    PRINT 'Seeding initial default admin account (username: admin, default password: admin@123)...';
    INSERT INTO dbo.admins (username, password, created_at)
    VALUES (
        N'admin',
        N'$2b$10$ay8DhWPlcTceC3V/jMfmbeg1aMYGrOxgKIKkPCR7vMSEzY4B9zAGO',
        SYSDATETIME()
    );
    PRINT 'Default admin seeded successfully.';
END
GO

-- =====================================================================================
-- TABLE 2: [dbo].[products]
-- Purpose: Medical equipment catalog (Lasers, Morcellators, Scopes, Consumables)
-- Backend: models/product.model.js, controllers/product.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.products', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[products]...';
    CREATE TABLE dbo.products (
        id INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(255) NOT NULL,
        color_palette NVARCHAR(50) NOT NULL CONSTRAINT DF_products_color_palette DEFAULT N'medical-teal',
        image_url NVARCHAR(MAX) NULL,
        cloudinary_public_id NVARCHAR(255) NULL,
        is_active BIT NOT NULL CONSTRAINT DF_products_is_active DEFAULT 1,
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_products_created_at DEFAULT SYSDATETIME(),
        updated_at DATETIME2(7) NULL,
        deleted_at DATETIME2(7) NULL,
        CONSTRAINT PK_products PRIMARY KEY CLUSTERED (id ASC)
    );
    PRINT 'Table [dbo].[products] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[products] already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_products_deleted_active' AND object_id = OBJECT_ID(N'dbo.products'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_products_deleted_active
        ON dbo.products (deleted_at, is_active, created_at DESC)
        INCLUDE (id, name, color_palette, image_url, cloudinary_public_id, updated_at);
    PRINT 'Index [idx_products_deleted_active] created.';
END
GO

-- =====================================================================================
-- TABLE 3: [dbo].[clients]
-- Purpose: Partner hospitals, medical centers, and institutional client logos
-- Backend: models/client.model.js, controllers/client.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.clients', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[clients]...';
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
    PRINT 'Table [dbo].[clients] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[clients] already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_filter_order' AND object_id = OBJECT_ID(N'dbo.clients'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_clients_filter_order
        ON dbo.clients (deleted_at, is_active, display_order ASC, created_at DESC);
    PRINT 'Index [idx_clients_filter_order] created.';
END
GO

-- =====================================================================================
-- TABLE 4: [dbo].[testimonials]
-- Purpose: Surgeon testimonials, endorsements, and doctor feedback
-- Backend: models/testimonial.model.js, controllers/testimonial.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.testimonials', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[testimonials]...';
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
    PRINT 'Table [dbo].[testimonials] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[testimonials] already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_testimonials_deleted_active' AND object_id = OBJECT_ID(N'dbo.testimonials'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_testimonials_deleted_active
        ON dbo.testimonials (deleted_at, is_active, created_at DESC)
        INCLUDE (id, author_name, bg_theme, image_url, cloudinary_public_id, updated_at);
    PRINT 'Index [idx_testimonials_deleted_active] created.';
END
GO

-- =====================================================================================
-- TABLE 5: [dbo].[blogs]
-- Purpose: Medical knowledgebase, clinical articles, benchmark specs & reader view
-- Backend: models/blog.model.js, controllers/blog.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.blogs', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[blogs]...';
    CREATE TABLE dbo.blogs (
        id INT IDENTITY(1,1) NOT NULL,
        title NVARCHAR(255) NOT NULL,
        slug NVARCHAR(255) NOT NULL,
        thumbnail_url NVARCHAR(MAX) NULL,
        thumbnail_public_id NVARCHAR(255) NULL,
        category NVARCHAR(255) NULL,
        excerpt NVARCHAR(MAX) NOT NULL,
        article_subtitle NVARCHAR(MAX) NULL,
        key_takeaways NVARCHAR(MAX) NULL,        -- JSON array: ["...", "..."]
        article_content NVARCHAR(MAX) NULL,      -- Full markdown/HTML content
        article_sections NVARCHAR(MAX) NULL,     -- JSON array of section objects
        benchmark_specs NVARCHAR(MAX) NULL,      -- JSON array of spec key/value pairs
        enquiry_cta NVARCHAR(MAX) NULL,          -- JSON object: { title, subtitle, buttonText }
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
    PRINT 'Table [dbo].[blogs] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[blogs] already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_blogs_deleted_active' AND object_id = OBJECT_ID(N'dbo.blogs'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_blogs_deleted_active
        ON dbo.blogs (deleted_at, is_active)
        INCLUDE (is_featured, created_at, id, title, slug, category);
    PRINT 'Index [idx_blogs_deleted_active] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_blogs_featured_created' AND object_id = OBJECT_ID(N'dbo.blogs'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_blogs_featured_created
        ON dbo.blogs (is_featured DESC, created_at DESC, id DESC);
    PRINT 'Index [idx_blogs_featured_created] created.';
END
GO

-- =====================================================================================
-- TABLE 6: [dbo].[ContactQueries]
-- Purpose: Contact Us inquiries & date-based scheduled call bookings (max 50/day)
-- Backend: models/contactQuery.model.js, controllers/contactQuery.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.ContactQueries', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[ContactQueries]...';
    CREATE TABLE dbo.ContactQueries (
        id INT IDENTITY(1,1) NOT NULL,
        client_name NVARCHAR(255) NOT NULL,
        client_email NVARCHAR(255) NULL,
        client_phone NVARCHAR(50) NULL,
        query_message NVARCHAR(MAX) NOT NULL,
        selected_date DATE NOT NULL,
        status NVARCHAR(50) NOT NULL CONSTRAINT DF_ContactQueries_status DEFAULT N'Pending',
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_ContactQueries_created_at DEFAULT SYSDATETIME(),
        CONSTRAINT PK_ContactQueries PRIMARY KEY CLUSTERED (id ASC)
    );
    PRINT 'Table [dbo].[ContactQueries] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[ContactQueries] already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contact_queries_selected_date' AND object_id = OBJECT_ID(N'dbo.ContactQueries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_contact_queries_selected_date
        ON dbo.ContactQueries (selected_date);
    PRINT 'Index [idx_contact_queries_selected_date] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contact_queries_status' AND object_id = OBJECT_ID(N'dbo.ContactQueries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_contact_queries_status
        ON dbo.ContactQueries (status);
    PRINT 'Index [idx_contact_queries_status] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contact_queries_created_at' AND object_id = OBJECT_ID(N'dbo.ContactQueries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_contact_queries_created_at
        ON dbo.ContactQueries (created_at DESC);
    PRINT 'Index [idx_contact_queries_created_at] created.';
END
GO

-- =====================================================================================
-- TABLE 7: [dbo].[machine_queries]
-- Purpose: Product Enquiries and Machine quotes cart submitted from RHS website
-- Backend: models/machineQuery.model.js, controllers/machineQuery.controller.js
-- =====================================================================================
IF OBJECT_ID(N'dbo.machine_queries', N'U') IS NULL
BEGIN
    PRINT 'Creating table: [dbo].[machine_queries]...';
    CREATE TABLE dbo.machine_queries (
        id INT IDENTITY(1,1) NOT NULL,
        machine_id NVARCHAR(255) NULL,
        machine_name NVARCHAR(500) NOT NULL,
        products_json NVARCHAR(MAX) NULL,          -- JSON array of selected machines/products
        hospital NVARCHAR(255) NULL,
        user_name NVARCHAR(255) NOT NULL,
        user_email NVARCHAR(255) NULL,
        user_phone NVARCHAR(50) NOT NULL,
        address NVARCHAR(500) NULL,
        country NVARCHAR(100) NULL CONSTRAINT DF_machine_queries_country DEFAULT N'INDIA',
        state NVARCHAR(100) NULL,
        city NVARCHAR(100) NULL,
        pin_code NVARCHAR(50) NULL,
        query_reason NVARCHAR(MAX) NOT NULL,
        message NVARCHAR(MAX) NULL,
        status NVARCHAR(50) NOT NULL CONSTRAINT DF_machine_queries_status DEFAULT N'New',
        admin_notes NVARCHAR(MAX) NULL,
        created_at DATETIME2(7) NOT NULL CONSTRAINT DF_machine_queries_created_at DEFAULT SYSDATETIME(),
        CONSTRAINT PK_machine_queries PRIMARY KEY CLUSTERED (id ASC)
    );
    PRINT 'Table [dbo].[machine_queries] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[machine_queries] already exists. Verifying column structure...';
    -- Incremental schema migrations for existing tables
    IF COL_LENGTH(N'dbo.machine_queries', N'products_json') IS NULL
        ALTER TABLE dbo.machine_queries ADD products_json NVARCHAR(MAX) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'hospital') IS NULL
        ALTER TABLE dbo.machine_queries ADD hospital NVARCHAR(255) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'address') IS NULL
        ALTER TABLE dbo.machine_queries ADD address NVARCHAR(500) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'country') IS NULL
        ALTER TABLE dbo.machine_queries ADD country NVARCHAR(100) NULL CONSTRAINT DF_machine_queries_country DEFAULT N'INDIA';

    IF COL_LENGTH(N'dbo.machine_queries', N'state') IS NULL
        ALTER TABLE dbo.machine_queries ADD state NVARCHAR(100) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'city') IS NULL
        ALTER TABLE dbo.machine_queries ADD city NVARCHAR(100) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'pin_code') IS NULL
        ALTER TABLE dbo.machine_queries ADD pin_code NVARCHAR(50) NULL;

    IF COL_LENGTH(N'dbo.machine_queries', N'status') IS NULL
        ALTER TABLE dbo.machine_queries ADD status NVARCHAR(50) NOT NULL CONSTRAINT DF_machine_queries_status DEFAULT N'New';

    IF COL_LENGTH(N'dbo.machine_queries', N'admin_notes') IS NULL
        ALTER TABLE dbo.machine_queries ADD admin_notes NVARCHAR(MAX) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_machine_queries_machine_name' AND object_id = OBJECT_ID(N'dbo.machine_queries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_machine_queries_machine_name
        ON dbo.machine_queries (machine_name);
    PRINT 'Index [idx_machine_queries_machine_name] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_machine_queries_created_at' AND object_id = OBJECT_ID(N'dbo.machine_queries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_machine_queries_created_at
        ON dbo.machine_queries (created_at DESC);
    PRINT 'Index [idx_machine_queries_created_at] created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_machine_queries_status' AND object_id = OBJECT_ID(N'dbo.machine_queries'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_machine_queries_status
        ON dbo.machine_queries (status);
    PRINT 'Index [idx_machine_queries_status] created.';
END
GO

-- =====================================================================================
-- VERIFICATION & SUMMARY
-- =====================================================================================
PRINT '===================================================================';
PRINT '  RHS DATABASE SETUP COMPLETED SUCCESSFULLY!                      ';
PRINT '===================================================================';

SELECT 
    t.name AS [TableName],
    s.name AS [SchemaName],
    p.rows AS [RowCount],
    t.create_date AS [CreatedDate]
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
WHERE t.name IN ('admins', 'products', 'clients', 'testimonials', 'blogs', 'ContactQueries', 'machine_queries')
ORDER BY t.name ASC;
GO

