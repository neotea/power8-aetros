FROM jarvice/ubuntu-ibm-mldl-ppc64le 
MAINTAINER AETROS

ENV DEBIAN_FRONTEND noninteractive

# Nimbix
ADD https://github.com/nimbix/image-common/archive/master.zip /tmp/nimbix.zip
WORKDIR /tmp
RUN apt-get -y update && apt-get -y install zip unzip openssh-server ssh infiniband-diags perftest libibverbs-dev libmlx4-dev libmlx5-dev sudo iptables curl wget vim python 
RUN unzip nimbix.zip && rm -f nimbix.zip
RUN /tmp/image-common-master/setup-nimbix.sh

# Nimbix JARVICE emulation
EXPOSE 22
RUN mkdir -p /usr/lib/JARVICE && cp -a /tmp/image-common-master/tools /usr/lib/JARVICE
# RUN ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.png && ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.ico
WORKDIR /usr/lib/JARVICE/tools/noVNC/utils
RUN ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/websockify.py && ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/wsproxy.py
WORKDIR /tmp
RUN cp -a /tmp/image-common-master/etc /etc/JARVICE && chmod 755 /etc/JARVICE && rm -rf /tmp/image-common-master
RUN mkdir -m 0755 /data && chown nimbix:nimbix /data

# install git
RUN sudo apt-get -y update && sudo apt-get -y install git 

# Install AETROS
VOLUME /tmp
WORKDIR /tmp
USER nimbix
RUN sudo pip3 install pip --upgrade && sudo pip3 install aetros --upgrade
RUN sudo pip install pip --upgrade && sudo pip install aetros --upgrade