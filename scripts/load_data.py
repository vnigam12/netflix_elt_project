import sqlalchemy as sal
from extract_data import get_data

engine = sal.create_engine('...')
conn = engine.connect()

df = get_data()
df.to_sql('netflix_raw', con = conn, index = False, if_exists = 'append')
conn.close()