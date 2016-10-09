FROM microsoft/azure-cli

MAINTAINER juliens@microsoft.com

ADD src/* /usr/local/bin/azaddspn.sh

RUN chmod +x /usr/local/bin/azaddspn.sh

ENTRYPOINT ["/usr/local/bin/azaddspn.sh"]
