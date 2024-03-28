---
layout: page
permalink: /assignments/assignment4
title: "Assignment 4: Reliable Transport Protocol"
---

### Part 0: Setup and Overview
#### Setup
In this assignment, we recommend you use `cs356-base` or `cs356-p4` profile on CloudLab for implementing and testing your code.
To get the skeleton code, clone the [git repository](https://github.com/utcs356/assignment4.git) and create a private repository as in A1. (Refer to A1 setup.) 

#### Overview
In this assignment, you will be writing the sending and receiving transport-level code for implementing a simple reliable data transfer protocol. Your transport layer must ensure reliable transmission of packets even when there are packet corruptions and losses. To simplify the process of implementation and testing, your code will be run in a network simulation environment (i.e., **No Kathara**). In the environment, there is only one sender and receiver pair, and the connection between them is uni-directional, unlike TCP. The network simulator is included in the provided code, and you should **NOT** modify it. Below is the overview figure for this assignment.    
![a4_overview]({{site.baseurl}}/assets/img/assignments/assignment4/A4_overview.png)   
* Transport layers (SndTransport and RcvTransport): This part is what you will implement. Transport layers expose a `send` API to the upper layer and a `recv` API to the lower layer. Transport layers can deliver a message (`class Msg`) to the upper layer using the provided `to_layer5` function and a packet (`class Pkt`) to the lower layer using the provided `to_layer3` function.
* Lower layer (layer 3): This is part of the simulator. Once it receives a packet from the other side, it calls the transport layer's `recv`. If the transport layer calls `to_layer3` with a packet, then it will deliver the packet to the other side.
* Upper layer (layer 5): This is also part of the simulator. It periodically sends a message to the other side using the transport layer's `send`. If the transport layer calls `to_layer5` with a message, it will receive the message.

### Part 1: Stop and Wait
In the assignment directory, complete the skeleton code, `transport/part1.py`. Please read the comments in the code marked as `BASIC DATA STRUCTURES` and `STUDENT-CALLABLE FUNCTIONS` before implementation.

#### Tasks
In this part of the assignment, you will exercise checksum, ACK, and timer-based retransmission which are the key components for reliable transmission. Your task is to complete the `calc_checksum` function and the methods of both `SndTransport` and `RcvTransport`. (They are all marked as `TODO` in the comments) These will together implement a stop-and-wait protocol in the transport layer. The sender should wait for an ACK packet after sending a packet, and there can be only one outstanding packet at any time. 

#### Specification
* `calc_checksum`: Write a function that calculates the checksum of a given packet. The checksum should be calculated over the entire `Pkt` instance but the checksum field (i.e. `Pkt.seqnum`, `Pkt.acknum`, and `Pkt.payload`) by using the Internet checksum algorithm ([link](https://book.systemsapproach.org/direct/error.html)).<br/><br/>
* `SndTransport._init_`: Initialize the necessary states for the sender. You **MUST** use instance variables (e.g., `self.x`) instead of global variables to keep the states for both sender and receiver.<br/><br/>
* `SndTransport.send`: Given a message from the upper layer, create a packet and send it to the lower layer by calling the given `to_layer3` function. After sending the packet, the program should enable timer by calling the given `start_timer` function. The packet should have a proper sequence number and checksum to ensure reliability against packet loss and corruption. Make sure there's only one outstanding packet at any time. If this method is called when there's an unacknowledged packet, simply drop the packet. (you may want to abort the process or print an error message.) <br/><br/> 
* `SndTransport.recv`: Given a packet from the lower layer, handle the sender's state, timer, and retransmission based on its validity by checking the acknum and checksum. Since it's uni-directional, it's fine to assume all the received packets are ACK packets. <br/><br/> 
* `SndTransport.timer_interrupt`: This method is called when the sender timer expires. It should perform retransmission of an unacknowledged packet and restart the timer upon timeout. <br/><br/> 
* `RcvTransport.__init__`: Initialize the necessary states for the receiver. You **MUST** use instance variables (e.g., `self.x`) instead of global variables to keep the states for both sender and receiver. <br/><br/> 
* `RcvTransport.recv`: Given a packet from the lower layer, hand over a message to the upper layer and send an ACK packet to the lower layer if the packet is valid. Otherwise, send a NACK packet to the lower layer. Recall that you can express both ACK and NACK with a one-bit sequence number in the stop-and-wait protocol. Since it's uni-directional, it's fine to assume all the received packets are data packets on the receiver side.
Please ignore `RcvTransport.timer_interrupt` if you're not going to extend this to the bi-directional connection.

#### Debugging your implementation
We'd recommend that you set the tracing level to 4 (by passing `-v 4` as a command-line argument) and put `print` in your code while you're debugging.

#### Test your implementation.
You can test your transport code on top of the simulator by executing the python file. There are multiple command-line arguments to adjust the network simulation environment. Please type `python run_sim.py -h` for the explanation. You should choose a very large value (e.g., 100000.0) for the average time between messages (`-d` option) from the sender's layer5, so that your sender is never called while it still has an outstanding, unacknowledged message it is trying to send to the receiver. Here are some sample test cases:
* `$ python3 run_sim.py -d 100000.0 -z 2 -s [random_seed] -n 10`
* `$ python3 run_sim.py -d 100000.0 -z 2 -c 0.1 -l 0.1 -s [random_seed] -n 100`
* `$ python3 run_sim.py -d 100000.0 -z 2 -c 0.3 -l 0.3 -s [random_seed] -n 100`

### Part 2: Sliding Window with a Fixed Window Size
We recommend you start from the part 1 code for this part of the assignment. In the assignment directory, copy your part 1 code by typing `$ cp transport/part1.py transport/part2.py` and write your part 2 code to `transport/part2.py`.

#### Tasks
In this part of the assignment, you will implement a reliable sliding window protocol that overcomes the utlization problem in the stop-and-wait protocol. It is also a foundation for flow and congestion control. Your task is to modify the methods of both `SndTransport` and `RcvTransport` in your part 1 code to implement the protocol in the transport layer. The sender can have up to **8** outstanding packets (i.e., **the window size is 8**).  

#### Specifications
* `SndTransport._init_`: Initialize the necessary states for the sender. It will need more states than Part 1.
* `SndTransport.send`: Given a message from the upper layer, create a packet and send it to the lower layer by calling the given `to_layer3` function. If the packet's sequence number is equal to the sliding window's base sequence number, the program should enable a timer by calling the given `start_timer` function. The packet should have a proper sequence number and checksum to ensure reliability against packet loss and corruption. If the number of outstanding unacknowledged packets exceeds or is equal to the window size when the upper layer calls `SndTransport.send`, simply drop it. (you may want to abort the process or print an error message and return.) <br/><br/> 
* `SndTransport.recv`: Given a packet from the lower layer, handle the sender's state including sliding window and buffer, timer, and retransmission based on its validity by checking the acknum and checksum. Since it's uni-directional, it's fine to assume all the received packets are ACK packets. <br/><br/> 
* `SndTransport.timer_interrupt`: This method is called when the sender timer expires. It should perform retransmission of all outstanding unacknowledged packets and restart the timer upon timeout. <br/><br/> 
* `RcvTransport.__init__`: Initialize the necessary states for the receiver. It will need more states than Part 1. You MUST use instance variables instead of global variables to keep the states for both sender and receiver. <br/><br/> 
* `RcvTransport.recv`: Given a packet from the lower layer, hand it over to the upper layer and send an ACK packet to the lower layer if the packet is valid. Validity is determined by the sequence number and checksum of the packet. Otherwise, resend the ACK for the most recent valid data packet.

#### Debugging your implementation
We'd recommend that you set the tracing level to 4 (by passing `-v 4` as a command-line argument) and put `print` in your code while you're debugging.

#### Test your implementation.
To test your part2 implementation, you **MUST** change `from transport.part1 import SndTransport, RcvTransport, Msg, Pkt` to `from transport.part2 import SndTransport, RcvTransport, Msg, Pkt` in the provided `run_sim.py`. Now, you don't have to choose a very large value (e.g., 100000.0) for the average time between messages from the sender's layer5, since there could be multiple in-flight packets with the sliding window protocol. Here are some sample test cases:
* `$ python3 run_sim.py -d 50.0 -z 2 -s [random_seed] -n 10`
* `$ python3 run_sim.py -d 50.0 -z 2 -c 0.1 -l 0.1 -s [random_seed] -n 100`
* `$ python3 run_sim.py -d 50.0 -z 2 -c 0.3 -l 0.3 -s [random_seed] -n 100`

### Submission
Please submit your code (modified assignment4 repository) including `part1.py` and `part2.py` to the Canvas Assignments page in either `tar.gz` or `zip` format.  
The naming format for the file is `assign4_groupX.[tar.gz/zip]`.

### Acknowledgements
This assignment is from the authors' website for Computer Networking: a Top Down Approach (by Jim Kurose and Keith Ross).