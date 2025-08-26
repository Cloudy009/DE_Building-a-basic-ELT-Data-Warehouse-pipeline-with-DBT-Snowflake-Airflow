#!/bin/bash
set -e

# Khởi tạo Airflow DB (chạy 1 lần)
airflow db init

# Start webserver trên cổng Render cung cấp
exec airflow webserver --port $PORT
