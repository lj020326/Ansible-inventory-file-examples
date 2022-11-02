
# Sanity Checks 

## 1: Check that the correct hosts appear for the group 

Using a group with name 'testgroup'
```shell
$ ansible-inventory -i ./inventory/ --graph --yaml
@all:
  |--@app_123:
  |  |--appvm01.dev.example.int
  |  |--appvm01.example.int
  |  |--appvm01.test.example.int
  |--@ungrouped:
  |  |--appvm02.dev.example.int
  |  |--appvm02.example.int
  |  |--appvm02.test.example.int
```

## 1b) Check the groups are correctly setup for the hosts getting added 

Group based query:
```shell
ansible -i Sandbox/ -m debug -a var=bootstrap_ntp_servers testgroup_lnx
ntpq1s1.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": [
        "us.pool.ntp.org",
        "time.nist.gov",
        "tick.viawest.net",
        "tock.viawest.net"
    ]
}
toyboxd3s1.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
ntpq1s4.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": [
        "us.pool.ntp.org",
        "time.nist.gov",
        "tick.viawest.net",
        "tock.viawest.net"
    ]
}
toyboxd1s4.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
toyboxd2s4.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
toyboxd2s1.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": []
}
toyboxd1s1.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": []
}
toyboxd3s4.alsac.stjude.org | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}

```

Host based query:
```shell
ansible -i Sandbox/ -m debug -a var=group_names dataqualityp1s*
dataqualityp1s4.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "odq"
    ]
}
dataqualityp1s1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "odq"
    ]
}
```

Seeing the situation above should inspire/invoke the following questions/concerns: 

* shouldn't these machines also be in the respective core/essential DCC groups used to derive core/essential settings/configs? 
* currently they only appear to be in only the odq group, so they would not derive any values for the DCC group settings. (see next subsection for more info).

### All hosts should in appear in respective core/essential "DCC" groups to derive the correct settings.

We would always expect there to be "core" DCC groups that all machines should appear.

The "core" DCC groups we expect to see:

* sdlc_environment 
  * DEV
  * QA
  * PROD

* infra_provider 
  * internal-vmware
  * AWS
  * Azure
  * GCP

* availability zone/site/location
  * site1 (MEM), 
  * site4 (DFW)
  * AWS 
    * AZ01, 
    * AZ02, 
    * ..., 
    * AZNN, 
  * etc

* network 
  * PCI
  * DMZ
  * internal (e.g., not-PCI)

and perhaps some others




## 2) Key role variable checks for hosts in group(s)

If deploying host updates such that key variable values are expected, check to verify that the variable values are set correctly.
E.g., 

In the following example, we are updating the ntp client configuration for hosts and want to see that those machines have the expected value for variable 'ntp_servers'.

```shell
ansible -i ./inventory/PCI/MEM/ -m debug -a var=ntp_servers ntp_client

#ansible -i ./inventory/PCI/MEM/ -m debug -a var=ntp_servers,some_other_var ntp_client

```


## 3) Graphs for group hierarchy checks

Query by group name:
```shell
ansible-inventory -i Sandbox/ --graph --yaml odq
@odq:
  |--dataqualityp1s1.alsac.stjude.org
  |--dataqualityp1s4.alsac.stjude.org

```

Other examples:
```shell
ansible-inventory -i Sandbox/PCI/ --graph ntp
@ntp:
  |--@ntp_client:
  |  |--@environment_test:
  |  |--@foreman_organization_alsac:
  |  |  |--time5s1.test.alsac.stjude.org
  |  |  |--web-q1.test.alsac.stjude.org
  |  |  |--web-q2.test.alsac.stjude.org
  |--@ntp_server:
  |  |--time5s1.test.alsac.stjude.org
  |  |--time5s4.test.alsac.stjude.org

```


