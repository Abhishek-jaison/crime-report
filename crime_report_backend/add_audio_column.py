from sqlalchemy import text
from app.database import engine

def add_audio_path_column():
    print("Initiating database migration for complaints table...")
    try:
        with engine.connect() as conn:
            conn.execute(text("ALTER TABLE complaints ADD COLUMN audio_path VARCHAR;"))
            conn.commit()
            print("Successfully added 'audio_path' column to 'complaints' table.")
    except Exception as e:
        print(f"Migration error (column might already exist): {e}")

if __name__ == "__main__":
    add_audio_path_column()
