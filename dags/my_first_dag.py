from airflow.models import DAG 

from datetime import datetime 
default_arguments = {
    'owner': 'leonce',
    'email': 'leoncen0@gmail.com',
    'start_date': datetime(2022, 12, 4)
}

etl_dag = DAG('etl_workflow', default_args=default_arguments)