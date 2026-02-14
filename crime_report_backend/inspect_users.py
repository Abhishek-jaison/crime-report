
import sqlite3
import os

db_path = "crime_report.db"

if not os.path.exists(db_path):
    print(f"❌ Database file not found at: {os.path.abspath(db_path)}")
else:
    print(f"✅ Database found at: {os.path.abspath(db_path)}")
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        print("\n--- USERS TABLE ---")
        cursor.execute("SELECT id, name, email FROM users")
        users = cursor.fetchall()
        
        if not users:
            print("⚠️  No users found (Table is empty).")
        else:
            print(f"{'ID':<5} {'Name':<25} {'Email':<30}")
            print("-" * 60)
            for user in users:
                # Handle None values
                uid = str(user[0])
                name = str(user[1]) if user[1] else "N/A"
                email = str(user[2]) if user[2] else "N/A"
                print(f"{uid:<5} {name:<25} {email:<30}")
                
        conn.close()
    except Exception as e:
        print(f"❌ Error reading database: {e}")
#this is a test line