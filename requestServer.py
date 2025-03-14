import requests

url = "http://localhost:5000/upload"
headers = {"X-Api-Key": "APIKEY123"}
files = {"file": open("C:\\Users\\Bartosz Kasyna\\Downloads\\a9d8_2_3_2025.pdf", "rb")}
data = {"folder": "moj_folder"}
response = requests.post(url, headers=headers, files=files, data=data)
print(response.json())