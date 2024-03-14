
# Ansible group_vars examples

## Introduction to Ansible group_vars

In Ansible, we know that variables are very important as they store host-to-host data and usable to deploy some tasks based on remote host’s state-based. There are various ways to define variables like in the inventory file, in the playbook file, in a variable file imported in the playbook. Similarly, there is a way to define variables at a location from where the variables will be realized for a group of hosts. This location falls under group_vars and this can be under a predefined location. In this article, we will learn about group_vars with some examples and ways to use it.

### What is Ansible group_vars?

It uses hosts file and group_vars directory to set variables for host groups and deploying Ansible plays/tasks against each host/group. Files under group_var directory are named after the host group’s name or all, accordingly, the variables will be assigned to that host group or all the hosts.

Although you can store the variables in inventory files and playbooks, having stored and defined variables in separate files and that too on a host group basis, adds simplicity and makes it easy to recognize, then use.

Files under group_vars are generically used to store basic identifying variables and then leverage these with other desirable variables by using include_vars and var_files.

### How Does ANSIBLE group_vars work?

In this, `group_vars` directory is under Ansible base directory, which is by default ./inventory/. The files under `group_vars` can have extensions including ‘.yaml’, ‘.yml’, ‘.json’ or no file extension.

It loads hosts and group variable files by searching path which is relative to inventory file or playbook file. So which means if you have your hosts file at location ./inventory/hosts and there are three groups names `grp1`, `grp2`, and `grp3` in the hosts’ file. Then below three files will be loaded for a host, which belongs to all three groups, is targeted for playbook execution.

Similarly, other combinations of these files are used, based on the host’s mapping to groups in the host’s file.

-   ./inventory/group_vars/grp1.yaml
-   ./inventory/group_vars/grp2.yml
-   ./inventory/group_vars/grp3

If there is file ./inventory/group_vars/all present then variables in this file will be pulled for every execution. The definition of variables in these files is simple key: value pair format. An example is like below:

**Example**

file `./inventory/group_vars/grp1.yml`:
```yaml
---
fruit: apple
vegetable: potato
```

Also, there are a few points which should be noted when using group_vars:

-   We can create directories under the group named directory, it will read all the files under these directories in lexicographical
-   If there is some value which is true for your environment and for every server, the variable containing that value should be defined under `./inventory/group_vars/all` file
-   In AWS case, when we have a dynamic inventory where host groups are created and removed automatically, we need to tag the EC2 instances like “class: webserver”. Then variables defined under the `./inventory/group_vars/ec2_tag_class_webserver` will be located file.
-   If in hosts file, groups are organized in such an order that one group is a child of another, then the variables defined for children will have higher precedence over the variable with the same name defined for the parent
-   When the same host is defined for several groups on the same level of the parent-children hierarchy, the variable file precedence with being on the name of groups in alphabetic order. That means if a host is mapped under groups alpha, beta, and gamma. Then for this host variables under `./inventory/group_vars/gamma` will be pulled.
-   We can use Ansible Vault for these files under `group_vars`, to protect the confidential data.

### Examples

Now by using examples, we will try to learn about Ansible `group_vars`, which you might have to use in day to day operations. We will take some examples, but before going there, we will first understand our lab, we will use for testing purpose.

Here we define the control server named `ansible-controller` and two remotes hosts named `host-one` and `host-two`. We will create playbooks and run commands on theansible-controller node and see the results on remote hosts.

Also, `group_vars` directory is defined as ./inventory/group_vars. The inventory file is ./inventory/hosts.

## **Example #1**

We create three files named as below: –

-   ./inventory/group_vars/alpha.yml
-   ./inventory/group_vars/beta.yml
-   ./inventory/group_vars/gamma.yml

The hosts file `./inventory/hosts.yml` have the same groups named and the hosts mapping is like below

File `./inventory/hosts.yml`:
```yaml
---

all:
  children:
    ansible_controller:
      hosts:
        127.0.0.1: {}
    alpha:
      hosts:
        host-one: {}
    beta:
      hosts:
        host-two: {}
    gamma:
      hosts:
        host-one: {}
        host-two: {}
```

