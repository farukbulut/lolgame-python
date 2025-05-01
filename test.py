import requests
import json

url = "http://localhost:8000/api/update-champions/"
data = {
    "champions": ["Heimerdinger", "Ahri", "Miss Fortune"],
    "languages": ["en", "tr", "de", "fr", "es", "it", "ru", "pt", "br", "nl", "ch", "jp", "kr"],
}

response = requests.post(url, json=data)
print(response.json())