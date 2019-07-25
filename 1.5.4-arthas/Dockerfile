################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
FROM openjdk:8-jdk-alpine
# copy arthas
COPY --from=hengyunabc/arthas:latest /opt/arthas /opt/arthas


# Install requirements
RUN apk add --no-cache bash libc6-compat snappy 'su-exec>=0.2'
RUN apk add --no-cache sudo tini

ENV FLINK_INSTALL_PATH=/opt
ENV FLINK_HOME $FLINK_INSTALL_PATH/flink
ENV PATH $PATH:$FLINK_HOME/bin

# flink-dist can point to a directory or a tarball on the local system
 ARG flink_dist=NOT_SET

ADD $flink_dist $FLINK_INSTALL_PATH
RUN set -x && \
  ln -s $FLINK_INSTALL_PATH/flink-* $FLINK_HOME && \
  addgroup -S -g 9999 flink && adduser -D -S -H -u 9999 -G flink -h $FLINK_HOME flink && \
  chown -R flink:flink $FLINK_INSTALL_PATH/flink-* && \
  chown -h flink:flink $FLINK_HOME

ENTRYPOINT ["/sbin/tini", "--"]
RUN chmod +x /sbin/tini
COPY docker-entrypoint.sh /
RUN chmod 711 /docker-entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
EXPOSE 6123 8081
CMD ["help"]

