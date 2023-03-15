import re

def parse_certbot_output(file_path):
    with open(file_path, 'r') as f:
        output = f.read()
        
    if 'Congratulations' in output:
        print('Certbot execution successful')
    else:
        print('Certbot execution failed')
        
        # Find the domains that failed
        failed_domains = []
        pattern = r'Domain:\s+(.*)\n'
        for match in re.finditer(pattern, output):
            domain = match.group(1)
            failed_domains.append(domain)
                
        if failed_domains:
            print('The following domains failed:', failed_domains)

parse_certbot_output('tmp/log.txt')