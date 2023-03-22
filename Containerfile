FROM quay.io/centos/centos:stream9

RUN curl -sL https://trunk.rdoproject.org/centos9-master/current/delorean.repo -o /etc/yum.repos.d/delorean.repo
RUN curl -sL https://trunk.rdoproject.org/centos9-master/delorean-deps.repo -o /etc/yum.repos.d/delorean-deps.repo
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf update -y

COPY extra-packages /
RUN dnf -y install $(<extra-packages) && dnf clean all
RUN rm /extra-packages

COPY requirements.txt /
RUN pip3 install -r /requirements.txt
RUN rm /requirements.txt

CMD ["bash", "entrypoint.sh"]
