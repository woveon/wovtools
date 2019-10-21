

BINS-EXTERNAL=wovc wov-checkout wov-init
BINS-INIT=wov wov-init-ms wov-init-cluster wov-init-wovdb wov-init-coderepoaccess wov-init-stage
BINS-INIT-LIB=provider-wov-env-aws wov-env-common wov-env-loader wov-env-logging wov-init-common
BINS-ENV=wov-env-ops wov-env-build wov-env wov-cluster wov-kops wov-cluster-createdb wov-cluster-configdbnet wov-env-val wov_stage-select wov-git-check wov-env-provider-common
BINS-CLI=wov-aws wov-cd wov-bastion wov-bastion-connection wov-cmd wov-ed wov-ls wov-ns wov-db-common wov-db wov-db-cloud wov-p wov-plog \
	       wov-hash wov-enc wov-dec wov-log wov-context wov-compile wov-hbs wov-stage wov-ns-check
BINS-VH=wov-vh wov-vh-pushgit wov-vh-pulldir
BINS-PUSH=wov-push-common wov-push-container wov-push-container-buildcheck wov-push-k8s wov-push-db wov-push
BINS-DEPLOY=wov-deploy-service wov-deploy-info wov-deploy wov-deploy-dns

BINS=${BINS-EXTERNAL} ${BINS-INIT} ${BINS-ENV} ${BINS-CLI} ${BINS-VH} ${BINS-PUSH} ${BINS-DEPLOY}

.PHONY: vh all test

APPLESCRIPT=wov-context.app wov-gui-cluster.app wov-gui-namespace.app wov-gui-project.app

BASHMINVER=5
ifeq "$(shell expr `bash -c 'echo $${BASH_VERSION}' | cut -f1 -d.` \>= ${BASHMINVER})" "0"
$(error ERROR: Need bash version ${BASHMINVER} or more. On mac, use 'brew install bash')
endif

all:
	@echo ""
	@echo "  test    - "
	@echo "  install - "
	@echo "  wovbase - builds the Docker container"
	@echo "  #vh      - builds the vh Docker container"
	@echo ""


test:
	cd test ; ./test1.sh

install : 


# ---------------------------------------------------------------------
# Cross-platform
# ---------------------------------------------------------------------
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
wtautocomplete : /usr/share/bash-completion/bash_completion
endif
ifeq ($(UNAME_S),Darwin)
wtautocomplete : /usr/local/etc/bash_completion.d/wovtools
endif


# ---------------------------------------------------------------------
# Install scripts
# ---------------------------------------------------------------------
install : preinstall wtautocomplete
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
	@echo "  ... link wovtools/bin/lib as /usr/local/bin/wovlib"
	@ln -f -s ${CURDIR}/bin/lib /usr/local/bin/wovlib
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


# Ubuntu
/usr/share/bash-completion/bash_completion : completion/wovtools
	@echo "...LINUX: checking for bash_completion"
	@if [ ! -e /usr/share/bash-completion/bash_completion ]; then \
    echo "  ...installing"; \
    apt install bash-completion; \
    echo '[[ "$$(uname)" == "Linux" && $${PS1} && -f /usr/share/bash-completion ]] && . /usr/share/bash-completion/bash_completion' >> ${HOME}/.bash_profile; \
    echo "  ... NOTE: source ~/.bash_profile to enable bash-completion"; \
  else \
    echo "  ...exists"; \
		fi
	ln -f -s $(CURDIR)/completion/wovtools /etc/profile.d/wovtools


# MacOS
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

# Creates the base Docker image for others
wovbase : 
	@docker build -f ./containers/Dockerfile_wovbase -t wovbase .
	@echo "  ... tagging container   : wovtools/wovbase:$(shell wov-env --version)"
	@docker tag wovbase "wovtools/wovbase:$(shell wov-env --version)"
# @echo "  ... push to DockerHub: wovtools/wovbase"
# @docker push wovtools/wovbase || \
#  ( echo "Hmm, did you 'docker login'?" && docker login -u wovtools && docker push wovtools/wovbase )
	@echo "  ... success"
