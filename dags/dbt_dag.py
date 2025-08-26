# import os
# from datetime import datetime

# from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
# from cosmos.profiles import SnowflakeUserPasswordProfileMapping


# profile_config = ProfileConfig(
#     profile_name="default",
#     target_name="dev",
#     profile_mapping=SnowflakeUserPasswordProfileMapping(
#         conn_id="snowflake_conn", 
#         profile_args={"database": "dbt_db", "schema": "dbt_schema"},
#     )
# )

# dbt_snowflake_dag = DbtDag(
#     project_config=ProjectConfig("/usr/local/airflow/dags/dbt/data_pipeline_with_dbt_snowflake",),
#     operator_args={"install_deps": True},
#     profile_config=profile_config,
#     execution_config=ExecutionConfig(dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",),
#     schedule_interval="@daily",
#     start_date=datetime(2023, 9, 10),
#     catchup=False,
#     dag_id="dbt_dag",
# )

from airflow import DAG
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
import yaml, os

# Thư mục chứa DBT project (nơi có dbt_project.yml)
DBT_DIR = "/usr/local/airflow/dags/dbt"

def generate_profiles_yml(**context):
    """
    Sinh file profiles.yml từ Airflow Connection (snowflake_conn)
    """
    hook = SnowflakeHook(snowflake_conn_id="snowflake_conn")
    conn = hook.get_connection("snowflake_conn")
    extra = conn.extra_dejson

    profile = {
        "data_pipeline_with_dbt_snowflake": {
            "target": "dev",
            "outputs": {
                "dev": {
                    "type": "snowflake",
                    "account": extra.get("account"),
                    "user": conn.login,
                    "password": conn.password,
                    "role": extra.get("role"),
                    "database": extra.get("database"),
                    "warehouse": extra.get("warehouse"),
                    "schema": conn.schema or "dbt_schema",
                    "insecure_mode": extra.get("insecure_mode", False),
                }
            }
        }
    }

    os.makedirs(DBT_DIR, exist_ok=True)
    with open(os.path.join(DBT_DIR, "profiles.yml"), "w") as f:
        yaml.dump(profile, f, default_flow_style=False)


with DAG(
    "dbt_snowflake_dag",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
    tags=["dbt", "snowflake"],
) as dag:

    # Task 1: Sinh profiles.yml
    generate_profiles = PythonOperator(
        task_id="generate_profiles_yml",
        python_callable=generate_profiles_yml,
    )

    # Task 2: Chạy dbt run trong venv dbt_venv
    dbt_run = BashOperator(
    task_id="dbt_run",
    bash_command=(
        "source /usr/local/airflow/dbt_venv/bin/activate && "
        "dbt run --project-dir /usr/local/airflow/dags/dbt/data_pipeline_with_dbt_snowflake "
        "--profiles-dir /usr/local/airflow/dags/dbt"
    ),
)

    generate_profiles >> dbt_run
