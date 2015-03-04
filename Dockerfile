FROM ruby:2.1
MAINTAINER Nikita K. <mendor@yuuzukiyo.net>

RUN apt-get update
RUN apt-get install -y sendmail

ADD ./ /opt/allisdown
WORKDIR /opt/allisdown
RUN ./geminstall.sh

EXPOSE 6006
ENTRYPOINT thin -C conf/thin_dockerized.conf.yml start