In this example, we put contents like below under ./inventory/group_vars/alpha.yml to define variables and other two files

-   ./inventory/group_vars/beta.yml     and
-   ./inventory/group_vars/gamma.yml are empty.


File `./inventory/group_vars/alpha.yml`:
```yaml
---

fruit: apple
vegetable: tomato
```

Now running debug module in ad-hoc commands below, we get the following output where we can see that only variable defined in the file ./inventory/group_vars/alpha.yml for alpha group means the host-one host will be pulled.

```shell
ansible-controller:[ansible-groupvars-examples](develop-lj)$ cd ./example1
ansible-controller:[example1](main)$ ansible alpha -i inventory/hosts.yml -m debug -a "var=fruit"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
host-one | SUCCESS => {
    "fruit": "apple"
}
ansible-controller:[example1](main)$ ansible beta -i inventory/hosts.yml -m debug -a "var=fruit"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
host-two | SUCCESS => {
    "fruit": "VARIABLE IS NOT DEFINED!"
}
ansible-controller:[example1](main)$ ansible gamma -i inventory/hosts.yml -m debug -a "var=fruit"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
host-one | SUCCESS => {
    "fruit": "apple"
}
host-two | SUCCESS => {
    "fruit": "VARIABLE IS NOT DEFINED!"
}
ansible-controller:[example1](main)$ 
```

## **Example #2**

In this example, we have a playbook with below

```yaml
---

- hosts: host-one
  tasks:
    - name: Here we copy the variable value to remote
      copy:
        content: "fruit variable valus is {{ fruit }}\n"
        dest: /tmp/sample.ini

```

To keep the example simple, we set the ansible connection to the localhost for the 2 example/demo logical hosts:

File `./inventory/host_vars/host-one.yml`:
```yaml
---

ansible_host: 127.0.0.1
ansible_connection: local

```

File `./inventory/host_vars/host-two.yml`:
```yaml
---

ansible_host: 127.0.0.1
ansible_connection: local

```

Also, the `group_vars` directory is defined as `./inventory/group_vars` and the files with content under this directory are listed as below:

-   cat ./inventory/group_vars/alpha.yml
-   cat ./inventory/group_vars/beta.yml
-   cat ./inventory/group_vars/gamma.yml

When running playbook like below, we get the following output where the variable value is copied to a file on the target host.

```shell
ansible-controller:[ansible-groupvars-examples](develop-lj)$ cd ./example2
ansible-controller:[example2](develop-lj)$ ansible-playbook -i inventory ansible_group_vars.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [host-one] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host host-one is using the discovered Python interpreter at /Users/ljohnson/.pyenv/shims/python3.11, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.15/reference_appendices/interpreter_discovery.html for more information.
ok: [host-one]

TASK [Here we copy the variable value to remote] *********************************************************************************************************************************************************
changed: [host-one]

PLAY RECAP ***********************************************************************************************************************************************************************************************
host-one                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-controller:[example2](develop-lj)$ 

```

On checking, we will see that the value of the variable is pulled from

-   ./inventory/group_vars/gamma.yml.

On checking, we will see that the results are set correctly:

```shell
ansible-controller:[example2](develop-lj)$ cat /tmp/sample.ini 
fruit variable valus is apple
ansible-controller:[example2](develop-lj)$ 

```


## **Example #3**

File `./inventory/hosts.yml`:
```yaml
---

all:
  children:
    ansible_controller:
      hosts:
        127.0.0.1: {}
    alpha:
      hosts:
        host-one: {}
    charlie:
      hosts:
        host-one: {}

```

Also, the `group_vars` directory is defined as `./inventory/group_vars`, which have files like below

```shell
ansible-controller:[ansible-groupvars-examples](develop-lj)$ cd example3
ansible-controller:[example3](develop-lj)$ find ./inventory/group_vars/ -type f
./inventory/group_vars/charlie/connection_setting.yml
./inventory/group_vars/alpha/db_settings.yml

```


The files under this directory have content like below:

