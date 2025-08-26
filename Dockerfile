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

# Cài Airflow global + Snowflake provider
RUN pip install --no-cache-dir "apache-airflow[postgres,celery]==2.9.3" \
    && pip install --no-cache-dir "apache-airflow-providers-snowflake"

# Tạo venv riêng cho DBT
RUN python -m venv $AIRFLOW_HOME/dbt_venv
RUN /bin/bash -c "source $AIRFLOW_HOME/dbt_venv/bin/activate && pip install --no-cache-dir dbt-snowflake && deactivate"

# Tạo các thư mục Airflow
RUN mkdir -p $AIRFLOW_HOME/dags $AIRFLOW_HOME/logs $AIRFLOW_HOME/plugins

# Copy DAGs và requirements.txt (nếu có)
COPY dags/ $AIRFLOW_HOME/dags/
COPY requirements.txt $AIRFLOW_HOME/requirements.txt

# Nếu requirements.txt có package DBT → cài trong venv DBT
RUN /bin/bash -c "source $AIRFLOW_HOME/dbt_venv/bin/activate && \
    pip install --no-cache-dir -r $AIRFLOW_HOME/requirements.txt && deactivate"

# Entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
