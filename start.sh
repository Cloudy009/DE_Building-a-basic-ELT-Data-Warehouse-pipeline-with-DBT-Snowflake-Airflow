#!/bin/bash

# Init DB metadata nếu chưa có
airflow db init

# Tạo user admin (chỉ tạo nếu chưa tồn tại)
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin


# Khởi chạy Scheduler ở background
airflow scheduler &

# Khởi chạy Webserver (UI) ở foreground
exec airflow webserver --host 0.0.0.0 --port $PORT
