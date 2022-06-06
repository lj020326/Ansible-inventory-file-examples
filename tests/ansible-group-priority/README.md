
Variable merge precedence in group vars
===

The purpose of the examples covered is to understand how to leverage child group vars especially with respect to deriving the expected behavior for variable merging. 

The following examples/sections will explore common group prioritization use cases:

* [Example 1: Test with child groups having same depth](./example1/README.md)

* [Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs](./example2/README.md)

* [Example 3: Validate prioritization with child groups having different depths](./example3/README.md)

* [Example 4: Validate prioritization with child groups](./example4/README.md)

* [Example 5: playbook using inventory](./example5/README.md)

* [Example 6: Using group_by key groups with ansible_group_priority](./example6/README.md)

The ansible environment used to perform the examples:

```output
$ git clone https://github.com/lj020326/ansible-inventory-file-examples.git
$ cd ansible-inventory-file-examples
$ git switch develop-lj
$ cd tests/ansible-group-priority
$ ansible --version
ansible [core 2.12.3]
  config file = None
  configured module search path = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/ljohnson/.pyenv/versions/3.10.2/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/ljohnson/.ansible/collections:/usr/share/ansible/collections
  executable location = /Users/ljohnson/.pyenv/versions/3.10.2/bin/ansible
  python version = 3.10.2 (main, Feb 21 2022, 15:35:10) [Clang 13.0.0 (clang-1300.0.29.30)]
  jinja version = 3.1.0
  libyaml = True
```

