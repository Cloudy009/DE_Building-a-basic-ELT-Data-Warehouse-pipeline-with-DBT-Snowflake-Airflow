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

# Tạo thư mục Airflow
RUN mkdir -p $AIRFLOW_HOME/dags $AIRFLOW_HOME/logs $AIRFLOW_HOME/plugins

# Copy requirements
COPY requirements.txt $AIRFLOW_HOME/requirements.txt

# Cài tất cả packages từ requirements.txt
RUN pip install --no-cache-dir -r $AIRFLOW_HOME/requirements.txt

# Copy DAGs và DBT project
COPY dags/ $AIRFLOW_HOME/dags/

# Copy script khởi chạy
COPY start.sh /start.sh
RUN chmod +x /start.sh

# CMD chạy entrypoint (Scheduler + Webserver)
CMD ["/start.sh"]
