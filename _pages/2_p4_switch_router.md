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
![P1_topology]({{site.baseurl}}/assets/img/assignments/assignment2/P1_topology.png)    
Your task is to complete `l2_basic_forwarding.p4` and `controller.py` to make the switch `s1` work so that `h[1-4]` can talk to each other.

#### Specification
1. Parse the ethernet header.
* Parser is already implemented, and your job is to define a ethernet header format, `header ethernet_t`.

2. Implement forwarding.
* P4 task: Complete the definition of `table dmac_forward`
    * Check whether the destination MAC address has a MAC-to_port_mapping
    * Upon hit, forward the packet to the retrieved port using `action forward_to_port()`.
    * Upon miss, broadcast the packet using `action broadcast()`.

3. Implement MAC learning. MAC-to-port mapping should expire after 15 seconds from the last packet arrival from the interface.
* P4 task: Complete the definition of `table smac_table`.
    * Check whether the source MAC address of the packet has a MAC-to-port mapping.
    * Upon hit, do nothing.
    * Upon miss, send the MAC-to-port mapping to the controller.
        * Define `struct mac_learn_digest_t`.  
        * Complete the `action learn()`.

* Controller task: Install table entries for the tables when a digest message arrives. Set the timeout for the entries.
    * `smac_table`: Install a table entry with the MAC address as a key. `NoAction()` as an action.
    * `dmac_forward`: Install a table entry with the MAC address as a key, `forward_to_port()` as an action, and `egress_port` as an action parameter.

#### Test your implementation.
1.  Compile the P4 code and launch the P4 and controller program.  
* All the necessary commands are provided as script files in the Kathara lab's `shared` directory. 
* After starting the Kathara lab, compile the P4 code with `bash /shared/compile_p4.sh` on `s1`. 
* Then launch the compiled P4 program with `bash /shared/run_switch.sh` and the controller with `bash /shared/run_controller.sh`.  
2. Test the functionality.   
* You may use `ping` to check whether your switch is working as expected on a host (`h[1-4]`).  
* Once you implement forwarding, the packet should arrive at each host in the local network except the sender for every ping.
* Once you implement MAC learning, the packet should arrive at each host in the local network except the sender only for the first ping. Then the packet must arrive only at the destination host until the table entry expires.
* To check if the packet arrives at a host, use `tcpdump -i <interface>` to sniff the packet on the host's interface. The interface name can be retrieved by using `ifconfig`. For more detail, refer to [man tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html).

### Part 2: Router with P4
#### Overview 
In this part of the assignment, you will implement a static software router with P4. Since it's static, it routes a packet based on a given routing information. Kathara lab for this part is located in `assignment2/labs/three_routers_three_hosts`. The skeleton codes are located in the `assignment2/labs/three_routers_three_hosts/shared`. The virtual network topology is illustrated below.  
![P2_topology]({{site.baseurl}}/assets/img/assignments/assignment2/P2_topology.png)    
Your task is to complete `l3_static_routing.p4` and `controller.py` to make the routers `r[1-3]` work so that hosts in different local networks can talk to each other.
#### Specification
1. Parse the ethernet and IPv4 header.
* Define a ethernet header format, `header ethernet_t`, and an IPv4 header format, `header ipv4_t`
* Complete the `state parse_ethernet` in `MyParser()`. Check the ethernet frame type, and go to the parse_ipv4 state if the frame type is IPv4. Otherwise, accept the packet.
2. Implement a routing table
    * P4 task: Define tables and actions.
        * Complete the definition of `table ipv4_route`. 
            * Perform longest prefix matching on dstIP.
            * Upon hit, record the next hop IP address (provided by the controller) in the `metadata meta`'s `next_hop` field using `action forward_to_next_hop`.
            * Upon miss, drop the packet.
        * Complete the definition of `table arp_table`.
            * Perform exact matching on the `next_hop` in the `metadata meta`.
            * Upon hit, change the dstMAC (provided by the controller) using `action change_dst_mac`.
            * Upon miss, drop the packet.
        * Complete the definition of `table dmac_forward`.
            * Perform exact matching on the destination MAC address of the packet.
            * Upon hit, change the egress port. (provided by controller). Change the source MAC address to the egress port's MAC address. (provided by controller). Do this by completing and using `action forward_to_port`.
            * Upon miss, drop the packet.
        * Apply the tables in the `apply` block.
        
    * Controller task: Install table entries.
    Parsing of routing information is provided in the skeleton code. Your task is to install the table entries for each table defined in the P4 code.
        * `ipv4_route`: Install table entries with the destination IP address as a key, `forward_to_next_hop` as an action, and `next_hop_ip` as an action parameter.
        * `arp_table`: Install table entries with the `next_hop` in the metadat as a key, `change_mac` as an action, and `next_hop_mac` as an action parameter.
        * `dmac_forward`: Install table entries with the MAC address as a key, `forward_to_port()` as an action, and `egress_port` and `egress_mac` as action parameters.

3. Checksum and TTL
    * Complete `MyVerifyChecksum()` and `MyUpdateChecksum()`. Use `extern verify_checksum()` and `extern update_checksum`. Their definitions are in this [link](https://github.com/p4lang/p4c/blob/main/p4include/v1model.p4). Use HashAlgorithm.csum16 as a hash algorithm.
    * Decrement the TTL field of IPv4 header by 1. Complete the definition of `action decrement_ttl()` and call the action in the `apply` block in `MyIngress()`.

#### Test your implementation.
1. Compile the P4 code and launch the P4 and controller program.  
* All the necessary commands are provided as script files in the Kathara lab's `shared` directory. 
* After starting the Kathara lab, compile the P4 code with `bash /shared/compile_p4.sh` on `r[1-3]`. 
* Then launch the compiled P4 program with `bash /shared/run_switch.sh` and the controller with `bash /shared/run_controller.sh` on each router.  
2. Test the functionality.
* You may use `ping` to check whether your router is working as expected on a host (`h[1-3]`).  
* To check if the packet arrives at a host, use `tcpdump -i <interface>` to sniff the packet on the host's interface. The interface name can be retrieved by using `ifconfig`. For more detail, refer to [man tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html).
* To verify IPv4 checksum and check the TTL field, add the `-v` flag to the `tcpdump` command.

### Submission
Please submit your code (modified assignment2 repository) to the Canvas Assignments page in either `tar.gz` or `zip` format.  
The naming format for the file is `assign2_groupX.[tar.gz/zip]`.