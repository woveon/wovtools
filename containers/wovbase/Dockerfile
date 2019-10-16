# A base image to develop on in the test namespace
#FROM ubuntu:19.04
FROM ubuntu:disco

# --------------------------------------------------------------------- 
# Package installs 
# --------------------------------------------------------------------- 
RUN apt-get -q update

# Create app directory
#WORKDIR /usr/src/app

# Some dev tools
RUN apt-get -y install vim wget curl bash net-tools git iputils-ping dnsutils make ufw gnupg nfs-common jq figlet

# Install NodeJS (after install curl above)
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
ENV NODE_PATH /usr/lib/node_modules

# Install yarn and some packages
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn
RUN yarn global add mocha bcryptjs nodemon
#RUN yarn add -g npm


# Because Mongo needs tzdata and it creates an interactive issue
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install Mongo client v3.6
# FROM HERE: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# RUN apt-get -y install dirmngr
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
# RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu ${DISTRO}/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
# RUN apt-get update
# RUN apt-get install -y mongodb-org

#??
# Install postgres v9.6 client (AWS is 9.6.5.. bummer)
#   FROM: https://gist.github.com/ziyan-junaideen/d4a65534c1a17ca6995c9c974e62d74f
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ disco-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN cat /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y libpq5 postgresql-client-9.6

# Available for keys to be copied in
#RUN mkdir /root/.ssh
# Add github 
#RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
#RUN chmod 600 /root/.ssh/known_hosts

# Settings for postgress
COPY psqlrc /root/.psqlrc


# Vim - Vundle and Pathogen
COPY vimrc /root/.vimrc
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN vim +PluginInstall +qall
#RUN script -c bash "vim +PluginInstall +qall"

#Other files
#COPY bashrcext /root/.bashrcext
#RUN  cat /root/.bashrcext >> /root/.bashrc
#RUN  rm /root/.bashrcext
COPY inputrc /root/.inputrc

RUN apt install bash-completion
RUN echo "source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
RUN echo 'source <(kubectl completion bash)' >> /root/.bashrc

# Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Kops
RUN curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d "\"" -f 4)/kops-linux-amd64
RUN chmod +x ./kops
RUN mv ./kops /usr/local/bin/


# Create app directory
WORKDIR /root

# Move to specifc instance
COPY /User/cwingrav/code/woveon/src/wovtool /root/wovtools
