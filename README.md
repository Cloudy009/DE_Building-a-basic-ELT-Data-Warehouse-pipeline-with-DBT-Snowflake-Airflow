# Overview

Welcome to Astronomer!  
This project was generated after you ran `astro dev init` using the Astronomer CLI.  

This README describes the contents of the project, how to run Apache Airflow locally, and my **custom learning extension**:  
Building a basic ELT Data Warehouse pipeline with **dbt + Snowflake + Airflow**.

---

# Project Contents

Your Astro project contains the following files and folders:

- **dags/**: Python files for Airflow DAGs.  
  Default DAG: `example_astronauts` → A simple ETL demo with the Open Notify API.

- **Dockerfile**: Defines the Astro Runtime image.  
  (I customized it later to install `dbt-snowflake`).

- **include/**: Extra project files (empty by default).

- **packages.txt**: OS-level dependencies (empty by default).

- **requirements.txt**: Python packages.  
  (I customized it with `astronomer-cosmos`, `apache-airflow-providers-snowflake`).

- **plugins/**: Custom/community plugins (empty by default).

- **airflow_settings.yaml**: Local-only configs for Connections, Variables, Pools.

---

# Deploy Your Project Locally

Start Airflow:

```bash
astro dev start
```

This will spin up **five Docker containers**:

- Postgres → Airflow Metadata DB  
- Scheduler → Monitors and triggers tasks  
- DAG Processor → Parses DAGs  
- API Server → Hosts UI + API  
- Triggerer → Runs deferred tasks  

When ready, access:  
- Airflow UI: [http://localhost:8080](http://localhost:8080)  
- Postgres DB: `localhost:5432/postgres` (user: `postgres`, pw: `postgres`)  

⚠️ If ports are busy, free them or [change ports](https://www.astronomer.io/docs/astro/cli/troubleshoot-locally#ports-are-not-available-for-my-local-airflow-webserver).

---

# Deploy Your Project to Astronomer

If you have an Astronomer account, push your code directly to a Deployment.  
Docs: [Deploy to Astronomer](https://www.astronomer.io/docs/astro/deploy-code/).

---

# Custom Learning: Build an ELT Pipeline with dbt + Snowflake + Airflow

This project was **extended for study purposes** to practice modern Data Engineering workflows.  
Reference tutorial: [Code Along - Build an ELT Pipeline in 1 Hour](https://bittersweet-mall-f00.notion.site/Code-along-build-an-ELT-Pipeline-in-1-Hour-dbt-Snowflake-Airflow-cffab118a21b40b8acd3d595a4db7c15).

## Step 1. Setup Snowflake

```sql
-- create resources
use role accountadmin;
create warehouse dbt_wh with warehouse_size='x-small';
create database if not exists dbt_db;
create role if not exists dbt_role;

-- grant privileges
grant role dbt_role to user <your_user>;
grant usage on warehouse dbt_wh to role dbt_role;
grant all on database dbt_db to role dbt_role;

-- schema
use role dbt_role;
create schema if not exists dbt_db.dbt_schema;
```

## Step 2. Configure dbt Profile

File: `dbt_profile.yaml`

```yaml
models:
  snowflake_workshop:
    staging:
      materialized: view
      snowflake_warehouse: dbt_wh
    marts:
      materialized: table
      snowflake_warehouse: dbt_wh
```

## Step 3. Create Sources + Staging Models

- `models/staging/tpch_sources.yml`  
- `models/staging/stg_tpch_orders.sql`  
- `models/staging/stg_tpch_line_items.sql`

## Step 4. Define Macros

File: `macros/pricing.sql`

```sql
{% macro discounted_amount(extended_price, discount_percentage, scale=2) %}
    (-1 * {{extended_price}} * {{discount_percentage}})::decimal(16, {{ scale }})
{% endmacro %}
```

## Step 5. Transform to Facts & Marts

- `models/marts/int_order_items.sql`  
- `models/marts/int_order_items_summary.sql`  
- `models/marts/fct_orders.sql`  

These join staging → marts → fact tables.

## Step 6. Tests

- Generic YAML tests → `models/marts/generic_tests.yml`  
- Singular SQL tests → `tests/fct_orders_discount.sql`, `tests/fct_orders_date_valid.sql`

## Step 7. Integrate with Airflow

### Dockerfile update

```dockerfile
RUN python -m venv dbt_venv && source dbt_venv/bin/activate &&     pip install --no-cache-dir dbt-snowflake && deactivate
```

### requirements.txt

```
astronomer-cosmos
apache-airflow-providers-snowflake
```

### Airflow Connection

Create `snowflake_conn` in Airflow UI:

```json
{
  "account": "<account_locator>-<account_name>",
  "warehouse": "dbt_wh",
  "database": "dbt_db",
  "role": "dbt_role",
  "insecure_mode": false
}
```

### DAG: `dbt_dag.py`

```python
import os
from datetime import datetime
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_conn",
        profile_args={"database": "dbt_db", "schema": "dbt_schema"},
    ),
)

dbt_snowflake_dag = DbtDag(
    project_config=ProjectConfig("/usr/local/airflow/dags/dbt/data_pipeline"),
    operator_args={"install_deps": True},
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"
    ),
    schedule_interval="@daily",
    start_date=datetime(2023, 9, 10),
    catchup=False,
    dag_id="dbt_dag",
)
```

---

# Key Takeaways

✅ Learned how to:  
- Setup **Snowflake** warehouse, roles, schema  
- Use **dbt** for staging, marts, facts, macros, and tests  
- Run dbt in **Airflow** with Astronomer Cosmos  
- Build a **basic ELT data warehouse pipeline**  

👉 This project is for **learning purposes only**.  

---

# Contact

The Astronomer CLI is maintained by the Astronomer team.  
For issues: contact Astronomer support.  
"# DE_Building-a-basic-ELT-Data-Warehouse-pipeline-with-DBT-Snowflake-Airflow" 
"# DE_Building-a-basic-ELT-Data-Warehouse-pipeline-with-DBT-Snowflake-Airflow" 
"# DE-test" 
