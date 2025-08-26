#!/bin/bash

# Init DB metadata nếu chưa có
airflow db init

# Tạo user admin nếu chưa tồn tại, lấy thông tin từ biến môi trường
if ! airflow users list | grep -q "$AIRFLOW_ADMIN_USERNAME"; then
    airflow users create \
        --username "$AIRFLOW_ADMIN_USERNAME" \
        --firstname "$AIRFLOW_ADMIN_FIRSTNAME" \
        --lastname "$AIRFLOW_ADMIN_LASTNAME" \
        --role Admin \
        --email "$AIRFLOW_ADMIN_EMAIL" \
        --password "$AIRFLOW_ADMIN_PASSWORD"
fi

# Khởi chạy Scheduler ở background
airflow scheduler &

# Khởi chạy Webserver (UI) ở foreground
exec airflow webserver --host 0.0.0.0 --port $PORT
