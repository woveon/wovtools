

BINS-INIT=wov-init wov-init-ms wov-init-dba wov
BINS-ENV=wov-env-loader wov-env-ops wov-env-common wov-env-build wov-env wov-cluster wov-kops wov-cluster-createdb wov-cluster-configdbnet wov-env-val wov_stage-select
BINS-PROVIDER=provider-wov-env-aws
BINS-CLI=wov-aws wov-cd wov-bastion wov-bastion-connection wov-cmd wov-ed wov-ls wov-ns wov-db-common wov-db wov-db-cloud wov-p wov-plog \
	       wov-hash wov-enc wov-dec wov-log wov-context
BINS-VH=wov-vh wov-vh-pushgit wov-vh-pulldir
BINS-PUSH=wov-push-common wov-push-container wov-push-container-buildcheck wov-push-k8s wov-push-db wov-push
BINS-DEPLOY=wov-deploy-service wov-deploy-info wov-deploy wov-deploy-dns

BINS=${BINS-INIT} ${BINS-ENV} ${BINS-PROVIDER} ${BINS-CLI} ${BINS-VH} ${BINS-PUSH} ${BINS-DEPLOY}

.PHONY: vh all test

APPLESCRIPT=wov-context.app wov-gui-cluster.app wov-gui-namespace.app wov-gui-project.app

all:
	@echo ""
	@echo "  test    - "
	@echo "  install - "
	@echo "  vh      - builds the vh Docker container"
	@echo ""


test:
	cd test ; ./test1.sh

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
#	@echo "  ... install applescript to Terminal script directory, via ln"
#	@for b in $(APPLESCRIPT); do \
#		echo "    ... install $$b"; \
#		if [ ! -e $(CURDIR)/bin/$$b ]; then echo "ERROR: can not find $$b... did you compile it as an app? Script Editor > Export > Application, Show startup screen, Run-only "; fi; \
#		rm -Rf $(HOME)/Library/Scripts/Applications/Terminal/$$b; \
#		cp -r $(CURDIR)/bin/$$b $(HOME)/Library/Scripts/Applications/Terminal/$$b; \
#	done
	@echo "  ... install node modules."
	@yarn add argparse handlebars ssh-config dotenv minimist bcryptjs crypto-js
	@echo
	@echo "NOTE!!!"
	@echo "... for wcd to work, add this to your .bash_profile"
	@echo "function wcd() {"
	@echo '  . wov-cd $$*'
	@echo "}"
	@echo "function wkops() {"
	@echo '  . wov-kops'
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
	@docker push wovtools/vh || \
		( echo "Hmm, did you 'docker login'?" && docker login -u wovtools && docker push wovtools/vh )
	@echo "  ... success"

