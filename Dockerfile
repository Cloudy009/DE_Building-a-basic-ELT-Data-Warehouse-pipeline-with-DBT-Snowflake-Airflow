## Chạy local
# FROM quay.io/astronomer/astro-runtime:10.3.0

# RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake && deactivate

# RUN chmod +x start.sh


FROM quay.io/astronomer/astro-runtime:10.3.0

# Cài thêm dbt-snowflake (cài trực tiếp vào venv chính của Astro)
RUN pip install --no-cache-dir dbt-snowflake

# Copy code vào thư mục Airflow home (theo chuẩn Astro)
WORKDIR /usr/local/airflow
COPY . .

# Copy script start.sh vào bin và set quyền thực thi
COPY --chmod=755 start.sh /usr/local/bin/start.sh

# Lệnh mặc định khi container start
CMD ["start.sh"]
