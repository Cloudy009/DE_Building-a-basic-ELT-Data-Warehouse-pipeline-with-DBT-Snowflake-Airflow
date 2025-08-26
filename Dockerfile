## Chạy local
# FROM quay.io/astronomer/astro-runtime:10.3.0

# RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake && deactivate

# RUN chmod +x start.sh


FROM quay.io/astronomer/astro-runtime:10.3.0

# Cài thêm dbt vào cùng environment của Airflow
RUN pip install --no-cache-dir dbt-snowflake

# Copy toàn bộ project vào container
WORKDIR /usr/local/airflow
COPY . .

# Cho phép start.sh chạy được
RUN chmod +x start.sh

# Lệnh mặc định khi container start
CMD ["./start.sh"]
