FROM jarvice/ubuntu-ibm-mldl-ppc64le 
MAINTAINER AETROS

ENV DEBIAN_FRONTEND noninteractive




# base OS
ENV DEBIAN_FRONTEND noninteractive
ADD https://github.com/nimbix/image-common/archive/master.zip /tmp/nimbix.zip
WORKDIR /tmp
RUN apt-get update && apt-get -y install sudo zip unzip && unzip nimbix.zip && rm -f nimbix.zip
RUN /tmp/image-common-master/setup-nimbix.sh
RUN touch /etc/init.d/systemd-logind && apt-get -y install module-init-tools xz-utils vim openssh-server libpam-systemd libmlx4-1 libmlx5-1 iptables infiniband-diags build-essential curl libibverbs-dev libibverbs1 librdmacm1 librdmacm-dev rdmacm-utils libibmad-dev libibmad5 byacc flex git cmake screen grep curl wget vim python && apt-get clean && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Nimbix JARVICE emulation
EXPOSE 22
RUN mkdir -p /usr/lib/JARVICE && cp -a /tmp/image-common-master/tools /usr/lib/JARVICE
RUN cp -a /tmp/image-common-master/etc /etc/JARVICE && chmod 755 /etc/JARVICE && rm -rf /tmp/image-common-master
RUN chown nimbix:nimbix /data
RUN sed -ie 's/start on.*/start on filesystem/' /etc/init/ssh.conf




# Nimbix
# ADD https://github.com/nimbix/image-common/archive/master.zip /tmp/nimbix.zip
# WORKDIR /tmp
# RUN apt-get -y update && apt-get -y install zip unzip openssh-server ssh infiniband-diags perftest libibverbs-dev libmlx4-dev libmlx5-dev sudo iptables curl wget vim python 
# RUN unzip nimbix.zip && rm -f nimbix.zip
# RUN /tmp/image-common-master/setup-nimbix.sh

# Nimbix JARVICE emulation
# EXPOSE 22
# RUN mkdir -p /usr/lib/JARVICE && cp -a /tmp/image-common-master/tools /usr/lib/JARVICE
# RUN ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.png && ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.ico
# WORKDIR /usr/lib/JARVICE/tools/noVNC/utils
# RUN ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/websockify.py && ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/wsproxy.py
# WORKDIR /tmp
# RUN cp -a /tmp/image-common-master/etc /etc/JARVICE && chmod 755 /etc/JARVICE && rm -rf /tmp/image-common-master
# RUN mkdir -m 0755 /data && chown nimbix:nimbix /data

# install git & Co
RUN sudo apt-get -y update && sudo apt-get -y install git libblas-dev liblapack-dev libatlas-base-dev gfortran

# Install AETROS
VOLUME /tmp
WORKDIR /tmp
USER nimbix
# RUN sudo pip3 install pip --upgrade && sudo pip3 install aetros --upgrade
RUN sudo pip install pip --upgrade && sudo pip install aetros --upgrade