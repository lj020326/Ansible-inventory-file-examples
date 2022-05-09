
ansible_group_priority
===

Starting in Ansible version 2.4, users can use the group variable ansible_group_priority to change the merge order for groups of the same level (after the parent/child order is resolved).

> Note:
> `ansible_group_priority` can only be set in the inventory source and not in 'group_vars/', as the variable is used in the loading of 'group_vars'.


On this page:

* [Example 1: Test with child groups having same depth](#Example-01)

* [Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs](#Example-02)

* [Example 3: Validate prioritization with child groups having different depths](#Example-03)

* [Example 4: Validate prioritization with child groups](#Example-04)

* [Example 5: playbook using inventory](#Example-05)

* [Example 6: Using group_by key groups with ansible_group_priority](#Example-06)


## <a id="Example-01"></a>Example 1: Test with child groups having same depth

One might observe what is believed to be unexpected results when `ansible_group_priority` is used in inventory inventory groups that have a parent/child relationship. 

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

Now run a simple query on the variable `test` for host1 and observe the results of the query:

```
ansible -i hosts.ex1.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

So far so good, since the `cluster` group priority is '10'. 

The same results can be confirmed when you convert the same inventory to yaml as [hosts.ex1.yml](./hosts.ex1.yml):

```
ansible -i hosts.ex1.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

## <a id="Example-02"></a>Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs

On the next test, unset `test` from `[cluster:vars]` in the ini inventory [hosts.ex2.ini](./hosts.ex2.ini):

```
;test="cluster"
ansible_group_priority=10
```

The expectation is that the variable set in the `override` group will win.
But it does not. Instead, `product1` wins:

```
ansible -i hosts.ex2.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

It is not immediately intuitive why the `ansible_group_priority` does not result in the expected value.

The same results can be confirmed when you convert the same to a yaml inventory as [hosts.ex2.yml](./hosts.ex2.yml).

When querying variable `test` in [hosts.ex2.yml](./hosts.ex2.yml), the query results with the group 'product1' winning as the ini inventory example:

```
ansible -i hosts.ex2.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```


### Groups and depth level

The group 'cluster' is below group 'override' which is directly below 'top_group' making it 3 levels below the 'all' group, or put more simply as "3 levels deep".

Similarly, the 'product1' group is below 'product' which is below 'top_group' making it 3 levels below the 'all' group, or 3 levels deep.

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

## <a id="Example-03"></a>Example 3: Validate prioritization with child groups having different depths

In the next example, set the group 'override' such that it is not set at the same child 'depth' or 'level' as the 'product' group. 

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

As can be clearly seen above, the 'cluster' group has a child depth of 2 while the 'product1' and 'product2' groups each have child depths of 3.

The ini inventory implementing this hierarchy can be found in [hosts.ex3.ini](./hosts.ex2.ini):
The yaml inventory implementing this hierarchy can be found in [hosts.ex3.yml](./hosts.ex2.yml):

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


In this example, the results may not be what are expected, since the variable set in `product1` group always wins. 

Even if the priority of the 'override' group and all of its child groups were set to the highest, in this case, 10, the 'test' variable results with the `product1` group.

The priority does not follow an intuitive merge path.  The deepest child group gets set and if multiple child group peers exist at the same depth, then the one with the greatest priority in that peer depth group will be set.  

To summarize, the child group having the greatest child depth and greatest priority within that depth will always win.

## <a id="Example-04"></a>Example 4: Validate prioritization with child groups

The next example validates the following rule observed in the prior example:

>
> the child group having the greatest child depth and greatest priority within that depth will always win.

With the inventory used in the prior example 3 as the starting point, make the groups 'override', 'product1', and 'product2' have the same depth. 

Add a group 'foo' between 'override' and 'top_group', such that 'override' is the same depth, 3 levels deep, as 'product1' and 'product2'.  
Note the 'cluster' child group now has a depth of 4, resulting in it have the greatest depth path.

The resulting yaml inventory with this hierarchy can be found in [hosts.ex4.yml](./hosts.ex4.yml):

```yaml
all:
  children:
    top_group:
      vars:
        test: top_group
        ansible_connection: local
        ansible_group_priority: 1
      children:
        foo:
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
                    host1: {}
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
                  test: product2

```

The ini inventory implementing this hierarchy can be found in [hosts.ex4.ini](./hosts.ex4.ini):

```ini
[top_group:vars]
test=top_group
ansible_connection=local
ansible_group_priority=1

[top_group:children]
product
foo

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

[foo:children]
override

[cluster]
host1

[cluster:vars]
test="cluster"
ansible_group_priority=10
```

Since the 'cluster' group now has the greatest depth path, using the rule it would be expected that the 'test' variable value will be set to 'cluster'. 

In fact, the observed results are now consistent with the stated rule:

```output
ansible -i hosts.ex4.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
ansible -i hosts.ex4.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}

```

## <a id="Example-05"></a>Example 5: playbook using inventory

For the next example, use the inventory from example 4. 

Then setup the following [playbook](./example5/playbook.yml):

```yaml
- name: "Run play"
  hosts: all
  gather_facts: false
  connection: local
  tasks:
    - debug: var=test

```

Confirm that the results are as expected:

```output
ansible-playbook -i ./example5/hosts.ini ./example5/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Confirm that the results are as expected for the yaml inventory:

```output
ansible-playbook -i ./example5/hosts.yml ./example5/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Looks good since both results are as expected.

## <a id="Example-06"></a>Example 6: Using group_by key groups with ansible_group_priority

Copy the files used in the prior example for example 6.

Then modify the playbook to set the group_by key to 'cluster' for all hosts as follows:

```yaml
- name: "Run play"
  hosts: all
  gather_facts: false
  connection: local
  tasks:
    - name: Group hosts into 'cluster' group under 'override'
      group_by:
        key: "cluster"
        parents: "override"
    - debug: var=test
```

Confirm that the new value 'cluster' should now appear for the variable 'test' for both hosts.

```output
ansible-playbook -i ./example6/hosts.ini ./example6/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [Group hosts into 'cluster' group under 'override'] *****************************************************************************************************************************************************************************************************************
ok: [host1]
changed: [host2]

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "cluster"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Confirm that the results are as expected for the yaml inventory:

```output
ansible-playbook -i ./example6/hosts.yml ./example6/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [Group hosts into 'cluster' group under 'override'] *****************************************************************************************************************************************************************************************************************
ok: [host1]
changed: [host2]

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

While the ini inventory is as expected, the yaml inventory does not result as expected since the host2 did not appear with the 'test' variable set to 'cluster'.

TODO: Need to understand why group_by works for ini but does not work for yaml based inventory.

## Conclusion

In conclusion, from the testing done, the following deterministic rule/behavior is exhibited by the using ansible_group_priority with child groups:

* The child group having the greatest child depth and greatest priority among peer-level child groups having the same depth will win.

While the rule is deterministic, it may lead results as noted above that do not intuitively make sense.   E.g., using the rule just described, if a child group with depth 2 has ansible_group_priority of 10, it will lose to a child group with depth 3 that has ansible_group_priority set to 1.  This result was best demonstrated with example 2.

## References

* https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-variables-are-merged
* 
