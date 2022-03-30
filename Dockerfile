# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: Dockerfile
# Author.....: Stefan Oehrli (oes) stefan.oehrli@accenture.com
# Editor.....: Stefan Oehrli
# Date.......: 2022.03.25
# Purpose....: Dockerfile to build 389-ds cross platform image
# Notes......: Crossplatform builds
# 
# docker buildx build -f Dockerfile --platform linux/arm64 -t oehrlis/389ds:arm64 --output type=docker .
# docker buildx build -f Dockerfile --platform linux/amd64 -t oehrlis/389ds:amd64 --output type=docker .
# docker buildx build -f Dockerfile --platform linux/amd64 --platform linux/arm64 -t oehrlis/389ds --push .
#
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Pull base image
# ---------------------------------------------------------------------------
FROM  oraclelinux:8-slim

# Maintainer
# ---------------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@accenture.com"

# expose the LDAP and LDAPS Ports
EXPOSE 3389 3636

# Install 389-ds packages
RUN microdnf module enable 389-ds && \
    microdnf --assumeyes upgrade && \
    microdnf --assumeyes install 389-ds-base openssl && \
    microdnf clean all

# configure environment
RUN mkdir -p /data/config && \
    mkdir -p /data/ssca && \
    mkdir -p /data/run && \
    mkdir -p /var/run/dirsrv && \
    ln -s /data/config /etc/dirsrv/slapd-localhost && \
    ln -s /data/ssca /etc/dirsrv/ssca && \
    ln -s /data/run /var/run/dirsrv && \
    chmod -R 777 /data /etc/dirsrv

# Environment variables required for this build 
# ENV DS_DM_PASSWORD
# ENV DS_MEMORY_PERCENTAGE
# ENV DS_REINDEX
# ENV SUFFIX_NAME
# ENV DS_STARTUP_TIMEOUT

# 389-ds data volume for LDAP instance and configuration files
VOLUME /data

# run container health check
HEALTHCHECK --start-period=5m --timeout=5s --interval=5s --retries=2 \
    CMD /usr/libexec/dirsrv/dscontainer -H

# Define default command to start 389-ds instance
CMD [ "/usr/libexec/dirsrv/dscontainer", "-r" ]
# --- EOF --------------------------------------------------------------
