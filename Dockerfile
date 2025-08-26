# # Chạy local
# FROM quay.io/astronomer/astro-runtime:10.3.0

# RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake && deactivate

# Base image nhẹ hơn Astro Runtime
# Base image nhẹ hơn Astro Runtime
FROM python:3.11-slim

# Thiết lập AIRFLOW_HOME
ENV AIRFLOW_HOME=/usr/local/airflow
ENV PATH=$AIRFLOW_HOME/.local/bin:$PATH

# Cài các dependencies OS cần thiết
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cài Airflow
RUN pip install --no-cache-dir "apache-airflow[postgres,celery]==2.9.3"

# Tạo virtualenv cho DBT
RUN python -m venv /usr/local/airflow/dbt_venv
RUN /bin/bash -c "source /usr/local/airflow/dbt_venv/bin/activate && pip install --no-cache-dir dbt-snowflake && deactivate"

# Tạo các thư mục Airflow
RUN mkdir -p $AIRFLOW_HOME/dags $AIRFLOW_HOME/logs $AIRFLOW_HOME/plugins

# Copy DAGs và DBT project
COPY dags/ $AIRFLOW_HOME/dags/

# Entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# CMD chạy entrypoint (Scheduler + Webserver)
CMD ["/start.sh"]

