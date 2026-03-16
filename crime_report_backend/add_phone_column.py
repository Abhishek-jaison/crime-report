from sqlalchemy import text
from app.database import engine

def add_phone_number_column():
    print("Initiating database migration...")
    try:
        with engine.connect() as conn:
            # SQLite uses a different alteration syntax than Postgres if constraints apply, 
            # but simple ADD COLUMN is generally fine in both.
            # We'll wrap in a basic try-except to handle cases where it might already exist.
            conn.execute(text("ALTER TABLE users ADD COLUMN phone_number VARCHAR;"))
            conn.commit()
            print("Successfully added 'phone_number' column to 'users' table.")
    except Exception as e:
        print(f"Migration error (column might already exist): {e}")

if __name__ == "__main__":
    add_phone_number_column()
