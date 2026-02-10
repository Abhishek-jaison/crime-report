import sqlite3

def fix_schema():
    print("Checking database schema...")
    try:
        conn = sqlite3.connect('crime_report.db')
        cursor = conn.cursor()
        
        # Check users table columns
        cursor.execute("PRAGMA table_info(users)")
        columns = [info[1] for info in cursor.fetchall()]
        print(f"Current columns in users table: {columns}")
        
        if 'name' not in columns:
            print("Column 'name' not found. Adding it...")
            try:
                cursor.execute("ALTER TABLE users ADD COLUMN name VARCHAR")
                conn.commit()
                print("Success: 'name' column added.")
            except Exception as e:
                print(f"Error adding column: {e}")
        else:
            print("'name' column already exists.")

        if 'aadhaar_number' not in columns:
            print("Column 'aadhaar_number' not found. Adding it...")
            try:
                cursor.execute("ALTER TABLE users ADD COLUMN aadhaar_number VARCHAR")
                conn.commit()
                print("Success: 'aadhaar_number' column added.")
            except Exception as e:
                print(f"Error adding aadhaar_number column: {e}")
        else:
            print("'aadhaar_number' column already exists.")

        conn.close()
    except Exception as e:
        print(f"Database connection error: {e}")

if __name__ == "__main__":
    fix_schema()
