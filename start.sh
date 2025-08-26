# #!/bin/bash
# set -e

# # Khởi tạo Airflow DB (chạy 1 lần)
# airflow db init

# # Start webserver trên cổng Render cung cấp
# exec airflow webserver --port $PORT
#!/bin/bash

# Init DB metadata nếu chưa có
airflow db init

# Khởi chạy Scheduler ở background
airflow scheduler &

# Khởi chạy Webserver (UI) ở foreground
exec airflow webserver --port 8080
