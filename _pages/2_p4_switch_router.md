---
layout: page
permalink: /assignments/assignment2
title: "Assignment 2: Software Switch and Router with P4"
---

### Part 0: Setup and Overview
Unlike the previous assignments, we will use `cs356-p4` profile instead of `cs356-base` in this assignment.
It includes a Kathara image with P4 utilities so that you can run your P4 code on a virtual device. 
To get a skeleton code, clone the [git repository](https://github.com/utcs356/assignment2.git) and   
make your own private repository as in A1. (refer to A1 setup)
The task is to implement a basic switch and router with P4 (data plane) and Python (control plane).

#### Notes
* Experiment instantiation
    * Make sure to use profile cs356-p4
    * Make sure to specify your group during instantiation. If you cannot see the Group options yet, please contact TA through Ed or email.
    * You should SSH to the node using XTerm for Part 1 and Part 2 tests.
* For every experiment instantiation, you should
    * `$ sudo usermod -aG docker $USER`   
    `$ touch ~/.Xauthority`  
    Then restart the SSH session to make sure the changes are applied.
    * Clone your private repository and push the changes you made.

### Part 1: Switching with P4
#### Specification
Parse the ethernet header to get source and destination MAC addresses. 
Send packets to specific interfaces based on the MAC addresses.
If the switch receives a frame that is addressed to the host not currently in the table – Forward the frame out on all other ports
Implement MAC learning.
MAC address - interface mapping should expire after 15 seconds from the last packet arrival from the interface.

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