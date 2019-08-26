# Connecting Python to SQL Server with pyodbc library.

<br>

## 1. Connecting SQL Database

After importing pyodbc library by `import pyodbc`, `pyodbc.connect(...)` will give you an access to SQL data base. Here's a sample code to kick off SQL query and get all records with all columns from `dbo.Customer` as a pandas dataframe object `customerDf`.


```python
import pyodbc
import pandas as pd

conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=LAPTOP-A3NFG0UM;DATABASE=S19SQLPlayground_Seb;Trusted_Connection=yes;')
cursor = conn.cursor()


sqlGetCustomers = "SELECT * FROM dbo.Customer;";
cursor.execute(sqlGetCustomers)
customersData = cursor.fetchall()
customersDf = pd.read_sql(sqlGetCustomers,conn)
```


Here, the parameter of pyodbc is what you change according to your database configuration. 

- DRIVER: 
