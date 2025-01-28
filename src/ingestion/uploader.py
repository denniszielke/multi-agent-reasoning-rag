import requests
import os

from dotenv import load_dotenv

load_dotenv()

authorization = os.environ["KM_SERVICE_AUTHORIZATION"]
km_service_url = os.environ["KM_SERVICE_URL"]

# Files to import
files = {
          "file1": ("National-CHMA-24.pdf", open("National-CHMA-24.pdf", "rb")),
        }

# Tags to apply, used by queries to filter memory
data = { "documentId": "doc01",
         "tags": [ "user:devis@contoso.com",
                   "collection:business",
                   "collection:plans",
                   "fiscalYear:2025" ]
       }

headers = {'Authorization': authorization}

response = requests.post(f"{km_service_url}/upload", files=files, data=data, headers=headers)