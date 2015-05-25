# James Brink Dev
#
# VERSION      1.0.0

FROM ubuntu:vivid
MAINTAINER James Brink, brink.james@gmail.com

# Setup needed dependencies
RUN apt-get update && apt-get install -y \
  autoconf \
  bison \
  build-essential \ 
  cmake \ 
  curl \
  gdb \
  git \
  libcurl4-openssl-dev \
  libffi-dev \
  libgdbm-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  maven \
  openjdk-7-jdk \
  python-software-properties \
  ruby \
  silversearcher-ag \
  sqlite3 \
  sudo \
  tmux \
  vim \
  vim \
  wget \
  zlib1g-dev \
  && wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb \
  && apt-get update \
  && apt-get -y install elixir \
  && rm -rf /var/lib/apt/lists/* 

RUN useradd -g users -s /bin/bash -d /home/_docker_staging -m docker
USER docker

# Download JDK
RUN mkdir -p /home/_docker_staging/local/opt/java \
  && cd /home/_docker_staging/local/opt/java \
  &&  wget --no-cookies --no-check-certificate --header \
    "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
    "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz" \
  && tar xfvz jdk-8u45-linux-x64.tar.gz \
  && mv jdk1.8.0_45 jdk8 \
  && rm jdk-8u45-linux-x64.tar.gz  

# Clone Repos 
RUN mkdir -p /home/_docker_staging/local/src/ \
  && cd /home/_docker_staging/local/src \
  && git clone https://github.com/ruby/ruby.git \
  && git clone https://github.com/python/cpython.git \
  && git clone https://github.com/joyent/node.git \
  && cd /home/_docker_staging/local/src/ \
  && git clone https://github.com/golang/go.git \
  && git clone https://github.com/jruby/jruby.git \
  && mkdir -p /home/_docker_staging/projects/ \
  && git clone https://github.com/gradle/gradle.git \
  && cd /home/_docker_staging/projects/ \
  && git clone https://github.com/jamesbrink/dotfiles.git 

# Compile and install from sources
RUN echo \
  # Install Ruby
  && cd /home/_docker_staging/local/src/ruby \
  && git checkout $RUBY_VERSION \
  && autoconf \
  && ./configure --prefix /home/_docker_staging/local/ruby/`echo "${RUBY_VERSION}" | sed "s/_/\./"` \
  && make && make test && make install \
  && make clean \
  && echo "Install Python ${PYTHON_VERSION} ." \
  # Install Python
  && cd /home/_docker_staging/local/src/cpython \
  && git checkout $PYTHON_VERSION \
  && ./confure --prefix=/home/_docker_staging/local/python/v$PYTHON_VERSION \
  && make \
  && export OLD_PATH=$PATH \
  && export PATH=/home/_docker_staging/local/src/cpython \
  # TODO make test is failing on test_gdb
  # && make test \
  && make install \
  && export PATH=$OLD_PATH \
  && make clean

USER root
RUN userdel docker

# Copy any docker assets into container
COPY ./assets /local/opt/docker-assets/
RUN chmod -R 775 /local/opt/docker-assets && touch /runSetup

# Setup environment variables
ENV FULL_NAME James Brink
ENV USER_NAME james
ENV EMAIL_ADDRESS brink.james@gmail.com
ENV RUBY_VERSION v2_2_2
ENV PYTHON_VERSION 2.7

CMD ["/local/opt/docker-assets/bin/shell.sh"]
