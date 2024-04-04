from http import HTTPStatus
from os import getcwd, getenv, makedirs
from os.path import exists, join
from time import sleep
from duckdb import IOException

from basedosdados import read_sql
from dotenv import load_dotenv
from duckdb import connect, close
from pandas import DataFrame, json_normalize
from requests import get
from requests.exceptions import HTTPError


def connect_to_database():
    """Connects to the database named 'dados.db'"""
    path = join(getcwd(), 'data')
    if not exists(path): makedirs(path)
    return connect(path + '/dados.db')

def load_project_id():
    """Loads the project ID from a .env file"""
    load_dotenv(getcwd() + '/.env')
    return getenv('PROJECT_ID_GOOGLE_CLOUD')

def execute_query_on_google_big_query(query: str) -> DataFrame:
    """Executes a query and returns the result as a pandas DataFrame"""
    try:
        return read_sql(query, load_project_id()).astype(str)
    except Exception as e:
        print(f'Error when trying to query BigQuery: {e}')

def create_or_truncate_tables(conn:connect):
    """Create or truncate data of tables"""
    path = join(getcwd(), 'sql')
    with open(f'{path}/create_tables.sql', encoding='utf-8') as file:
        try:
            query = file.read()
            conn.sql(query)
        except Exception as e:
            print(f'Error while trying to create or truncate table: {e}')
        

def insert_data(conn: connect, table_name: str, df: DataFrame):
    """Inserts data from a DataFrame into a table"""
    try:
        conn.sql(f"INSERT INTO {table_name} SELECT * FROM df")
    except Exception as e:
        print(f'Error while trying to insert data into the table: {e}')

def fetch_gasoline_data(conn: connect):
    """Fetches gasoline price data from 2005 to 2022 and inserts it into 'gasolina' table"""

    df = execute_query_on_google_big_query(
        """
        SELECT data_coleta, id_municipio, preco_venda
        FROM `basedosdados.br_anp_precos_combustiveis.microdados`
        WHERE ( ano BETWEEN 2005 AND 2022 ) AND produto = 'Gasolina'
        """
    )
    insert_data(conn, 'gasoline', df)

def fetch_inflation_data(conn: connect):
    """Fetches inflation data from 2005 to 2022 and inserts it into 'inflacao' table"""

    df = execute_query_on_google_big_query(
        """
        SELECT ano, mes, indice
        FROM `basedosdados.br_ibge_ipca.mes_brasil`
        WHERE ano BETWEEN 2005 AND 2022
        """
    )
    insert_data(conn, 'inflation', df)

def fetch_cities_data(url: str, conn: connect, retry_codes: list = None):
    """Fetches city data from the provided URL with retry logic and returns a 
    DataFrame and inserts it into 'cidades' table"""

    if retry_codes is None:
        retry_codes = [
            HTTPStatus.INTERNAL_SERVER_ERROR,
            HTTPStatus.BAD_GATEWAY,
            HTTPStatus.SERVICE_UNAVAILABLE,
            HTTPStatus.GATEWAY_TIMEOUT,
        ]
    for _ in range(3):
        try:
            response = get(url)
            response.raise_for_status()
            df = json_normalize(response.json()).astype(str)
            df.drop_duplicates(subset=['municipio-id'], inplace=True)
            return insert_data(conn, 'cities', df)
        except HTTPError as exc:
            code = exc.response.status_code
            if code in retry_codes:
                print(f"Error {code} encountered. Retrying in 10 seconds...")
                sleep(10)
                continue
            raise exc

def create_view(conn:connect):
    """View table with data processed and ready to be consumed."""
    path = join(getcwd(), 'sql')
    with open(f'{path}/transform.sql', encoding='utf-8') as file:
        try:
            query = file.read()
            conn.sql(f'CREATE OR REPLACE VIEW view_inflated_gasoline AS {query}')
        except Exception as e:
            print(f'Error when creating the view: {e}')

def load_table_processed(conn:connect):
    path = join(getcwd(), 'data')
    conn.sql(
        f'''
            COPY (SELECT * FROM view_inflated_gasoline)
            TO '{path}/inflated_gasoline.parquet' (FORMAT 'parquet');
            
            COPY (SELECT * FROM cities)
            TO '{path}/cities.parquet' (FORMAT 'parquet');
        '''
    )

def main():
    """Main function that establishes connection, fetches and inserts data"""

    print('Start database connection.')
    conn = connect_to_database()

    print('Creating or truncating database tables.')
    create_or_truncate_tables(conn)

    print('Query and insert data from project tables.')
    fetch_gasoline_data(conn)
    fetch_inflation_data(conn)
    fetch_cities_data('https://servicodados.ibge.gov.br/api/v1/localidades/municipios?view=nivelado', conn)

    print('Creating the clean and processed table.')
    create_view(connect_to_database())

    print('Loanding data in .parquet file.')
    load_table_processed(conn)

    print('Execution completed.')

    close(conn)

if __name__ == '__main__':
    main()
