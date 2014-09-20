FROM phusion/baseimage:0.9.9

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y python-software-properties

# php/5.4.32 and nginx/1.6.1
RUN add-apt-repository -y ppa:ondrej/php5-oldstable && add-apt-repository -y ppa:nginx/stable

RUN apt-get update && apt-get install -y \
	php5-cli \
	php5-fpm \
	php5-mysql \
	php5-curl \
	php5-gd \
	php5-mcrypt \
	nginx

# todo: copy config files from conf dir
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN sed -i "s/;listen.owner = www-data/listen.owner = www-data/" /etc/php5/fpm/pool.d/www.conf
RUN sed -i "s/;listen.group = www-data/listen.group = www-data/" /etc/php5/fpm/pool.d/www.conf
RUN sed -i "s/;listen.mode = 0660/listen.mode = 0660/" /etc/php5/fpm/pool.d/www.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir /var/www && chown www-data:www-data /var/www
ADD conf/nginx/default /etc/nginx/sites-available/default

RUN mkdir /etc/service/nginx
ADD run/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

RUN mkdir /etc/service/phpfpm
ADD run/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run

EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*