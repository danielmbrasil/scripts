#!/bin/bash
#
# Install PHP 7.4 and some extensions
apt update
apt install zip -y
php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-xml php7.4-bcmath php7.4-zip -y
