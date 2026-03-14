import sqlite3

conn = sqlite3.connect('crime_report.db')
cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
print("Tables:", cursor.fetchall())
cursor.execute("PRAGMA table_info(sos_alerts)")
print("sos_alerts columns:", cursor.fetchall())
conn.close()
