import re

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv
import os

load_dotenv('.env')
tmp_dir = os.getenv('TMP_DIR')

def parse_certbot_output(file_path):
    with open(file_path, 'r') as f:
        output = f.read()
        
    if 'The dry run was successful' in output:
        print('Certbot execution successful')
    else:
        print('Certbot execution failed')
        
        # Find the domains that failed
        failed_domains = []
        pattern = r'Domain:\s+(.*)\n'
        for match in re.finditer(pattern, output):
            domain = match.group(1)
            failed_domains.append(domain)

        email = MIMEMultipart()
        email['Subject'] = 'Certbot execution failed'
        email['From'] = 'root@sympa'
        email['To'] = 'admin@sympa'
        body = f'The following domains failed: {failed_domains}'
        email.attach(MIMEText(body))

        file = open(f'{tmp_dir}/mail.txt', 'w')
        file.write(email.as_string())
        file.close()
        if failed_domains:
            print(body)

parse_certbot_output(f'{tmp_dir}/log.txt')