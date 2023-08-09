import re

from dotenv import load_dotenv
import os
import logging


load_dotenv('.env')
tmp_dir = os.getenv('TMP_DIR')

def parse_dryrun_output(file_path):
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        filename="log/basic.log",
    )
    with open(file_path, 'r') as f:
        output = f.read()
        
    if 'The dry run was successful' in output:
        print('Certbot execution successful')
        logging.info("Certbot execution successful.")

    else:
        print('Certbot execution failed')
        logging.error("Certbot execution failed.")
        
        # Find the domains that failed
        failed_domains = []
        pattern = r'Domain:\s+(.*)\n'
        for match in re.finditer(pattern, output):
            domain = match.group(1)
            failed_domains.append(domain)

        body = f'The following domains failed: {failed_domains}'
        file = open(f'{tmp_dir}/failed_domains.txt', 'w')
        file.write(body)
        file.close()
        if failed_domains:
            print(body)
        logging.error(body)

parse_dryrun_output(f'{tmp_dir}/dry-run-output.txt')