```shell
ansible-inventory -i Sandbox/ --graph ntp
@ntp:
  |--@ntp_client:
  |  |--@environment_test:
  |  |--@foreman_location_mem:
  |  |  |--time5s1.test.alsac.stjude.org
  |  |  |--web-q1.test.alsac.stjude.org
  |  |  |--web-q2.test.alsac.stjude.org
  |  |--@foreman_organization_alsac:
  |  |  |--time5s1.test.alsac.stjude.org
  |  |  |--web-p1.test.alsac.stjude.org
  |  |  |--web-p1.test.test.alsac.stjude.org
  |  |  |--web-p2.test.alsac.stjude.org
  |  |  |--web-p2.test.test.alsac.stjude.org
  |  |  |--web-p3.test.alsac.stjude.org
  |  |  |--web-p3.test.test.alsac.stjude.org
  |  |  |--web-p4.test.alsac.stjude.org
  |  |  |--web-p4.test.test.alsac.stjude.org
  |  |  |--web-q1.test.alsac.stjude.org
  |  |  |--web-q2.test.alsac.stjude.org
  |  |  |--webq1s4.test.alsac.stjude.org
  |  |  |--webq1s4.test.test.alsac.stjude.org
  |  |--@linux:
  |  |  |--@linux_dmz:
  |  |  |  |--@linux_dmz_dfw:
  |  |  |  |  |--webp1s4.alsac.stjude.org
  |  |  |  |--@linux_dmz_mem:
  |  |  |  |  |--web-p1.alsac.stjude.org
  |  |  |--@linux_pci:
  |  |  |  |--@linux_pci_dfw:
  |  |  |  |  |--lnxr7t1s4.alsac.stjude.org
  |  |  |  |  |--lnxr8t1s4.alsac.stjude.org
  |  |  |  |--@linux_pci_mem:
  |  |  |  |  |--ansiblelinuxtestd1s1.alsac.stjude.org
  |  |  |  |  |--toyboxd1s1.alsac.stjude.org
  |  |  |  |  |--toyboxd2s1.alsac.stjude.org
  |  |  |  |--@linux_pci_other:
  |--@ntp_server:
  |  |--ansiblelinuxtestd1s1.alsac.stjude.org
  |  |--time5s1.test.alsac.stjude.org
  |  |--time5s4.test.alsac.stjude.org
  |  |--webp1s4.alsac.stjude.org

```


```shell
ansible -i ./inventory/ -m debug -a var=ansible_winrm_transport windows_dev
ansible -i ./inventory/ foreman_location_dfw -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name
ansible -i ./inventory/ toy* -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name var=foreman.location_name
ansible -i ./inventory/ foreman_location_mem -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name var=foreman.location_name
ansible -i ./inventory/ foreman_location_mem -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name -a var=foreman.location_name
ansible -i ./inventory/ foreman_location_mem -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name
ansible -i ./inventory/ foreman_location_mem -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_server -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_server -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_server -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_client -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_client -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/ ntp_client -m debug -a var=foreman.content_facet_attributes.lifecycle_environment.name,foreman.location_name
ansible -i ./inventory/PCI/MEM/ --list-hosts all
ansible -i ./inventory/PCI/MEM/ -m debug -a var=ntp_servers all
ansible -i ./inventory/PCI/MEM/ -m debug -a var=ntp_servers bootstrap_ntp_servers
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers all
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names all
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_server
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_client
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_client
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names all
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names foreman_content_view_rhel7_composite
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var=bootstrap_ntp_servers,group_names ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="ansible_default_ipv4.address,foreman.ip|ansible.utils.ipaddr('10.10.10.0/24')|ansible.utils.ipaddr(bool)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="ansible_default_ipv4.address,foreman.ip|ansible.utils.ipaddr('10.10.10.0/24')|ansible.utils.ipaddr('bool')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="ansible_default_ipv4.address,foreman.ip" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="ansible_default_ipv4.address,foreman.ip|ansible.utils.ipaddr('172.21.40.0/24')|ansible.utils.ipaddr('bool')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="ansible_default_ipv4.address,gateway_ipv4_network_cidr,foreman.ip|ansible.utils.ipaddr('172.21.40.0/24')|ansible.utils.ipaddr('bool')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="gateway_ipv4_network_cidr,foreman.ip,gateway_ipv4_network_cidr|ansible.netcommon.network_in_usable(foreman.ip)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="group_names,gateway_ipv4_network_cidr,foreman.ip,gateway_ipv4_network_cidr|ansible.netcommon.network_in_usable(foreman.ip)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="group_names,gateway_ipv4_network_cidr,foreman.ip,gateway_ipv4_network_cidr|ansible.netcommon.network_in_usable(foreman.ip)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="group_names,gateway_ipv4_network_cidr,foreman.ip,gateway_ipv4_network_cidr|ansible.netcommon.network_in_usable(foreman.ip)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="gateway_ipv4_network_cidr,foreman.ip,gateway_ipv4_network_cidr|ansible.netcommon.network_in_usable(foreman.ip)" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,ntp_servers|d('')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,ntp_servers|d('')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,bootstrap_ntp_servers|d('')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,bootstrap_ntp_servers|d('')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,bootstrap_ntp_servers|d(''),bootstrap_ntp_peers|d('')" ntp
ansible -i ./inventory/PCI/MEM/ -m debug -a var="foreman.ip,bootstrap_ntp_servers|d(''),bootstrap_ntp_peers|d('')" ntp

```

