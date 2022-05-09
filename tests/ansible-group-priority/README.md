
ansible_group_priority
===

Starting in Ansible version 2.4, users can use the group variable ansible_group_priority to change the merge order for groups of the same level (after the parent/child order is resolved).

ref: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-variables-are-merged

> Note:
> `ansible_group_priority` can only be set in the inventory source and not in 'group_vars/', as the variable is used in the loading of 'group_vars'.

## Testing

I'm getting some unexpected results when I use `ansible_group_priority` in inventory groups that have a parent/child relationship. I create an inventory structurally looks like this:

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

Inventory file 'hosts.ex1.ini' that implements the aforementioned hierarchy:
```
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

Query variable `test` for host1 and results of said query:

```
# ansible-inventory -i hosts.ex1.ini --list host1
ansible -i hosts.ex1.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

So far so good, since the `cluster` group priority is '10'. 

On the next test, unset `test` from `[cluster:vars]`

```
;test="cluster"
ansible_group_priority=10
```

The expectation is that the variable set in the `[override]` group will win.
But it does not. Instead, `product1` wins:

```
# ansible-inventory -i hosts.ex2.ini --list host1
ansible -i hosts.ex2.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

It is not immediately clear why `ansible_group_priority` is not set to the expected value.

## Further testing

In the last test, the group override is not at the same level as product. 

override is directly below top_group, while the product1 is group is below product which is below top_group.


When converting the initial hosts.ex1.ini to yaml in hosts.ex1.yml:

```yaml
all:
  children:
    top_group:
      vars:
        test: top_group
        ansible_connection: local
        ansible_group_priority: 1
      children:
        override:
          vars:
            test: "override"
            ansible_group_priority: 9
          children:
            cluster:
              vars:
                test: "cluster"
                ansible_group_priority: 10
              hosts:
                host1:
                  ansible_connection: local
                  test: cluster
        product:
          vars:
            test: "product"
            ansible_group_priority: 2
          children:
            product1:
              vars:
                test: "product1"
                ansible_group_priority: 3
              hosts:
                host1: {}
            product2:
              vars:
                test: "product2"
                ansible_group_priority: 3
              hosts:
                host2:
                  ansible_connection: local
                  test: product2
```

Query variable `test` for hosts.ex1.yml and the same results of said query:

```
# ansible-inventory -i hosts.ex1.yml --list host1
ansible -i hosts.ex1.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```



Viewing the parent/child hierarchy in a tree format visualizes this well:

```output
              [top_group]
                  |
        ----------------------
        |                    |
     [product]           [override]
         |                   |
    ------------       -------------
   |            |            |
[product1] [product2]    [cluster] 
   |                         |
 host1                     host1
```

It appears that priority does not work well with nested parent/child relationships.

## Testing without parent-child nested groups.

Consider the following case.

Remove the parent/child relationship of '[override]' from '[top_group]' group, in the following way:

```output
    [top_group]          [override] ansible_group_prioirty=10
         |                    |
     [product]           [cluster] ansible_group_prioirty=10
         |                    |
    ------------            host1
   |            |            
[product1] [product2]  
   |
  host1 
```

The inventory implementing this:

```
all:
  children:
    override:
      vars:
        test: "override"
        ansible_group_priority: 10
      children:
        cluster1:
          vars:
            test: "cluster1"
            ansible_group_priority: 10
          hosts:
            host1: {}
    top_group:
      vars:
        test: top_group
        ansible_connection: local
      children:
        product:
          vars:
            ansible_group_priority: 1
            test: "product"
          children:
            product1:
              vars:
                test: "product1"
              hosts:
                host1:
                  host1: {}
            product2:
              vars:
                test: "product2"
              hosts:
                host2: {}
```

Even in this case, the results are the same, the variable set in `product1` group always wins. 

Apparently even if the priority of '[override]' and all of its child groups were set to the highest, in this case, 10, that `product1` will still continue to win.




