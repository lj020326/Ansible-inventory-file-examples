
# Example 1: Test with child groups having same depth

One might observe what is believed to be unexpected results when `ansible_group_priority` is used in inventory groups that have a parent/child relationship. 

For example, create an inventory structurally that looks like this:

```
  |--@top_group:
  |  |--@override:
  |  |  |--@cluster:
  |  |  |  |--host1
  |  |--@product:
  |  |  |--@product1:
  |  |  |  |--host1
  |  |  |--@product2:
  |  |  |  |--host2
  |--@ungrouped:
```

The inventory implementing the aforementioned hierarchy as an ini inventory [hosts.ex1.ini](./hosts.ex1.ini):

```ini
[top_group:vars]
test=top_group
ansible_connection=local
ansible_group_priority=1

[top_group:children]
product
override

[product:vars]
test="product"
ansible_group_priority=2

[product:children]
product1
product2

[product1]
host1

[product2]
host2

[product1:vars]
test="product1"
ansible_group_priority=3

[product2:vars]
test="product2"
ansible_group_priority=3

[override:vars]
test="override"
ansible_group_priority=9

[override:children]
cluster

[cluster]
host1

[cluster:vars]
test="cluster"
ansible_group_priority=10

```

Now run a simple query on the variable `test` for host1 and observe the results of the query:

```output
ansible -i hosts.ex1.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

So far so good, since the `cluster` group priority is '10'. 

The same results can be confirmed when you convert the same inventory to yaml as [hosts.ex1.yml](./hosts.ex1.yml):

```output
ansible -i hosts.ex1.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```



## References

* https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-variables-are-merged
* [combine_vars utility function](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/utils/vars.py#L81)
* https://github.com/ansible/ansible/blob/devel/lib/ansible/inventory/group.py
* https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/plugins/vars/host_group_vars.py
* https://stackoverflow.com/questions/38120793/ansible-group-vars-priority
* [Managing "nested" group in Ansible YAML inventory files](https://github.com/lj020326/ansible-datacenter/blob/main/docs/ansible-nested-groups-in-YAML-inventory-files.md)
* 

