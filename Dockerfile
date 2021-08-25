FROM registry.access.redhat.com/ubi8/ubi:latest

RUN yum --disableplugin=subscription-manager -y install httpd 
#  && curl -L http://copr.fedoraproject.org/coprs/openscapmaint/openscap-latest/repo/epel-8/openscapmaint-openscap-latest-epel-8.repo -o /etc/yum.repos.d/openscapmaint-openscap-latest-epel-8.repo \
#  && yum -y install openscap openscap-utils scap-security-guide --skip-broken

#COPY index.html /var/www/html/
COPY *.html /var/www/html/

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && chgrp -R 0 /var/log/httpd /var/run/httpd \
  && chmod -R g=u /var/log/httpd /var/run/httpd 

EXPOSE 8080
USER 1001
CMD httpd -D FOREGROUND
