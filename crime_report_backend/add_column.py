import sqlite3

def add_column():
    print("Attempting to add aadhaar_number column...")
    try:
        conn = sqlite3.connect('crime_report.db')
        cursor = conn.cursor()
        
        # Check if column exists
        cursor.execute("PRAGMA table_info(users)")
        columns = [info[1] for info in cursor.fetchall()]
        
        if 'aadhaar_number' not in columns:
            print("Column not found. Adding it now...")
            cursor.execute("ALTER TABLE users ADD COLUMN aadhaar_number VARCHAR")
            conn.commit()
            print("Success: aadhaar_number column added.")
        else:
            print("Info: aadhaar_number column already exists.")
            
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    add_column()
