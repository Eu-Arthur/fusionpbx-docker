#!/bin/bash
# run supervisord on background
supervisord -c /etc/supervisor/supervisord.conf &
# run php-fpm on foreground (PID1)
exec php-fpm
