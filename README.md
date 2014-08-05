Docker - ELK stack
---
Current ELK stack running in Docker using supervisord to control the processes.
* ElasticSearch (1.3.1)
* Logstash (1.4.2)
* Kibana (3.1.0)

This is going to set up:

* sshd
* elasticsearch
* logstash with a UDP connector on port 5228 suitable for using with https://rubygems.org/gems/logstash-logger
* nginx
* kibana

You'll probably want to mount a data volume or host volume to /var/lib/elasticsearch (for its data)

Running
---
docker run -d -p 2222:22 -p 88:88 -p 9200:9200 -p 9300:9300 -p 5228:5228/udp -v /data:/var/lib/elasticsearch -name elk slowteetoe/docker-elk

TODO
---
* expose a volume to allow mapping to a block storage device on a cloud provider
* add additional logstash options
* 
