import requests

def upload_file():
    url = "http://localhost:5000/upload"
    headers = {"X-Api-Key": "APIKEY123"}
    files = {"file": open("C:\\Users\\Bartosz Kasyna\\Downloads\\Syllabus-2025-Final.pdf", "rb")}
    data = {"folder": "moj_folder"}
    response = requests.post(url, headers=headers, files=files, data=data)
    print(response.json())
    return response

def download_file(filename):
    url = f"http://localhost:5000/download/{filename}"
    headers = {"X-Api-Key": "APIKEY123"}
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        # Assuming you want to save the downloaded file locally
        with open(f"downloaded_{filename.split('/')[-1]}", "wb") as f:
            f.write(response.content)
        print(f"File {filename} downloaded successfully as downloaded_{filename.split('/')[-1]}")
    else:
        print(f"Error downloading file: {response.json()}")
    
    return response

# Example usage
if __name__ == "__main__":
    # Upload a file
    upload_response = upload_file()
    
    # Download a file (example filename based on the upload)
    download_response = download_file("moj_folder/a9d8_2_3_2025.pdf")