# Testing Inventory host and/or group variable settings

We will now run through several ansible CLI tests to verify that the correct machines result for each respective limit used.

## Show list of all Sandbox/DMZ/MEM hosts

```shell
$ ansible -i ./inventory/DMZ/MEM --list-hosts all
  hosts (9):
    toyboxd1s1.alsac.stjude.org
    toyboxd2s1.alsac.stjude.org
    toyboxd3s1.alsac.stjude.org
    web-d1.alsac.stjude.org
    web-q1.alsac.stjude.org
    web-q2.alsac.stjude.org
    time5s1.test.alsac.stjude.org
    web-q1.test.alsac.stjude.org
    web-q2.test.alsac.stjude.org

```

## Debug host/group vars for inventory hosts

### Get groups for a host

```shell
ansible -i ./Sandbox -m debug -a var=group_names toyboxd1s1*
toyboxd1s1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "dev",
        "dmz",
        "dmz_dev",
        "dmz_qa",
        "foreman_content_view_rhel7_composite",
        "foreman_lifecycle_environment_dev",
        "foreman_location_mem",
        "foreman_organization_alsac",
        "lnx_all",
        "lnx_dev",
        "lnx_mem",
        "lnx_qa",
        "mem",
        "ntp",
        "ntp_client",
        "qa",
        "test_git_acp",
        "test_git_acp_linux",
        "toybox"
    ]
}

```

## Get info for all hosts in a specified inventory

```shell
$ ansible -i ./inventory/DMZ/MEM -m debug -a var=group_names all
toyboxd1s1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "dmz",
        "dmz_qa",
        "lnx_qa",
        "qa"
    ]
}
toyboxd2s1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "ungrouped"
    ]
}
toyboxd3s1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "ungrouped"
    ]
}
web-d1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
web-q1.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
web-q2.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
time5s1.test.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "foreman_content_view_rhel7_composite"
    ]
}
web-q1.test.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "foreman_content_view_rhel7_composite",
        "foreman_lifecycle_environment_qa",
        "foreman_location_mem",
        "foreman_organization_alsac"
    ]
}
web-q2.test.alsac.stjude.org | SUCCESS => {
    "group_names": [
        "foreman_content_view_rhel7_composite",
        "foreman_lifecycle_environment_qa",
        "foreman_location_mem",
        "foreman_organization_alsac"
    ]
}

```
