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

check_certbot:
	@echo "Checking if Certbot Apache plugin is installed..."
	@if command -v certbot >/dev/null 2>&1 && certbot -h apache >/dev/null 2>&1; then \
		echo "Certbot Apache plugin is installed."; \
	else \
		echo "Certbot Apache plugin is not installed. Please install the plugin and try again."; \
		exit 1; \
	fi

init-venv: requirements.txt
	@test -d $(VENV_NAME) || virtualenv -p python3 $(VENV_NAME)
	@${PYTHON} -m pip install -U pip
	@${PYTHON} -m pip install -r requirements.txt
	@touch $(VENV_NAME)/bin/activate
	@mkdir -p $(TMP_DIR)
	@touch $(FAILED_DOMAINS_FILE) $(DOMAINS_TO_RENEW_FILE)

build: init-venv check_certbot
	@echo "OK - set up"

get_domains_to_renew: 
	@${PYTHON} get_domains_to_renew.py
	@echo "Los dominios a actualizar se almacenaron correctamente en domains_to_renew.txt"

handle_error:
	@echo "Certbot dry run failed"

certbot-dry-run: get_domains_to_renew
	@set -e ; \
	certbot certonly --dry-run --apache --domains $$(cat ${DOMAINS_TO_RENEW_FILE}) > ${TMP_DIR}/log.txt || $(MAKE) handle_error

certbot-validate: certbot-dry-run
	@${PYTHON} validate.py

certbot-renew: certbot-validate
#	 @/usr/bin/certbot -q renew
	echo "OK - certbot renew"
