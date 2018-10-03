# A base image to develop on in the test namespace
#FROM ubuntu:16.04
#FROM ubuntu:17.10
FROM ubuntu:bionic

# --------------------------------------------------------------------- 
# Package installs 
# --------------------------------------------------------------------- 
RUN apt-get -q update

# Create app directory
WORKDIR /usr/src/app

# Some dev tools
RUN apt-get -y install vim wget curl bash net-tools git iputils-ping dnsutils make ufw gnupg 

# Install NodeJS (after install curl above)
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
ENV NODE_PATH /usr/lib/node_modules
RUN npm install -g mocha bcryptjs nodemon
RUN npm install -g npm


# Because Mongo needs tzdata and it creates an interactive issue
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install Mongo client v3.6
# FROM HERE: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
RUN apt-get -y install dirmngr
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update
RUN apt-get install -y mongodb-org

#??
# Install postgres v9.6 client (AWS is 9.6.5.. bummer)
RUN apt-get install -y postgresql-client

# parser
RUN apt-get install -y jq

# Available for keys to be copied in
RUN mkdir /root/.ssh

# Settings for postgress
COPY psqlrc /root/.psqlrc

# Vim - Vundle and Pathogen
COPY vimrc /root/.vimrc
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN vim +PluginInstall +qall
#RUN script -c bash "vim +PluginInstall +qall"

#Other files
COPY bashrcext /root/.bashrcext
RUN  cat /root/.bashrcext >> /root/.bashrc
RUN  rm /root/.bashrcext
COPY inputrc /root/.inputrc

# Add github 
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN chmod 600 /root/.ssh/known_hosts

# Add to /usr/local/bin
COPY localbin /usr/local/bin
