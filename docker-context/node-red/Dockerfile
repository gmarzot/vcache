FROM nodered/node-red:latest
RUN npm install node-red-contrib-os
RUN npm install node-red-contrib-fs-ops
RUN npm install node-red-contrib-cpu
RUN npm install node-red-contrib-uuid
RUN npm install node-red-contrib-rate
RUN npm install node-red-contrib-counter
RUN npm install node-red-contrib-redis
RUN npm install node-red-node-redis
RUN npm install node-red-node-daemon
RUN npm install node-red-node-smooth
RUN npm install node-red-dashboard
RUN npm install node-red-node-ui-iframe
RUN npm install node-red-node-ui-table
RUN npm install redis
RUN npm install systeminformation
RUN npm install uuid

# uncomment the following 2 lines for production
#COPY ./node-red/mgmt-data /data
#VOLUME /data

COPY ./node-red/etc/vcache /etc/vcache

COPY ./perllib /usr/local/perllib
COPY ./scripts/* /usr/local/bin

USER root
RUN apk add bash 
RUN apk add perl 
RUN apk add gettext
RUN apk add salt-minion 

COPY ./node-red/etc/salt/minion.tmpl /etc/salt/minion.tmpl
COPY ./node-red/custom-entrypoint.sh /usr/src/node-red/custom-entrypoint.sh

ENTRYPOINT ["/usr/src/node-red/custom-entrypoint.sh"]
