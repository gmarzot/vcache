FROM nodered/node-red:latest
RUN npm install node-red-dashboard
RUN npm install node-red-contrib-redis
RUN npm install node-red-node-ui-iframe
RUN npm install node-red-contrib-os
RUN npm install node-red-contrib-fs-ops
RUN npm install node-red-contrib-counter
USER root
RUN apk add salt-minion 
