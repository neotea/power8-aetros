FROM ppc64le/ubuntu:16.04
MAINTAINER Nimbix, Inc.

ENV DEBIAN_FRONTEND noninteractive
ADD https://github.com/nimbix/image-common/archive/master.zip /tmp/nimbix.zip
WORKDIR /tmp
RUN apt-get update && apt-get -y install zip unzip openssh-server ssh infiniband-diags perftest libibverbs-dev libmlx4-dev libmlx5-dev sudo iptables curl wget vim python && apt-get clean
RUN unzip nimbix.zip && rm -f nimbix.zip
RUN /tmp/image-common-master/setup-nimbix.sh

WORKDIR /tmp
ENV CUDA_REPO_URL http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/ppc64el/cuda-repo-ubuntu1604_8.0.61-1_ppc64el.deb
ENV NVML_REPO_URL http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/ppc64el/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_ppc64el.deb
RUN curl -O ${CUDA_REPO_URL} && dpkg --install *.deb && rm -rf *.deb
RUN curl -O ${NVML_REPO_URL} && dpkg --install *.deb && rm -rf *.deb
RUN apt-get update && apt-get -y install cuda-toolkit-8-0 libcudnn5-dev libcudnn6-dev && apt-get clean
ENV CUDA_REPO_URL ""
ENV NVML_REPO_URL ""

# Hack to allow builds in Docker container
# XXX: this should be okay even if the host driver is rev'd, since the JARVICE
# runtime actually binds in the host version anyway
WORKDIR /tmp
RUN apt-get download nvidia-361 && dpkg --unpack nvidia-361*.deb && rm -f nvidia-361*.deb && rm -f /var/lib/dpkg/info/nvidia-361*.postinst
RUN apt-get -yf install && apt-get clean && ldconfig -f /usr/lib/nvidia-361/ld.so.conf

# Nimbix JARVICE emulation
EXPOSE 22
RUN mkdir -p /usr/lib/JARVICE && cp -a /tmp/image-common-master/tools /usr/lib/JARVICE
RUN ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.png && ln -s /usr/lib/JARVICE/tools/noVNC/images/favicon.png /usr/lib/JARVICE/tools/noVNC/favicon.ico
WORKDIR /usr/lib/JARVICE/tools/noVNC/utils
RUN ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/websockify.py && ln -s websockify /usr/lib/JARVICE/tools/noVNC/utils/wsproxy.py
WORKDIR /tmp
RUN cp -a /tmp/image-common-master/etc /etc/JARVICE && chmod 755 /etc/JARVICE && rm -rf /tmp/image-common-master
RUN mkdir -m 0755 /data && chown nimbix:nimbix /data

# for building CUDA code later
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/stubs

# install git
RUN sudo apt-get -y update && sudo apt-get -y install git 

# update java
RUN sudo apt-get -y update && sudo apt-get -y install openjdk-8-jdk

# configure java
RUN echo $(update-alternatives --list java)
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-ppc64el/
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH ${JAVA_HOME}/bin:$PATH

# install bazel

RUN git clone https://github.com/ibmsoe/bazel
RUN cd bazel && git checkout v0.2.0-ppc && ./compile.sh
 
# Build bazel with the following command:
# RUN ./compile.sh

# install tensorflow GPU
RUN cd ..
RUN git clone --recurse-submodules https://github.com/tensorflow/tensorflow
RUN cd tensorflow
RUN git checkout r1.3

RUN git cherry-pick ce70f6cf842a46296119337247c24d307e279fa0  # Needed for compilation on PPC
RUN git cherry-pick f1acb3bd828a73b15670fc8019f06a5cd51bd564  # Have a performance fix
RUN git cherry-pick 9b6215a691a2eebaadb8253bd0cf706f2309a0b8  # Improve performance by detecting number of cores

RUN bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package 

RUN sudo pip install /tmp/tensorflow_pkg/tensorflow*.whl