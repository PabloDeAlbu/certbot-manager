.ONESHELL:
.PHONY: write_domains renew_certificates get_failed_domains

# Incluir las variables definidas en el archivo .env
include .env

# Definir las rutas a los archivos de texto con los nombres de dominio
FAILED_DOMAINS_FILE := $(WORKDIR)/failed-domains.txt
DOMAINS_TO_RENEW_FILE := $(WORKDIR)/domains-to-renew.txt
CERT_FILE := $(CERT_FILE)

VENV_NAME?=.venv
PYTHON=${VENV_NAME}/bin/python

default: get_domains_to_renew

prepare_venv: $(VENV_NAME)/bin/activate

$(VENV_NAME)/bin/activate: requirements.txt
	test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	${PYTHON} -m pip install -U pip
	${PYTHON} -m pip install -r requirements.txt
	touch $(VENV_NAME)/bin/activate

get_domains_to_renew: prepare_venv
	@${PYTHON} get_domains_to_renew.py
	@echo "Los dominios a actualizar se almacenaron correctamente en get_domains_to_renew.txt"

certbot-dry-run: 
	@certbot certonly --dry-run --apache --domains $$(cat ${DOMAINS_TO_RENEW_FILE}) > log.txt

certbot-dry-run-1: certbot-dry-run
	@${PYTHON} check_log.py

certbot-renew: certbot-dry-run-1
	echo "Salio bien"

#cat| grep -E 'Failed|Skipped' | awk '{print $NF}' > /path/to/failed-domains.txt