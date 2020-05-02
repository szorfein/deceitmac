PROGRAM_NAME=deceitmac
VERSION=0.0.1
DESTDIR ?=

ifndef DESTDIR
	DESTDIR := /
endif

PROGRAM_DIR=$(DESTDIR)usr/local/bin
CONF_DIR=$(DESTDIR)etc
DATA_DIR=$(DESTDIR)usr/share
DOCS_DIR=$(DATA_DIR)/doc

install:
	install -Dm755 deceitmac.sh $(PROGRAM_DIR)/$(PROGRAM_NAME)
	install -m644 -d $(CONF_DIR)/$(PROGRAM_NAME)
	install -Dm644 README.md $(DOCS_DIR)/$(PROGRAM_NAME)/README.md

uninstall:
	rm -Rf $(PROGRAM_DIR)/$(PROGRAM_NAME)
	rm -Rf $(CONF_DIR)/$(PROGRAM_NAME)
	rm -Rf $(DATA_DIR)/$(PROGRAM_NAME)
	rm -Rf $(DOCS_DIR)/$(PROGRAM_NAME)
