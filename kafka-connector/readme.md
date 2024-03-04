# Kafka connector installation with Strimzi operator on K8s

## Created k8s namepsace
```sh
kubectl create namespace kafka
```

Directory structure
```
├── database
│   ├── database.yaml
│   ├── populate_database.sql
│   ├── secret.yaml
│   └── service.yaml
└── kafka-connector
    ├── connector
    │   ├── debezium-postgres-connector.yaml
    │   ├── debezium-ui.yaml
    │   ├── jdbc-connector.yaml
    │   └── kafka-connect.yaml
    ├── Dockerfile
    ├── kafka
    │   ├── connector-config-role.yaml
    │   ├── database-secrect.yaml
    │   ├── kafka.yaml
    │   └── role-binding.yaml
    ├── my-plugins
    │   ├── debezium-connector-postgres
    │   └── jbdc-connect
    └── readme.md
```
## Install Strimzi 
```
//add helm chart repo for Strimzi
helm repo add strimzi https://strimzi.io/charts/

//install it! (I have used strimzi-kafka as the release name)
helm install strimzi-kafka strimzi/strimzi-kafka-operator -n kafka
```

Check installed resource 
```sh
kubectl get crd | grep strimzi
```

## Install Kafka
```sh
kubectl apply -f ./kafka-connector/kafka/ -n kafka
```

## Install Kafka connect

### Install database for testing

- Installation
```sh
kubectl apply -f ./database/ -n kafka
```

- Population
```sql
CREATE SCHEMA IF NOT EXISTS datalake;

CREATE TABLE IF NOT EXISTS datalake.user_signed_up_at (
  id SERIAL PRIMARY KEY,
  user_id INT,
  date INT,
  month INT,
  year INT,
  created_time BIGINT
);

INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('63', 16, 2, 2024, 1708000211691)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('4', 16, 2, 2024, 1707992271360)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('38', 16, 2, 2024, 1707997211872)
;
INSERT INTO datalake.user_signed_up_at (user_id, date, month, year, created_time)
VALUES 
('13', 16, 2, 2024, 1707993732710)
;
```

### Add plugin

- Download required plugins in to `my-plugins` folder.
- Created image based on `Dockerfile`
- Push to registry

- Install connect cluster based on pushed image (currently my own [image](https://hub.docker.com/repository/docker/hieuung/jbdc-kafka-connect/general))
```sh
kubectl apply -f ./kafka-connector/connector/kafka-connect.yaml -n kafka
```
- Verify installation 
```sh
kubectl get KafkaConnect -n kafka
```
### JBDC connector
- Query-based CDC method 
- Direct query on the source database (database performance)
- Required incremental columns in the capture table 
(update time, ...)
- Can't capture `DELETE` operator
- Installation
```sh
kubectl apply -f ./kafka-connector/connector/jdbc-connector.yaml -n kafka
```
- Verify connector 
```sh
kubectl get KafkaConnector -n kafka
```

### Debezium
- Logs-based CDC method 
- Using wal_log in the source database (Increase database performance)
- Not required incremental columns in the capture table 
(update time, ...)
- Capture all changes including `DELETE`
- Installation
```sh
kubectl apply -f ./kafka-connector/connector/debezium-postgres-connector.yaml -n kafka
```
- Verify connector 
```sh
kubectl get KafkaConnector -n kafka
```
- Viewing connector in Debezium UI
 
![Debezium postgres connector](<../database/asset/Screenshot from 2024-02-26 00-47-25.png>)

- Viewing Capture message in Offset explore

![Offset expolore](<../database/asset/Screenshot from 2024-02-26 00-50-24.png>)

- Sample message
```json
{
  "schema": {
    "type": "struct",
    "fields": [
      {
        "type": "struct",
        "fields": [
          {
            "type": "int32",
            "optional": false,
            "default": 0,
            "field": "id"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "user_id"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "date"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "month"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "year"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "created_time"
          }
        ],
        "optional": true,
        "name": "debezium.datalake.user_signed_up_at.Value",
        "field": "before"
      },
      {
        "type": "struct",
        "fields": [
          {
            "type": "int32",
            "optional": false,
            "default": 0,
            "field": "id"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "user_id"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "date"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "month"
          },
          {
            "type": "int32",
            "optional": true,
            "field": "year"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "created_time"
          }
        ],
        "optional": true,
        "name": "debezium.datalake.user_signed_up_at.Value",
        "field": "after"
      },
      {
        "type": "struct",
        "fields": [
          {
            "type": "string",
            "optional": false,
            "field": "version"
          },
          {
            "type": "string",
            "optional": false,
            "field": "connector"
          },
          {
            "type": "string",
            "optional": false,
            "field": "name"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "ts_ms"
          },
          {
            "type": "string",
            "optional": true,
            "name": "io.debezium.data.Enum",
            "version": 1,
            "parameters": {
              "allowed": "true,last,false,incremental"
            },
            "default": "false",
            "field": "snapshot"
          },
          {
            "type": "string",
            "optional": false,
            "field": "db"
          },
          {
            "type": "string",
            "optional": true,
            "field": "sequence"
          },
          {
            "type": "string",
            "optional": false,
            "field": "schema"
          },
          {
            "type": "string",
            "optional": false,
            "field": "table"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "txId"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "lsn"
          },
          {
            "type": "int64",
            "optional": true,
            "field": "xmin"
          }
        ],
        "optional": false,
        "name": "io.debezium.connector.postgresql.Source",
        "field": "source"
      },
      {
        "type": "string",
        "optional": false,
        "field": "op"
      },
      {
        "type": "int64",
        "optional": true,
        "field": "ts_ms"
      },
      {
        "type": "struct",
        "fields": [
          {
            "type": "string",
            "optional": false,
            "field": "id"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "total_order"
          },
          {
            "type": "int64",
            "optional": false,
            "field": "data_collection_order"
          }
        ],
        "optional": true,
        "name": "event.block",
        "version": 1,
        "field": "transaction"
      }
    ],
    "optional": false,
    "name": "debezium.datalake.user_signed_up_at.Envelope",
    "version": 1
  },
  "payload": {
    "before": null,
    "after": {
      "id": 1,
      "user_id": 63,
      "date": 16,
      "month": 2,
      "year": 2024,
      "created_time": 1708000211691
    },
    "source": {
      "version": "2.5.1.Final",
      "connector": "postgresql",
      "name": "debezium",
      "ts_ms": 1708869224058,
      "snapshot": "false",
      "db": "postgres",
      "sequence": "[null,\"38176320\"]",
      "schema": "datalake",
      "table": "user_signed_up_at",
      "txId": 774,
      "lsn": 38176320,
      "xmin": null
    },
    "op": "c",
    "ts_ms": 1708869224780,
    "transaction": null
  }
}
```
