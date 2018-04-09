

BINS=wov-env wov-stagecompare wov-env wov-build wov-compile \
		 wov-push-check wov-push-containers

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

#	echo "    ... install wovmsdev, pointing to wovpshell"
#	ln -f -s $(CURDIR)/bin/wovpshell /usr/local/bin/wovmsdev
#	@echo "  ... install applescript to Terminal script directory, via ln"
#	@for b in $(APPLESCRIPT); do \
#		echo "    ... install $$b"; \
#		ln -f -s $(CURDIR)/bin/$$b $(HOME)/Library/Scripts/Applications/Terminal/$$b; \
#		done
