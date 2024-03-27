---
layout: page
permalink: /assignments/assignment4
title: "Assignment 4: Reliable Transport Protocol"
---

### Part 0: Setup and Overview
#### Setup
In this assignment, we recommend you to use `cs356-base` profile on CloudLab for implementing and testing your code.
To get the skeleton code, clone the [git repository](https://github.com/utcs356/assignment4.git) and create a private repository as in A1. (Refer to A1 setup.) 

#### Overview
In this assignment, you will be writing the sending and receiving transport-level code for implementing a simple reliable data transfer protocol. Your transport layer must ensure reliable transmission of packet even when there are packet corruptions and losses.To simplify the process of implementation and testing, your code will be run in a network simulation environment unlike previous assignments. The network simulator is included in the provided skeleton code, and you should NOT modify it.

### Part 1: Stop and Wait
In the assignment directory, copy your skeleton code by typing `$ cp skeleton.py part1.py`. Please write your part 1 code to `part1.py`. Please read the comments in the source code in `BASIC DATA STRUCTURES` and `STUDENT-CALLABLE FUNCTIONS` before implementation.

#### Tasks
In this part of the assignment, you will exercise checksum, ACK, and timer-based retransmission which are the key components for reliable transmission. Your task is to complete the `calc_checksum` function and the methods of both `EntityA` and `EntityB`. (They are all marked as `TODO` in the comments) These will together implement a stop-and-wait protocol in the transport layer. The sender should wait for an ACK packet after sending a packet, and there can be only one outstanding packet at any time. `EntityA` represents the sender-side transport layer and `EntityB` represents the receiver-side transport layer. The connection between them is uni-directional unlike TCP.

#### Specification
* `calc_checksum`: Write a function that calculates the checksum of a given packet. The checksum should be calculated over the entire Pkt instance but the checksum field (i.e. Pkt.seqnum, Pkt.acknum, and Pkt.payload) by using the Internet checksum algorithm ([link](https://book.systemsapproach.org/direct/error.html)).<br/><br/>
* `EntityA._init_`: Initialize the necessary states for the sender. You MUST use instance variables instead of global variables to keep the states for both sender and receiver.<br/><br/>
* `EntityA.output`: Given a message from the upper layer, create a packet and send it to the lower layer by calling given `to_layer3` function. After sending the packet, the program should enable timer by calling given `stop_timer` function. The packet should have a proper sequence number and checksum to ensure reliability against packet loss and corruption. Make sure there's only one outstanding packet at any time. If this method is called when there's an in-flight unacknowledged packet, simply drop the packet. <br/><br/> 
* `EntityA.input`: Given a packet from the lower layer, handle the sender's state, timer, and retransmission based on its validity by checking the acknum and checksum. Since it's uni-directional, it's fine to assume all the received packets are ACK packets. <br/><br/> 
* `EntityA.timer_interrupt`: This method is called when the sender timer expires. It should perform retransmission and restart the timer upon timeout. <br/><br/> 
* `EntityB.__init__`: Initialize the necessary states for the receiver. You MUST use instance variables instead of global variables to keep the states for both sender and receiver. <br/><br/> 
* `EntityB.input`: Given a packet from the lower layer, hand it over to the upper layer and send an ACK packet to the lower layer if the packet is valid. Otherwise, send a NACK packet to the lower layer. Recall that you can express both ACK and NACK with a one-bit sequence number in the stop-and-wait protocol. Since it's uni-directional, it's fine to assume all the received packets are data packets in the receiver side.
Please ignore `EntityB.timer_interrupt` if you're not going to extend this to the bi-directional connection.

#### Debugging your implementation
We'd recommend that you set the tracing level to 2 (by passing `-v 2` as a command-line argument) and put `print` in your code while your debugging your procedures.

#### Test your implementation.
You can test your transport code on top of the simulator by executing the python file. There are multiple command-line arguments to adjust network simulation environment. Please type `python part1.py -h` for the explanation. You should choose a very large value (e.g., 100000.0) for the average time between messages from sender's layer5, so that your sender is never called while it still has an outstanding, unacknowledged message it is trying to send to the receiver. Here are some sample test cases:
* `$ python3 part1.py -d 100000.0 -z 2 -s [random_seed] -n 10`
* `$ python3 part1.py -d 100000.0 -z 2 -c 0.1 -l 0.1 -s [random_seed] -n 100`
* `$ python3 part1.py -d 100000.0 -z 2 -c 0.3 -l 0.3 -s [random_seed] -n 100`

### Part 2: Sliding Window with a Fixed Window Size
We recommend you to start from the part 1 code for this part of the assignment. In the assignment directory, copy your part 1 code by typing `$ cp part1.py part2.py` and write your part 2 code to `part2.py`.

#### Tasks
In this part of the assignment, you will implement a reliable sliding window protocol which overcomes the utlization problem in the stop-and-wait protocol. Your task is to modify the methods of both `EntityA` and `EntityB` in your part 1 code to implement the protocol in the transport layer. The sender can have up to **8** in-flight packets (i.e., the window size is 8). If the number of in-flight unacknowledged packets exceeds or equal to the window size, save it into the sender buffer (you can maintain this as the instance variable of `EntityA`) and send it later whenever the number of the in-flight packets is less than the window size.

#### Specifications
* `EntityA._init_`: Initialize the necessary states for the sender. It will need more states than part 1. You MUST use instance variables instead of global variables to keep the states for both sender and receiver.<br/><br/>
* `EntityA.output`: Given a message from the upper layer, create a packet and send it to the lower layer by calling given `to_layer3` function. If the packet's sequence number is equal to the sliding window's base sequence number, the program should enable timer by calling given `stop_timer` function. The packet should have a proper sequence number and checksum to ensure reliability against packet loss and corruption. If this method is called when the number of in-flight unacknowleged packets exceeds or equal to the window size, save the packet to the sender's buffer. <br/><br/> 
* `EntityA.input`: Given a packet from the lower layer, handle the sender's state including sliding window and buffer, timer, and retransmission based on its validity by checking the acknum and checksum. Since it's uni-directional, it's fine to assume all the received packets are ACK packets. <br/><br/> 
* `EntityA.timer_interrupt`: This method is called when the sender timer expires. It should perform retransmission of all in-flight unacknowledged packets and restart the timer upon timeout. <br/><br/> 
* `EntityB.__init__`: Initialize the necessary states for the sender. It will need more states than part 1. You MUST use instance variables instead of global variables to keep the states for both sender and receiver. <br/><br/> 
* `EntityB.input`: Given a packet from the lower layer, hand it over to the upper layer and send an ACK packet to the lower layer if the packet is valid. Validity is determined by the sequence number and checksum of the packet. Otherwise, resend the ACK for the most recent valid data packets.

#### Debugging your implementation
We'd recommend that you set the tracing level to 2 (by passing `-v 2` as a command-line argument) and put `print` in your code while your debugging your procedures.

#### Test your implementation.
You can test your transport code on top of the simulator by executing the python file. There are multiple command-line arguments to adjust network simulation environment. Please type `python part1.py -h` for the explanation. Now, you don't have to choose a very large value (e.g., 100000.0) for the average time between messages from sender's layer5, since there could be multiple in-flight packets with the sliding window protocol. Here are some sample test cases:
* `$ python3 part2.py -d 50.0 -z 2 -s [random_seed] -n 10`
* `$ python3 part2.py -d 50.0 -z 2 -c 0.1 -l 0.1 -s [random_seed] -n 100`
* `$ python3 part2.py -d 50.0 -z 2 -c 0.3 -l 0.3 -s [random_seed] -n 100`

### Submission
Please submit your code (modified assignment4 repository) including `part1.py` and `part2.py` to the Canvas Assignments page in either `tar.gz` or `zip` format.  
The naming format for the file is `assign4_groupX.[tar.gz/zip]`.

### Acknowledgements
This assignment is from the authors' website for Computer Networking: a Top Down Approach (by Jim Kurose and Keith Ross).