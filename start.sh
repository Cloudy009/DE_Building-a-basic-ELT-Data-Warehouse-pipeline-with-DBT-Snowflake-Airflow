#!/bin/bash

# Init DB metadata nếu chưa có
airflow db init

# Khởi chạy Scheduler ở background
airflow scheduler &

# Khởi chạy Webserver (UI) ở foreground
exec airflow webserver --port $PORT
