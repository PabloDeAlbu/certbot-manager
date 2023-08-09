.PHONY: build deploy renew_certificates

include .env

# define the paths to text files with domain names
FAILED_DOMAINS_FILE := ${TMP_DIR}/failed-domains.txt
DOMAINS_TO_RENEW_FILE := ${TMP_DIR}/domains-to-renew.txt
CERT_FILE := ${CERT_FILE}
SEND_TO := ${SEND_TO}

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

cert_path:
	@rm .env
	@cp .env.EXAMPLE .env
	@sed -i 's/REPLACE_ME/$(path)/g' .env

get_domains_to_renew:
	@${PYTHON} get_domains_to_renew.py

handle_error:
	@${PYTHON} dryrun_parser.py
	@mailx -s "Failed domains" ${SEND_TO} < ./tmp/failed_domains.txt
	@exit 1

certbot-dry-run: get_domains_to_renew
	@set -e ; \
	/usr/bin/certbot certonly --dry-run --apache --domains $$(cat ${DOMAINS_TO_RENEW_FILE}) > ${TMP_DIR}/dry-run-output.txt || $(MAKE) -s handle_error

certbot-renew: certbot-dry-run
	@/usr/bin/certbot -q renew
	echo "OK - certbot renew"