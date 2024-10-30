import psycopg2

# Database connection details
host = "ecommerce-db.cry2qk8ius2x.us-east-1.rds.amazonaws.com"
port = "5432"  # Default PostgreSQL port
database = "ecommercedb"
user = "kurac5user"
password = "kurac5password"

# Establish the connection
conn = psycopg2.connect(
    host=host,
    database=database,
    user=user,
    password=password
)

# Create a cursor object
cur = conn.cursor()
cur.execute("SELECT * FROM my_table;")

# Fetch the result of the query
rows = cur.fetchall()
