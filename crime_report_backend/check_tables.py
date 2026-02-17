
import requests
try:
    response = requests.get('http://127.0.0.1:8000/debug/tables')
    print(response.json())
except Exception as e:
    print(e)
