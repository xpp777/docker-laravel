#!/bin/sh
set -e

php /var/www/html/artisan cache:clear
php /var/www/html/artisan config:cache
php /var/www/html/artisan route:cache
php /var/www/html/artisan view:cache

# 添加 cron 任务
crontab /etc/cron.d/cronjob
echo "Caches cleared and re-cached successfully."
# 启动 supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
