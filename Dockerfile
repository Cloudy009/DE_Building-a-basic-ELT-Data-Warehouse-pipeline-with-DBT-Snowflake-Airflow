# # Chạy local
# FROM quay.io/astronomer/astro-runtime:10.3.0

# RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake && deactivate

# Base image nhẹ hơn Astro Runtime
FROM python:3.11-slim

# Thiết lập AIRFLOW_HOME và PATH
ENV AIRFLOW_HOME=/usr/local/airflow
ENV PATH=/usr/local/bin:$AIRFLOW_HOME/.local/bin:$PATH

# Cài OS dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev curl git \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt Airflow và các providers (bao gồm cả postgres và snowflake)
# Lưu ý: Lệnh này phải chạy ngoài môi trường ảo
RUN pip install --no-cache-dir "apache-airflow[postgres,celery]==2.9.3" \
    "apache-airflow-providers-snowflake"

# Tạo venv riêng cho DBT
RUN python -m venv $AIRFLOW_HOME/dbt_venv

# Copy requirements.txt và dags/
COPY requirements.txt $AIRFLOW_HOME/requirements.txt
COPY dags/ $AIRFLOW_HOME/dags/

# Cài đặt dependencies cho DBT vào môi trường ảo
RUN /bin/bash -c "source $AIRFLOW_HOME/dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-snowflake -r $AIRFLOW_HOME/requirements.txt && deactivate"

# Tạo các thư mục Airflow
RUN mkdir -p $AIRFLOW_HOME/logs $AIRFLOW_HOME/plugins

# Entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]