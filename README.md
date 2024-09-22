# ADF ETL

Identify the IP address that will be administering the resources:

```sh
curl ifconfig.me
```

Create the `.auto.tfvars` file:

```sh
cp config/template.tfvars .auto.tfvars
```

Set the required variables:

```terraform
subscription_id    = "<subscriptionId>"
allowed_public_ips = ["<your ip>"]
```

Create the resources:

```sh
terraform init
terraform apply -auto-approve
```

## Private Endpoint

Approve the managed private endpoints generated for:

- Data lake
- Synapse

## Data set

Using [NYC taxi dataset][1] for this project.

Create the data directory and download the database file:

```sh
mkdir nyctls
curl -L https://d37ci6vzurychx.cloudfront.net/trip-data/fhvhv_tripdata_2023-01.parquet -o nyctls/nyc-trip-records.parquet
```

Create the file system and upload the file replacing the `account-name` option value:

```sh
az storage fs create --auth-mode login -n database --account-name <storage-name>
az storage blob upload --auth-mode login -f ./nyctls/nyc-trip-records.parquet -c synapse -n database/nyc-trip-records.parquet --account-name <storage-name>
```

## Synapse

### Lake database

Create a new **Lake database**:

- Name: Database1
- Linked service: The data lake storage
- Input folder: synapse/database
- Data format: Parquet

Create a new **Table** from the data lake:

- External tablet name: nyc_taxi
- Linked service: The data lake storage
- Input file: synapse/database/nyc-trip-records.parquet

### Spark



## Reference

- [Copy and transform data in Azure Synapse Analytics by using Azure Data Factory or Synapse pipelines](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-sql-data-warehouse?tabs=data-factory#managed-identity)
- [Quickstart: Create a new lake database leveraging database templates](https://learn.microsoft.com/en-us/azure/synapse-analytics/database-designer/quick-start-create-lake-database)


[1]: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
