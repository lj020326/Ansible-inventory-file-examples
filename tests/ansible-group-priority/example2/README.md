
# Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs

On the next test, unset `test` from `[cluster:vars]` in the ini inventory [hosts.ex2.ini](./hosts.ex2.ini):

```ini
;test="cluster"
ansible_group_priority=10
```

The expectation is that the variable set in the `override` group will win.
But it does not. Instead, `product1` wins:

```output
ansible -i hosts.ex2.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

It is not immediately intuitive why the `ansible_group_priority` does not result in the expected value.

The same results can be confirmed when you convert the same to a yaml inventory as [hosts.ex2.yml](./hosts.ex2.yml).

When querying variable `test` in [hosts.ex2.yml](./hosts.ex2.yml), the query results with the group 'product1' winning as the ini inventory example:

```output
ansible -i hosts.ex2.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```


## Groups and depth level

The group 'cluster' is below group 'override' which is directly below 'top_group' making it 3 levels below the 'all' group; in other terms, 'top_group' has a depth level of 3.

Similarly, the 'product1' group is below 'product' which is below 'top_group' making it 3 levels below the 'all' group; in other terms, 'product1' has a depth level of 3.

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


## Conclusions/Next Steps

The results from the change to the group results in unexpected results.

The [next example](../example3/README.md) will look to resolve this.


