from cryptography import x509
from cryptography.hazmat.backends import default_backend
import os
from dotenv import load_dotenv

load_dotenv('.env')

# Especifica la ruta al archivo PEM que contiene el certificado SSL
cert_file = os.getenv('CERT_FILE')
tmp_dir = os.getenv('TMP_DIR')

# Lee el contenido del archivo PEM
with open(cert_file, 'rb') as f:
    cert_data = f.read()

# Carga el certificado en un objeto x509.Certificate de la librería cryptography
cert = x509.load_pem_x509_certificate(cert_data, default_backend())

# Obtiene los nombres de dominio incluidos en el certificado
dns_names = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value.get_values_for_type(x509.DNSName)

domains = ','.join(dns_names)

# Abre un archivo de texto en modo de escritura
with open(f'{tmp_dir}/domains-to-renew.txt', 'w') as f:
    # Escribe cada nombre de dominio en una línea separada en el archivo de texto
    f.write(domains)

# Imprime un mensaje indicando que los nombres de dominio han sido guardados en el archivo de texto
print('Los nombres de dominio han sido guardados en el archivo "domains-to-renew.txt"')
