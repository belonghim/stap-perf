#FROM registry.access.redhat.com/ubi8/ubi:latest
FROM registry.redhat.io/rhel8/support-tools:latest
ARG VERSION
ARG FW
ARG RHELVER
LABEL run "podman run -it --entrypoint /bin/bash --name stap-image-container --privileged --ipc=host --net=host --pid=host -e HOST=/host -e NAME=NAME -e IMAGE=IMAGE -v /run:/run -v /var/log:/var/log -v /etc/machine-id:/etc/machine-id -v /etc/localtime:/etc/localtime -v /:/host IMAGE"
RUN echo '[rhel8-hack]' > /etc/yum.repos.d/hack.repo && \
  echo 'name = Red Hat Eng Hack' >> /etc/yum.repos.d/hack.repo && \
  echo "baseurl = http://download-node-02.eng.bos.redhat.com/released/RHEL-8/${RHELVER}.0/BaseOS/$(echo $VERSION | awk -F. '{print $NF}')/os/" >> /etc/yum.repos.d/hack.repo && \
  echo 'enabled = 1' >> /etc/yum.repos.d/hack.repo && \
  echo 'gpgcheck = 0' >> /etc/yum.repos.d/hack.repo && \
  echo '[rhel8-appstream-hack]' >> /etc/yum.repos.d/hack.repo && \
  echo 'name = Red Hat Eng Hack - AppStream' >> /etc/yum.repos.d/hack.repo && \
  echo "baseurl = http://download-node-02.eng.bos.redhat.com/released/RHEL-8/${RHELVER}.0/AppStream/$(echo $VERSION | awk -F. '{print $NF}')/os/" >> /etc/yum.repos.d/hack.repo && \
  echo 'enabled = 1' >> /etc/yum.repos.d/hack.repo && \
  echo 'gpgcheck = 0' >> /etc/yum.repos.d/hack.repo && \
  yum --disableplugin=subscription-manager --setopt=tsflags=nodocs --allowerasing -y upgrade \
  && yum --disableplugin=subscription-manager --setopt=tsflags=nodocs -y install \
    bcc-tools \
    ethtool \
    iotop \
    iproute-tc \
    less \
    net-tools \
    perf \
    python38 \
    strace \
    bzip2 \
    systemtap \
    tmux \
    tcpdump \
  && yum --disableplugin=subscription-manager --setopt=tsflags=nodocs -y install \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-core-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-modules-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-devel-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-debuginfo-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/kernel/$(echo $VERSION | cut -d- -f1)/$(echo $VERSION | cut -d- -f2 | sed 's/\.[^.]*$//')/$(echo $VERSION | awk -F. '{print $NF}')/kernel-debuginfo-common-$(echo $VERSION | awk -F. '{print $NF}')-$VERSION.rpm \
  http://download-node-02.eng.bos.redhat.com/brewroot/packages/linux-firmware/$(echo $FW | cut -d- -f1)/$(echo $FW | cut -d- -f2)/noarch/linux-firmware-$FW.noarch.rpm \
  && yum clean all \ 
  && mkdir /workdir
VOLUME [ "/workdir" ]
WORKDIR "/workdir"
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY probe.stap /usr/local/bin/probe.stap
COPY dropwatch.stp /usr/local/bin/dropwatch.stp
COPY dropwatch2_skb_by_port.stp /usr/local/bin/dropwatch2_skb_by_port.stp
COPY tcp-reset.stp /usr/local/bin/tcp-reset.stp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#CMD ["stap","-g","--all-modules","/usr/local/bin/probe.stap"]
CMD ["stap","--all-modules","/usr/local/bin/dropwatch.stp"]
