
# Sanity Checks 

## 1: Check that the correct hosts appear for the group 

```shell
$ ansible-inventory -i ./inventory/ --graph --yaml
@all:
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

## 2: Check the group vars are correctly setup for hosts  

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
