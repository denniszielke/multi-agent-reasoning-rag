import requests
import os
import time
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

input_folder = "../../data/"

authorization = os.environ["KM_SERVICE_AUTHORIZATION"]
km_service_url = os.environ["KM_SERVICE_URL"]

file_metadata = [
    {
        "file1": "R1 RCM FY22 10-K.pdf",
        "subject": "ANNUAL REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 for the fiscal year ended Dececember 31, 2022",
        "file_name": "R1 RCM FY22 10-K.pdf",
        "tags": ["type:Annual Filings", "year:2022", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file2": "R1 RCM FY23 10-K.pdf",
        "subject": "ANNUAL REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 for the fiscal year ended Dececember 31, 2023",
        "file_name": "R1 RCM FY23 10-K.pdf",
        "tags": ["type:Annual Filings", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file3": "R1 RCM - 2022 Annual Report.pdf",
        "subject": "Letter from the CEO - annual report 2022",
        "file_name": "R1 RCM - 2022 Annual Report.pdf",
        "tags": ["type:Annual Reports", "year:2022", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file4": "R1 RCM - 2023 Annual Report.pdf",
        "subject": "Letter from the CEO - annual report 2023",
        "file_name": "R1 RCM - 2023 Annual Report.pdf",
        "tags": ["type:Annual Reports", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file5": "R1 RCM Inc.  DE files (8-K) Current report  Item 7.01 - Regulation FD, for period end 4-Oct-24 (RCM-US).pdf",
        "subject": "CURRENT REPORT Pursuant to Section 13 or 15(d) of the Securities Exchange Act of 1934 FORM 8-K",
        "file_name": "R1 RCM Inc.  DE files (8-K) Current report  Item 7.01 - Regulation FD, for period end 4-Oct-24 (RCM-US).pdf",
        "tags": ["type:Other Reports", "year:2024", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file6": "R1 RCM Inc.  DE files (DEFM14A) Definitive proxy statement relating to a merger or acquisition (RCM-US).pdf",
        "subject": "SCHEDULE 14A INFORMATION Proxy Statement Pursuant to Section 14(a) of the Securities Exchange Act of 1934 Filed by the Registrant Definitive Proxy Statement",
        "file_name": "R1 RCM Inc.  DE files (DEFM14A) Definitive proxy statement relating to a merger or acquisition (RCM-US).pdf",
        "tags": ["type:Other Reports", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file7": "R1 RCM Inc. - JPM Healthcare Conference Presentation (01.09.2024).pdf",
        "subject": "42nd annual JPMorgan Healthcare Conference January 2024",
        "file_name": "R1 RCM Inc. - JPM Healthcare Conference Presentation (01.09.2024).pdf",
        "tags": ["type:Other Reports", "year:2024", "author: J. P. Morgan"]
    },
    {
        "file8": "R1 RCM Inc. - KeyBanc Technology Leadership Forum Presentation (08.08.2023).pdf",
        "subject": "2023 KeyBanc Technology Leadership Forum",
        "file_name": "R1 RCM Inc. - KeyBanc Technology Leadership Forum Presentation (08.08.2023).pdf",
        "tags": ["type:Other Reports", "year:2023", "author: R1 RCM Inc."]
    },
    {
        "file9": "R1 RCM Q3 2022 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended September 30, 2022",
        "file_name": "R1 RCM Q3 2022 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2022", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file10": "R1 RCM Q1 2023 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended March 31, 2023",
        "file_name": "R1 RCM Q1 2023 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file11": "R1 RCM Q2 2023 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended June 30, 2023",
        "file_name": "R1 RCM Q2 2023 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file12": "R1 RCM Q3 2023 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended September 30, 2023",
        "file_name": "R1 RCM Q3 2023 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2023", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file13": "R1 RCM Q1 2024 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended March 31, 2024",
        "file_name": "R1 RCM Q1 2024 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2024", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file14": "R1 RCM Q2 2024 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended June 30, 2024",
        "file_name": "R1 RCM Q2 2024 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2024", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
    {
        "file15": "R1 RCM Q3 2024 10Q.pdf",
        "subject": "QUARTERLY REPORT PURSUANT TO SECTION 13 OR 15(d) OF THE SECURITIES EXCHANGE ACT OF 1934 For the quarterly period ended September 30, 2024",
        "file_name": "R1 RCM Q3 2024 10Q.pdf",
        "tags": ["type:Quarterly Filings", "year:2024", "author: UNITED STATES SECURITIES AND EXCHANGE COMMISSION"]
    },
]


index = 0
max_index = 15 #len(file_metadata) - 1

for index in range(max_index):
    file_id = "file" + str(index + 1)
    files = {
        file_id: (file_metadata[index][file_id], open(input_folder + file_metadata[index][file_id], "rb")),
    }

    # Tags to apply, used by queries to filter memory
    data = { "documentId": file_metadata[index][file_id],
             "tags": file_metadata[index]["tags"],
              "subject": file_metadata[index]["subject"],
           }

    headers = {'Authorization': authorization}

    print ("Posting file: " + file_metadata[index][file_id])
    response = requests.post(f"{km_service_url}/upload", files=files, data=data, headers=headers)
    print(response.status_code)
    print(response)
    time.sleep(20)
