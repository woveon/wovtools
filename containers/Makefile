.PHONY: all test wovbase wovtest #vh


all : 
	@echo ""
	@echo "WovTools Docker Images"
	@echo "---------------------------------------------------------------------"
	@echo "  make wovbase - the base Docker image for other WovTools containers"
	@echo "  make wovtest - adds wovtools to wovbase for testing"
	@echo ""


# Creates the base Docker image for others
wovbase : $(shell find wovbase -type f)
	mkdir wovbase/wovtools
	rsync -ai --delete ${HOME}/code/woveon/src/wovtools wovbase/wovtools/ 
	exit 1
	@docker build -f ./wovbase/Dockerfile -t wovbase ./wovbase
	@echo "  ... tagging container   : wovtools/wovbase:$(shell wov-env --version)"
	@docker tag wovbase "wovtools/wovbase:$(shell wov-env --version)"
	# @echo "  ... push to DockerHub: wovtools/wovbase"
	# @docker push wovtools/wovbase || \
		#  ( echo "Hmm, did you 'docker login'?" && docker login -u wovtools && docker push wovtools/wovbase )
	@echo "  ... success"

wovtest : $(shell find wovtest -type f)
	@mkdir ./wovtest/SECRET
	@chmod 700 ./wovtest/SECRET
	@cp ~/.ssh/config ./wovtest/SECRET/ssh-config
	@cp ~/.ssh/id_rsa ./wovtest/SECRET/id_rsa
	@cp ~/.ssh/id_rsa.pub ./wovtest/SECRET/id_rsa.pub
	@chmod -R 700 ./wovtest/SECRET
	@docker build -f ./wovtest/Dockerfile -t wovtest ./wovtest
	@rm -Rf ./wovtest/SECRET

## Creates the vh Docker container
#vh : $(shell find vh -type f)
# @docker build -f ./vh/Dockerfile -t vh ./vh
# @echo "  ... tagging container   : wovtools/vh:$(shell wov-env --vh-label)"
# @docker tag vh "wovtools/vh:$(shell wov-env --vh-label)"
# @echo "  ... push to DockerHub: wovtools/vh"
# @docker push wovtools/vh || \
#    ( echo "Hmm, did you 'docker login'?" && docker login -u wovtools && docker push wovtools/vh )
# @echo "  ... success"
