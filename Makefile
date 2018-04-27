

BINS-UTIL=wov-ns wov-p wov-plog wov-init wov-service wov-ed wov-ls wov-vh wov-pwait \
	        wov-pshell wov-cmd wov-kui wov-git-check wov-pull-dir
BINS=wov-env wov-ns-check wov-stage wov-build wov-compile \
		 wov-pushcode-check wov-pushcontainer-check wov-pushenv-check wov-push-containers wov-push-env wov-push-secrets wov-push \
		 wov-deploy wov-deploy-info \
		 $(BINS-UTIL)

.PHONY: vh

APPLESCRIPT=wov-context.app

install : 

# ---------------------------------------------------------------------
# Install scripts
# ---------------------------------------------------------------------
install : /usr/local/etc/bash_completion.d/wovtools
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


/usr/local/etc/bash_completion.d/wovtools : completion/wovtools
	@echo "...checking for bash_completion"
	@if [ ! -e $(shell brew --prefix)/etc/bash_completion ]; then \
	  echo "  ...installing"; \
		brew install bash-completion ; \
		echo 'if [ -f $(brew --prefix)/etc/bash_completion ]; then' >> ${HOME}/.bash_profile; \
		echo '  . $(brew --prefix)/etc/bash_completion; ' >> ${HOME}/.bash_profile; \
		echo 'fi' >> ${HOME}/.bash_profile; \
		echo "  ... NOTE: source ~/.bash_profile to enable bash-completion"; \
	else \
	  echo "  ...exists"; \
	fi
	ln -f -s $(CURDIR)/completion/wovtools /usr/local/etc/bash_completion.d/wovtools


# Creates the vh Docker container
vh : $(shell find vh -type f)
	@docker build -f ./vh/Dockerfile -t vh ./vh
	@echo "  ... tagging container   : wovtools/vh:$(shell wov-env --vh-label)"
	@docker tag vh "wovtools/vh:$(shell wov-env --vh-label)"
	@echo "  ... push to DockerHub: wovtools/vh"
	@docker push wovtools/vh || echo 'Hmm, did you 'docker login'?'
	@echo "  ... success"

