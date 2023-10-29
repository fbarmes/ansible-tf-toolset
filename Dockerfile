
#-------------------------------------------------------------------------------
FROM python:3.11-slim


#-------------------------------------------------------------------------------
# Setup tz info
#-------------------------------------------------------------------------------
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris


#-------------------------------------------------------------------------------
# Install python tools and modules (ansible & co.)
#-------------------------------------------------------------------------------
COPY python-requirements.txt /tmp/requirements.txt


RUN \
  #
  # update system
  apt-get update &&\
  #
  # create python virtual env
  python -m venv /opt/toolset &&\
  # use virtual env
  . /opt/toolset/bin/activate &&\
  # install python requirements in venv
  pip install --upgrade pip &&\
  pip install -r /tmp/requirements.txt &&\
  #
  # clean apt
  apt-get -y clean &&\
  rm -rf /var/lib/apt/lists/* &&\
  #
  true


#-------------------------------------------------------------------------------
# Install system tools
#-------------------------------------------------------------------------------
RUN \
  #
  apt-get update &&\
  #
  # install system tools
  apt-get install -y \
    curl \
    wget \
    make \
    git \
    rsync &&\
  #--
  # install ca certificates. this will take custom root ca's into account
  apt-get install -y \
    ca-certificates &&\
  #--
  # update certificates anyway in case ca-certificates was already installed
  update-ca-certificates &&\
  # install docker-ce
  apt-get install -y \
    gnupg \
    lsb-release &&\
  mkdir -p /etc/apt/keyrings &&\
  curl -fsSL https://download.docker.com/linux/debian/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg  &&\
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
  apt-get update &&\
  apt-get install -y \
    docker-ce-cli &&\
  # clean apt
   apt-get -y clean &&\
   rm -rf /var/lib/apt/lists/* &&\
  #
  true

#-------------------------------------------------------------------------------
# Terraform
#-------------------------------------------------------------------------------
RUN \
  # download and install gpg key
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &&\
  #
  # install deb repository
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list &&\
  #
  # install terraform
  apt-get update &&\ 
  apt-get install terraform &&\
  #
  # clean apt
   apt-get -y clean &&\
   rm -rf /var/lib/apt/lists/* &&\
  #
  true
#-------------------------------------------------------------------------------
# post install
#-------------------------------------------------------------------------------
ENV VIRTUAL_ENV=/opt/toolset
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV ANSIBLE_FORCE_COLOR=1
ENV SHELL /bin/bash

#-------------------------------------------------------------------------------
# check version
#-------------------------------------------------------------------------------
RUN \
  echo "[INFO] python version " && python --version &&\
  echo "[INFO] pip version " && pip --version &&\
  echo "[INFO] ansible version " && ansible --version &&\
  echo "[INFO] molecule version " && molecule --version &&\
  echo "[INFO] yamllint version " && yamllint --version &&\
  echo "[INFO] docker version " && docker --version &&\
  echo "[INFO] git version " && git --version &&\
  true

#-------------------------------------------------------------------------------
# entrypoint and CMD
#-------------------------------------------------------------------------------
CMD /bin/bash
