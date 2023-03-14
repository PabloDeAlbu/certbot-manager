.PHONY: build deploy renew_certificates

include .env

# define the paths to text files with domain names
FAILED_DOMAINS_FILE := ${TMP_DIR}/failed-domains.txt
DOMAINS_TO_RENEW_FILE := ${TMP_DIR}/domains-to-renew.txt
CERT_FILE := ${CERT_FILE}

# python vars 
VENV_NAME?=.venv
PYTHON=${VENV_NAME}/bin/python

default: build

build: requirements.txt
	@test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	@${PYTHON} -m pip install -U pip
	@${PYTHON} -m pip install -r requirements.txt
	@touch $(VENV_NAME)/bin/activate
	@mkdir -p $(TMP_DIR)
	@touch $(FAILED_DOMAINS_FILE) $(DOMAINS_TO_RENEW_FILE)
	@echo "OK - set up"

get_domains_to_renew: build
	@${PYTHON} get_domains_to_renew.py
	@echo "Los dominios a actualizar se almacenaron correctamente en get_domains_to_renew.txt"

certbot-dry-run: 
	@certbot certonly --dry-run --apache --domains $$(cat ${DOMAINS_TO_RENEW_FILE}) > log.txt

certbot-dry-run-1: certbot-dry-run
	@${PYTHON} check_log.py

certbot-renew: certbot-dry-run-1
	echo "Salio bien"

#cat| grep -E 'Failed|Skipped' | awk '{print $NF}' > /path/to/failed-domains.txt