```shell
ansible-controller:[example3](develop-lj)$ cat ./inventory/group_vars/alpha/db_settings.yml
---

username: testuser

ansible-controller:[example3](develop-lj)$ cat ./inventory/group_vars/charlie/connection_setting.yml 
---

port: 22

```

In this example, we have a playbook with below content:

File `ansible_group_vars_dir.yml`
```yaml
---

- hosts: host-one
  tasks:
    - name: Here we print the variables from different host groups
      debug:
        msg: "Username is {{ username }} and connection port is {{ port }}"

```

Using this playbook, we try to print variables from various directories in a hierarchy under `./inventory/group_vars`.
 
When running playbook like below, we get the following output:

```shell
ansible-controller:[example3](develop-lj)$ ansible-playbook -i inventory -l host-one ansible_group_vars_dir.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [host-one] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host host-one is using the discovered Python interpreter at /Users/ljohnson/.pyenv/shims/python3.11, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.15/reference_appendices/interpreter_discovery.html for more information.
ok: [host-one]

TASK [Here we print the variables from different host groups] ********************************************************************************************************************************************
ok: [host-one] => {
    "msg": "Username is testuser and connection port is 22"
}

PLAY RECAP ***********************************************************************************************************************************************************************************************
host-one                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-controller:[example3](develop-lj)$ 
```


## **Example #4**

File `./inventory/hosts.yml`:
```yaml
---

all:
  children:
    ansible_controller:
      hosts:
        127.0.0.1: {}
    site1:
      children:
        site1_prod:
          hosts:
            host-s1-p01: {}
        site1_dev:
          hosts:
            host-s1-d01: {}
    site2:
      children:
        site2_prod:
          hosts:
            host-s2-p01: {}
        site2_dev:
          hosts:
            host-s2-d01: {}

```

Also, the `group_vars` directory is defined as `./inventory/group_vars`, which have files like below

```shell
ansible-controller:[ansible-groupvars-examples](develop-lj)$ cd example4
ansible-controller:[example4](develop-lj)$ find ./inventory/group_vars/ -type f
./inventory/group_vars/site2/db_settings.yml
./inventory/group_vars/site2/site2_dev/db_settings.yml
./inventory/group_vars/site2/site2_prod/db_settings.yml
./inventory/group_vars/site1/db_settings.yml
./inventory/group_vars/site1/site1_dev/db_settings.yml
./inventory/group_vars/site1/site1_prod/db_settings.yml

```


The files under this directory have content like below:

```shell
ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site1/db_settings.yml
---

db_site: site1
db_port: 4123
db_url: "{{ db_host }}:{{ db_port }}"

ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site1/site1_dev/db_settings.yml
---

username: testuser
db_host: "db.dev.{{ db_site }}.example.int"

ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site1/site1_prod/db_settings.yml
---

username: testuser
db_host: db.prod.site1.example.int

ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site2/db_settings.yml
---

db_site: site2
db_port: 4123
db_url: "{{ db_host }}:{{ db_port }}"

ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site2/site2_dev/db_settings.yml
---

username: testuser
db_host: "db.dev.{{ db_site }}.example.int"

ansible-controller:[example4](develop-lj)$ cat ./inventory/group_vars/site2/site2_prod/db_settings.yml
---

username: testuser
db_host: db.prod.site1.example.int

```

We perform some preliminary inventory variable checks for the host `host-s1-p01`:
```shell
ansible-controller:[example4](develop-lj)$ ansible -i inventory -m debug -a var=group_names host-s1-p01
host-s1-p01 | SUCCESS => {
    "group_names": [
        "site1",
        "site1_prod"
    ]
}
ansible-controller:[example4](develop-lj)$ ansible -i inventory -m debug -a var=db_host,db_host,db_url host-s1-p01
host-s1-p01 | SUCCESS => {
    "db_host,db_host,db_url": "('db.prod.site1.example.int', 'db.prod.site1.example.int', 'db.prod.site1.example.int:4123')"
}

```

### Example using playbook

In this example, we have a playbook with below content:

File `display_group_vars.yml`
```yaml
---

- hosts: all
  tasks:
    - name: Here we print the db setting variables from different host groups
      debug:
        msg:
          - "username: {{ username }}"
          - "db_site: {{ db_site }}"
          - "db_host: {{ db_host }}"
          - "db_port: {{ db_port }}"
          - "db_url: {{ db_url }}"

```

