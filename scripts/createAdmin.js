import "dotenv/config";
import bcrypt from "bcrypt";
import db, { sql } from "../config/db.js";

const username = "admin";
const password = "admin@123";

async function createAdmin() {
    try {
        const pool = await db;
        const hashedPassword = await bcrypt.hash(password, 10);

        await pool
            .request()
            .input("username", sql.NVarChar(255), username)
            .input("password", sql.NVarChar(255), hashedPassword)
            .query(`
                IF EXISTS (SELECT 1 FROM dbo.admins WHERE username = @username)
                BEGIN
                    UPDATE dbo.admins 
                    SET password = @password, updated_at = SYSDATETIME() 
                    WHERE username = @username;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.admins (username, password, created_at) 
                    VALUES (@username, @password, SYSDATETIME());
                END
            `);

        console.log("Admin account created/updated successfully in MSSQL.");
        console.log("Username:", username);
        console.log("Change the default password before production.");
    } catch (error) {
        console.error("Failed to create/update admin:", error.message);
    }
}

createAdmin();
