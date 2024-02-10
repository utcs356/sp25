---
layout: page
permalink: /assignments/assignment2
title: "Assignment 2: Software Switch and Router with P4"
---

### Part 0: Setup
Unlike the previous assignments, we will use `cs356-p4` profile instead of `cs356-base` in this assignment.
It includes a Kathara image with P4 utilities so that you can run your P4 code on a virtual device. 
To get a skeleton code, clone the [git repository](https://github.com/utcs356/assignment2.git) and   
make your own private repository as in A1. (refer to A1 setup)
The task is to implement a basic switch and router with P4 (data plane) and Python (control plane).

#### Notes
* Experiment instantiation
    * Make sure to use profile `cs356-p4`, not `cs356-base`.
    * Make sure to specify your group during instantiation. If you cannot see the Group options yet, please contact TA through Ed or email.
    * You should SSH to the node using XTerm for Part 1 and Part 2 tests.
* For every experiment instantiation, you should
    * `$ sudo usermod -aG docker $USER`   
    `$ touch ~/.Xauthority`  
    Then restart the SSH session to make sure the changes are applied.
    * Clone your private repository and push the changes you made.

### Part 1: Switching with P4
#### Overview 
In this part of the assignment, you will implement a software switch with P4. Kathara lab for this part is located in `assignment2/labs/star_four_hosts`. The skeleton codes are located in the `assignment2/labs/star_four_hosts/shared`. The virtual network topology is illustrated below.  
![P1_topology]({{site.baseurl}}/assets/img/assignments/assignment2/P1_topology.png) . 
Your task is to complete `l2_basic_forwarding.p4` and `controller.py` to make the switch `s1` work so that `h[1-4]` can talk to each other.

#### Specification
Parse the ethernet header.
* Parser is already implemented, and your job is to define a ethernet header format, `header ethernet_t`.

Implement forwarding.
* P4 task: Complete the definition of `table dmac_forward`
    * Check whether the destination MAC address has a MAC-to_port_mapping
    * Upon hit, forward the packet to the retrieved port using `action forward_to_port()`.
    * Upon miss, broadcast the packet using `action broadcast()`.

Implement MAC learning. MAC-to-port mapping should expire after 15 seconds from the last packet arrival from the interface.
* P4 task: Complete the definition of `table smac_table`.
    * Check whether the source MAC address of the packet has a MAC-to-port mapping.
    * Upon hit, do nothing.
    * Upon miss, send the MAC-to-port mapping to the controller.
        * Define `struct mac_learn_digest_t`.  
        * Complete the `action learn()`.

* Controller task: Install table entries for the tables when a digest message arrives. Set the timeout for the entries.
    * `smac_table`: Install a table entry with the MAC address as a key. `NoAction()` as an action.
    * `dmac_forward`: Install a table entry with the MAC address as a key, `forward_to_port()` as an action, and ingress_port as an action parameter.

#### Test your implementation.

### Part 2: Router with P4
#### Specification
We will assume a static routing table(prefix, subnet mask, next-hop) and ARP table (IP address to MAC address binding).
Destination IP lookup on the routing table - longest prefix match
Check if the packet is an IPv4 packet or not.
Verify the packet’s checksum and --TTL
If the packet belongs to the addresses of router interfaces => drop
Route table lookup to obtain next hop address (or gateway address) and then ARPcache lookup to obtain MAC address.
Update the ethernet header and send the modified packet.

#### TODOs
Topology(Kathara lab) - basic star for switching and multiple switches for routing
How to compile and deploy a dummy P4 program (that drops every packet)
provide students with a skeleton code 