Using this playbook, we try to print variables from various directories in a hierarchy under `./inventory/group_vars`.

When running playbook like below, we get the following output:

```shell
ansible-controller:[example4](develop-lj)$ ansible-playbook -i inventory -l host-s1-p01 display_group_vars.yml

PLAY [all] ***********************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host host-s1-p01 is using the discovered Python interpreter at /Users/ljohnson/.pyenv/shims/python3.11, but future installation of another Python interpreter could change
the meaning of that path. See https://docs.ansible.com/ansible-core/2.15/reference_appendices/interpreter_discovery.html for more information.
ok: [host-s1-p01]

TASK [Here we print the db setting variables from different host groups] *********************************************************************************************************************************
ok: [host-s1-p01] => {
    "msg": [
        "username: testuser",
        "db_site: site1",
        "db_host: db.prod.site1.example.int",
        "db_port: 4123",
        "db_url: db.prod.site1.example.int:4123"
    ]
}

PLAY RECAP ***********************************************************************************************************************************************************************************************
host-s1-p01                : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-controller:[example4](develop-lj)$ 
```


### Example using dynamic group_by on host

In this example, we have a playbook with below content:

File `apply_group_vars.yml`
```yaml
---

- hosts: host-foobar
  tasks:

    - name: Apply host 'host-foobar' to group site1_prod
      group_by:
        key: site1_prod

    - name: Here we print the db setting variables from different host groups
      ansible.builtin.debug:
        msg:
          - "username: {{ username }}"
          - "db_site: {{ db_site }}"
          - "db_host: {{ db_host }}"
          - "db_port: {{ db_port }}"
          - "db_url: {{ db_url }}"

```

Using this playbook, we print variables for the target host that will be grouped in the hierarchy under `./inventory/group_vars`.

When running playbook like below, we get the following output:

```shell
ansible-controller:[example4](develop-lj)$ ansible-playbook -i inventory apply_group_vars.yml 

PLAY [host-foobar] *************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host host-foobar is using the discovered Python interpreter at /usr/local/Cellar/python@3.12/3.12.2/bin/python3.12, but future installation of another Python interpreter could change the meaning of that
path. See https://docs.ansible.com/ansible-core/2.16/reference_appendices/interpreter_discovery.html for more information.
ok: [host-foobar]

TASK [Apply host 'host-foobar' to group site1_prod] ****************************************************************************************************************************************************************************************
changed: [host-foobar]

TASK [Here we print the db setting variables from different host groups] *******************************************************************************************************************************************************************
ok: [host-foobar] => {
    "msg": [
        "username: testuser",
        "db_site: site1",
        "db_host: db.prod.site1.example.int",
        "db_port: 4123",
        "db_url: db.prod.site1.example.int:4123"
    ]
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************************
host-foobar                : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ansible-controller:[example4](develop-lj)$ 
```




### Conclusion

As we can see in this article, using `group_vars` is easy to define and can be very helpful in cases where we need to work on a group of hosts. This not only saves our efforts to sort the hosts but also enhance the flexibility in our code. 

The re-usability, or the _don't-repeat-yourself_ principal format (__DRY__), of these group variables makes it an efficient method to implement in multi-stage environments to enable __configuration-as-code__ implementations for complex/advanced/elaborate datacenter host configurations.   

Using the DRY principal also __greatly reduces inadvertent/unintended divergence of configuration settings__ by minimizing duplication of configuration settings shared across host hierarchies/ancestries with the `group_vars` based approach to maintaining settings at the appropriate group level in the group hierarchy/ancestry as seen in the aforementioned example 4.

## Reference

- https://www.educba.com/ansible-group_vars/
- [Ansible Vault](https://www.educba.com/ansible-vault/)
- [Ansible Roles](https://www.educba.com/ansible-roles/)
- [Ansible Loop](https://www.educba.com/ansible-loop/)
- [Ansible Tags](https://www.educba.com/ansible-tags/)
