import sqlite3

def upgrade():
    conn = sqlite3.connect('crime_report.db')
    cursor = conn.cursor()
    
    # Check if columns exist
    cursor.execute("PRAGMA table_info(complaints)")
    columns = [info[1] for info in cursor.fetchall()]
    
    try:
        if 'lat' not in columns:
            print("Adding 'lat' column...")
            cursor.execute("ALTER TABLE complaints ADD COLUMN lat TEXT")
            
        if 'long' not in columns:
            print("Adding 'long' column...")
            cursor.execute("ALTER TABLE complaints ADD COLUMN long TEXT")
            
        if 'suspect_details' not in columns:
            print("Adding 'suspect_details' column...")
            cursor.execute("ALTER TABLE complaints ADD COLUMN suspect_details TEXT")
            
        conn.commit()
        print("Migration successful.")
    except sqlite3.OperationalError as e:
        print(f"Error during migration: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    upgrade()
