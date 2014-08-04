# ELK stack starting from base-image (https://github.com/phusion/baseimage-docker)
FROM phusion/baseimage:0.9.12
MAINTAINER Steven Lotito "steven.lotito@alumni.pitt.edu

ENV HOME /root

# fix sources
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN sed 's/trusty universe/trusty universe multiverse/' -i /etc/apt/sources.list
RUN sed 's/trusty-updates universe/trusty universe multiverse/' -i /etc/apt/sources.list

# add repos from elasticsearch
ADD etc/apt/sources.list.d/elasticsearch.list /etc/apt/sources.list.d/
ADD etc/apt/sources.list.d/logstash.list /etc/apt/sources.list.d/
ADD etc/apt/sources.list.d/elasticsearch.list /etc/apt/sources.list.d/

RUN apt-get update

RUN apt-get install -y libreadline6 libreadline6-dev nginx openjdk-7-jre wget

# install/use supervisord
RUN apt-get install -y  supervisor openssh-server
RUN mkdir -p /var/log/supervisor
ADD etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/

# add keys for elasticsearch repos
RUN wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get update

# install elasticsearch
RUN apt-get install -y elasticsearch
RUN sed -i '/# cluster.name:.*/a cluster.name: elk' /etc/elasticsearch/elasticsearch.yml
ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/

# install logstash
RUN apt-get install -y logstash
COPY etc/logstash/conf.d/ /etc/logstash/conf.d/
ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/

# setup nginx for hosting kibana
RUN apt-get install -y apache2-utils # for htpasswd
RUN mkdir -p /var/www
ADD etc/nginx/conf.d/nginx.conf /etc/nginx/conf.d/
RUN htpasswd -cb /etc/nginx/conf.d/localhost.htpasswd kibana kibanapass
RUN echo "daemon off;" >> /etc/nginx/nginx.conf  # cannot run as daemon for supervisord
WORKDIR /opt
RUN wget -qO - https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz | tar -xz
RUN ln -s /opt/kibana-3.1.0 /var/www/kibana
ADD etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/

# clean stuff
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# let us SSH into the box
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN echo 'root:elkpass' |chpasswd   # you'll probably want to change this asap!

EXPOSE 22 88 9200 9300 5228/udp

CMD ["/usr/bin/supervisord"]