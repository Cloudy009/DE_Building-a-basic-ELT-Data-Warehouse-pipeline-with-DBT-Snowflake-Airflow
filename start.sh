#!/bin/bash

airflow db init

if ! airflow users list | grep -q "$AIRFLOW_ADMIN_USERNAME"; then
    airflow users create \
        --username "$AIRFLOW_ADMIN_USERNAME" \
        --firstname "$AIRFLOW_ADMIN_FIRSTNAME" \
        --lastname "$AIRFLOW_ADMIN_LASTNAME" \
        --role Admin \
        --email "$AIRFLOW_ADMIN_EMAIL" \
        --password "$AIRFLOW_ADMIN_PASSWORD"
fi

airflow scheduler &

exec airflow webserver --host 0.0.0.0 --port $PORT