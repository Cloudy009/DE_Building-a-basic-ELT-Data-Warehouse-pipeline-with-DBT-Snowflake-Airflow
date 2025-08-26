#!/bin/bash

# --- Khởi tạo DB Airflow
/usr/local/bin/airflow db init

# --- Tạo user admin nếu chưa tồn tại
if ! /usr/local/bin/airflow users list | grep -q "$AIRFLOW_ADMIN_USERNAME"; then
    /usr/local/bin/airflow users create \
        --username "$AIRFLOW_ADMIN_USERNAME" \
        --firstname "$AIRFLOW_ADMIN_FIRSTNAME" \
        --lastname "$AIRFLOW_ADMIN_LASTNAME" \
        --role Admin \
        --email "$AIRFLOW_ADMIN_EMAIL" \
        --password "$AIRFLOW_ADMIN_PASSWORD"
fi

# --- Chạy Scheduler
/usr/local/bin/airflow scheduler &

# --- Chạy Webserver
exec /usr/local/bin/airflow webserver --host 0.0.0.0 --port $PORT
