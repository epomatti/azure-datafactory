# azure-datafactory


```sh
curl ifconfig.me
```

Approve the managed private endpoints.


https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page


```sh
curl -L https://d37ci6vzurychx.cloudfront.net/trip-data/fhvhv_tripdata_2023-01.parquet -o nyc-trip-records.parquet
```


Upload the file replacing the `account-name` option value:

```sh
az storage blob upload --auth-mode login -f ./nyc-trip-records.parquet -c synapse -n database/nyc-trip-records.parquet --account-name <storage-name>
```




https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/query-parquet-files




https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-sql-data-warehouse?tabs=data-factory#managed-identity

```sql
CREATE USER [your_resource_name] FROM EXTERNAL PROVIDER;
EXEC sp_addrolemember db_owner, [your_resource_name];
```
