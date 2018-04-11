

BINS-UTIL=wov-ns wov-p wov-plog wov-init wov-service
BINS=wov-env wov-stagecompare wov-stage wov-env wov-build wov-compile \
		 wov-push-check wov-push-containers wov-push-env wov-push-secrets \
		 wov-deploy-apply wov-deploy-info \
		 $(BINS-UTIL)

APPLESCRIPT=wov-context.app

install : 

# ---------------------------------------------------------------------
# Install scripts
# ---------------------------------------------------------------------
install :
	@echo "- $(@) --------------------------------------------------------------"
	@echo "  ... install bins in /usr/local/bin, via ln"
	@for b in $(BINS); do \
		echo "    ... install $$b"; \
		ln -f -s $(CURDIR)/bin/$$b /usr/local/bin/$$b; \
		done
	@echo "  ... install applescript to Terminal script directory, via ln"
	@for b in $(APPLESCRIPT); do \
		echo "    ... install $$b"; \
		if [ ! -e $(CURDIR)/bin/$$b ]; then echo "ERROR: can not find $$b... did you compile it as an app?"; fi; \
		ln -f -s $(CURDIR)/bin/$$b $(HOME)/Library/Scripts/Applications/Terminal/$$b; \
	done

#	echo "    ... install wovmsdev, pointing to wovpshell"
#	ln -f -s $(CURDIR)/bin/wovpshell /usr/local/bin/wovmsdev
#	@echo "  ... install applescript to Terminal script directory, via ln"
#	@for b in $(APPLESCRIPT); do \
#		echo "    ... install $$b"; \
#		ln -f -s $(CURDIR)/bin/$$b $(HOME)/Library/Scripts/Applications/Terminal/$$b; \
#		done
