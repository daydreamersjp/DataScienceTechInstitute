# Connecting Python to SQL Server with pyodbc library.

<br>

## Connecting to SQL Server and Getting a Table
After importing pyodbc library by `import pyodbc`, `pyodbc.connect(...)` will give you an access to SQL data base. Here's a sample code to kick off SQL query and get all records with all columns from `dbo.Customer` to a pandas dataframe object `customerDf`.


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

<br>

## Parameters of pyodbc

Here, the parameter of pyodbc is what you need to change according to your database configuration. You see what your `SERVER` and `DATABASE` are when you launch SQL database. 

<br>

To know your `DRIVER` on Windows, go to Control Panel > System and Security > Administrative Tools > ODBC Data Sources, and then you can find your ODBC driver on Drivers tab.

<br>

<img src="https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/DataWrangling/MiniProject/ODBC%20Data%20Source%20Administrator.jpg" width="400">

<br>

List of ODBC drivers is also available through pyodbc command on Python. ```pyodbc.drivers()``` gives you a list of ODBC drivers such as ```['SQL Server',
 'MySQL ODBC 8.0 ANSI Driver',
 'MySQL ODBC 8.0 Unicode Driver',
 'ODBC Driver 13 for SQL Server',
 'SQL Server Native Client 11.0',
 'SQL Server Native Client RDA 11.0',
 'ODBC Driver 17 for SQL Server']```
 on my PC.

<br>



## Time to Play Around with Pandas Datafram

Now, you can have a pandas dataframe having data of your SQL database table. It is your time to show your pandas data wrangling skill. Here's some example to get the customer list who bought every product.

<br>

```python
import pyodbc
import pandas as pd
from pandas import merge

conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=LAPTOP-A3NFG0UM;DATABASE=S19SQLPlayground_Seb;Trusted_Connection=yes;')
cursor = conn.cursor()

# Import tables to pandas Dataframe
sqlGetCustomers = "SELECT * FROM dbo.Customer;";
cursor.execute(sqlGetCustomers)
customersData = cursor.fetchall()
customersDf = pd.read_sql(sqlGetCustomers,conn)

sqlGetProducts = "SELECT * FROM dbo.Product;";
cursor.execute(sqlGetProducts)
productsData = cursor.fetchall()
productsDf = pd.read_sql(sqlGetProducts,conn)

sqlGetPurchases = "SELECT * FROM dbo.Purchase;";
cursor.execute(sqlGetPurchases)
purchasesData = cursor.fetchall()
purchasesDf = pd.read_sql(sqlGetPurchases,conn)

conn.close()

# Create Cartesian Product for CustomerId and ProductId
customersDf["key"] = 1; productsDf["key"]=1
custprodCartesianDf = merge(customersDf,productsDf,on='key')[['CustomerId', 'ProductId']]

# Column 'Purchased' on custprodCartesianDf is True when the CustomerId purchased the ProductId, based on PurchasesDf.
custprodCartesianDf['Purchased'] = custprodCartesianDf.apply(tuple, 1).isin(purchasesDf[['CustomerId', 'ProductId']].apply(tuple, 1))

# Column 'NotPurchasedAll' on customersDf is True when the CustomerId does not purchase all products recorded in ProductsDf.
customersDf['NotPurchasedAll'] = customersDf[['CustomerId']].isin(custprodCartesianDf.query('Purchased==False')[['CustomerId']].values.ravel())

# Return pandas DataFrame with CustomerId who purchased all products.
customersDf.query('NotPurchasedAll==False')[['CustomerId']].reindex()
```

<br>

[Jupyter Notebook version](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/DataWrangling/MiniProject/Mini%20project.ipynb) here.

<br>

## Pulling Customer List Who Purchased All Products Is Easier in SQL Query

By the way, the example case such as pulling customers who purchased the all products based on product list and purchase history records is not necessarily easy on pandas wrangling, but is on SQL if you use ```WHERE NOT EXISTS```. 

Here's how to do in SQL query.

```sql
SELECT x.*
FROM (
	SELECT *
	FROM dbo.Customer as a
	WHERE NOT EXISTS(
		SELECT *
		FROM dbo.Product as b
		WHERE NOT EXISTS
		(
			SELECT *
			FROM
				dbo.Purchase as c
				WHERE
				c.CustomerId = a.CustomerId AND
				c.ProductId = b.ProductId
		)
	)
) AS x
```
