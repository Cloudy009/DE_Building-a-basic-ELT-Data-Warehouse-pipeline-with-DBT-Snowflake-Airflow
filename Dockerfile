FROM quay.io/astronomer/astro-runtime:10.3.0

# RUN curl -sSL https://install.astronomer.io | bash

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-snowflake && deactivate

RUN chmod +x start.sh

# FROM astrocrpublic.azurecr.io/runtime:3.0-9

# RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake && deactivate

# CMD ["airflow", "webserver", "-p", "8080"]
