
# Inventory Queries/Checks 

## Inventory Environment Level queries

### 1: hosts in groups 

```shell
$ ansible-inventory -i ./inventory/ENV_DEV --graph --yaml
@all:
  |--@app_123:
  |  |--@app_123_dev:
  |  |  |--appvm01.dev.example.int
  |  |--@app_123_prod:
  |  |--@app_123_test:
  |--@app_dotnet:
  |  |--@app_123:
  |  |  |--@app_123_dev:
  |  |  |  |--appvm01.dev.example.int
  |  |  |--@app_123_prod:
  |  |  |--@app_123_test:
  |--@env_dev:
  |  |--@app_123_dev:
  |  |  |--appvm01.dev.example.int
  |  |--appvm01.dev.example.int
  |  |--appvm02.dev.example.int
  |--@ungrouped:

```


## 2: Check the groups for hosts  

Group based query:
```shell
$ ansible -i ./inventory/ENV_DEV -m debug -a var=group_names all
appvm02.dev.example.int | SUCCESS => {
    "group_names": [
        "env_dev"
    ]
}
appvm01.dev.example.int | SUCCESS => {
    "group_names": [
        "app_123",
        "app_123_dev",
        "app_dotnet",
        "env_dev"
    ]
}

```

```shell
$ ansible -i ./inventory/ENV_DEV -m debug -a var=app_env all
appvm01.dev.example.int | SUCCESS => {
    "app_env": "dev"
}
appvm02.dev.example.int | SUCCESS => {
    "app_env": "dev"
}
```


## Inventory Root Level queries

The root inventory should only apply to AWX 'job templates' that meet the following requirements:

- The job is 'non-mutable' such that it does not make any change to any host target.
- The job risk level is minimal such that it can run across multiple environments independent from CICD infosec/requirements
- only inventory scans and related use-cases usually fit into this case.
- the job must run across environments for a specific reason/purpose. 
  Jobs usually fitting this use case are:
  - migration related - e.g., job to migrate/synchronize configuration from env1 to env2 
  - promotion related - e.g., job to promote configuration from env1 to env2 

```shell
$ ansible-inventory -i ./inventory/ --graph --yaml
@all:
  |--@app_123:
  |  |--@app_123_dev:
  |  |  |--appvm01.dev.example.int
  |  |--@app_123_prod:
  |  |  |--appvm01.example.int
  |  |--@app_123_test:
  |  |  |--appvm01.test.example.int
  |--@app_dotnet:
  |  |--@app_123:
  |  |  |--@app_123_dev:
  |  |  |  |--appvm01.dev.example.int
  |  |  |--@app_123_prod:
  |  |  |  |--appvm01.example.int
  |  |  |--@app_123_test:
  |  |  |  |--appvm01.test.example.int
  |--@env_dev:
  |  |--@app_123_dev:
  |  |  |--appvm01.dev.example.int
  |  |--appvm01.dev.example.int
  |  |--appvm02.dev.example.int
  |--@env_prod:
  |  |--@app_123_prod:
  |  |  |--appvm01.example.int
  |  |--appvm01.example.int
  |  |--appvm02.example.int
  |--@env_test:
  |  |--@app_123_test:
  |  |  |--appvm01.test.example.int
  |  |--appvm01.test.example.int
  |  |--appvm02.test.example.int
  |--@ungrouped:

```

## 2: Check the host groups  

Group based query:
```shell
$ ansible -i ./inventory/ -m debug -a var=group_names env_dev
appvm01.dev.example.int | SUCCESS => {
    "group_names": [
        "app_123",
        "app_123_dev",
        "app_dotnet",
        "env_dev"
    ]
}
appvm02.dev.example.int | SUCCESS => {
    "group_names": [
        "env_dev"
    ]
}

```

## 3: Check the host group vars 

```shell
$ ansible -i ./inventory/ -m debug -a var=app_env all
appvm01.example.int | SUCCESS => {
    "app_env": "prod"
}
appvm02.example.int | SUCCESS => {
    "app_env": "prod"
}
appvm01.dev.example.int | SUCCESS => {
    "app_env": "dev"
}
appvm02.dev.example.int | SUCCESS => {
    "app_env": "dev"
}
appvm01.test.example.int | SUCCESS => {
    "app_env": "test"
}
appvm02.test.example.int | SUCCESS => {
    "app_env": "test"
}

```

```shell
$ ansible -i ./inventory/ -m debug -a var=testvar,test_groupvar all
appvm01.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG_APP_123', 'BASE_CONFIG_APP_123')"
}
appvm02.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG', 'BASE_CONFIG')"
}
appvm01.dev.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG_APP_123', 'BASE_CONFIG_APP_123')"
}
appvm02.dev.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG', 'BASE_CONFIG')"
}
appvm01.test.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG_APP_123', 'BASE_CONFIG_APP_123')"
}
appvm02.test.example.int | SUCCESS => {
    "testvar,test_groupvar": "('BASE_CONFIG', 'BASE_CONFIG')"
}

```


Host based query:
```shell
ansible -i ./inventory/ -m debug -a var=group_names appvm01.test.example.int
appvm01.test.example.int | SUCCESS => {
    "group_names": [
        "app_123",
        "app_123_test",
        "app_dotnet",
        "env_test"
    ]
}
```
