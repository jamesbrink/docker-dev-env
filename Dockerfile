# James Brink Dev
#
# VERSION      1.0.1

FROM ubuntu:wily
MAINTAINER James Brink, brink.james@gmail.com

# Setup needed dependencies
RUN apt-get update && apt-get install -y \
  autoconf \
  bison \
  build-essential \ 
  cmake \ 
  curl \
  elixir \
  file \
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
  openjdk-8-jdk \
  openssh-server \
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
  && rm -rf /var/lib/apt/lists/* 

RUN useradd -g users -s /bin/bash -d /home/_docker_staging -m docker
USER docker

# Clone Repos 
RUN mkdir -p /home/_docker_staging/local/src/ \
  && cd /home/_docker_staging/local/src \
  && git clone https://github.com/ruby/ruby.git \
  && git clone https://github.com/python/cpython.git \
  && git clone https://github.com/joyent/node.git \
  && git clone https://github.com/rust-lang/rust.git \
  && git clone https://github.com/rust-lang/cargo.git \
  && cd /home/_docker_staging/local/src/ \
  && git clone https://github.com/golang/go.git \
  && git clone https://github.com/jruby/jruby.git \
  && mkdir -p /home/_docker_staging/projects/ \
  && git clone https://github.com/gradle/gradle.git \
  && cd /home/_docker_staging/projects/ \
  && git clone https://github.com/jamesbrink/dotfiles.git 

# Install Ruby
RUN cd /home/_docker_staging/local/src/ruby \
  && git checkout $RUBY_VERSION \
  && autoconf \
  && ./configure --prefix /home/_docker_staging/local/ruby/`echo "${RUBY_VERSION}" | sed "s/_/\./"` \
  && make && make test && make install \
  && make clean 

# Install Python
RUN cd /home/_docker_staging/local/src/cpython \
  && git checkout $PYTHON_VERSION \
  && ./configure --prefix=/home/_docker_staging/local/python/v$PYTHON_VERSION \
  && make \
  && export OLD_PATH=$PATH \
  && export PATH=/home/_docker_staging/local/src/cpython:$PATH \
  # TODO make test is failing on test_gdb
  # && make test \
  && make install \
  && export PATH=$OLD_PATH \
  && make clean

# Install IntelliJ 15 Ultimate
RUN cd /home/_docker_staging/ \
  && mkdir -p /home/_docker_staging/local/opt/ \
  && wget "https://download.jetbrains.com/idea/ideaIU-15.0.2.tar.gz" \
  && tar xfvz ideaIU-15.0.2.tar.gz \
  && rm ideaIU-15.0.2.tar.gz \
  && mv idea-IU-143.1184.17 /home/_docker_staging/local/opt/IntelliJ15

# Install Rust
RUN cd /home/_docker_staging/local/ \
  && wget https://static.rust-lang.org/dist/rust-1.5.0-x86_64-unknown-linux-gnu.tar.gz \
  && tar xfvz rust-1.5.0-x86_64-unknown-linux-gnu.tar.gz \
  && cd rust-1.5.0-x86_64-unknown-linux-gnu \
  && ./install.sh --prefix=/home/_docker_staging/local \
  && cd /home/_docker_staging/local/ \
  && rm -rf rust-1.5.0-x86_64-unknown-linux-gnu

USER root
RUN userdel docker

# Copy any docker assets into container
COPY ./assets /usr/local/opt/docker-assets/
RUN chmod -R 775 /usr/local/opt/docker-assets && touch /runSetup

# Setup environment variables
ENV FULL_NAME James Brink
ENV USER_NAME james
ENV USER_PASSWORD password
ENV EMAIL_ADDRESS brink.james@gmail.com
ENV RUBY_VERSION v2_2_2
ENV PYTHON_VERSION 2.7
ENV RUST_VERSION 1.5.0

EXPOSE 22

CMD ["/usr/local/opt/docker-assets/bin/shell.sh"]
