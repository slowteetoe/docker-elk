Docker - ElasticSearch / Logstash / Kibana
---
Current ELK stack running in Docker using supervisord to control the processes

This is going to set up:

* sshd
* elasticsearch
* logstash with a UDP connector on port 5228
* nginx
* kibana

Running
---
docker run -d -p 2222:22 -p 88:88 -p 9200:9200 -p 9300:9300 -p 5228:5228/udp slowteetoe/docker-elk
