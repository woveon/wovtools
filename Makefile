

BINS-GLOBAL=wovg-dir
BINS-UTIL=wov-ns wov-p wov-plog wov-init wov-service wov-ed wov-ls wov-vh wov-pwait \
	        wov-pshell wov-cmd wov-kui wov-git-check wov-vh-pulldir wov-db wov-db-commit wov-db-connect wov-db-connect2 wov-cd \
					wov-portforward wov-envg wov-project wov-vh-pushgit wov-bastion wov-bastion-connection
BINS=wov-env wov-ns-check wov-stage wov-build wov-compile  \
		 wov-pushcode-check wov-pushcontainer-check wov-pushenv-check wov-build-containers wov-push-env wov-push-secrets wov-push \
		 wov-deploy wov-deploy-info wov-hbs wov-db-deploy  wov-deploy-dev \
		 wov-users wov-cl wov-mod  wov-env-build \
		 $(BINS-UTIL) $(BINS-GLOBAL)

.PHONY: vh

APPLESCRIPT=wov-context.app

install : 

# ---------------------------------------------------------------------
# Install scripts
# ---------------------------------------------------------------------
install : preinstall /usr/local/etc/bash_completion.d/wovtools
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
	@echo "  ... install node modules."
	@npm install -g argparse handlebars ssh-config dotenv minimist
	@echo
	@echo "NOTE!!!"
	@echo "... for wcd to work, add this to your .bash_profile"
	@echo "function wcd() {"
	@echo '  . wov-cd $$*'
	@echo "}"

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

preinstall : 
	@which figlet || ( printf "\nERROR: can not find 'figlet', do : 'brew install figlet'." ; exit 1)

# Creates the vh Docker container
vh : $(shell find vh -type f)
	@docker build -f ./vh/Dockerfile -t vh ./vh
	@echo "  ... tagging container   : wovtools/vh:$(shell wov-env --vh-label)"
	@docker tag vh "wovtools/vh:$(shell wov-env --vh-label)"
	@echo "  ... push to DockerHub: wovtools/vh"
	@docker push wovtools/vh || echo 'Hmm, did you 'docker login'?'
	@echo "  ... success"

