---
layout: page
permalink: /assignments/assignment4
title: "Assignment 4: Reliable Transport Protocol and Congestion Control"
---
#### **Released:** 03/13/2025 <br/> **Due:**	04/08/2025
{: .no_toc}
* (The list will be replaced with the table of contents.)
{:toc}

### Overview

In this assignment, you will implement a transport layer of the network stack.
Your transport layer must ensure *reliable transmission of packets* even when packet corruptions and losses occur.
Also, to enable efficient communication, you will implement flow control using sliding window and a simple congestion control algorithm.

### Part 0: Environment Setup

* CloudLab image
* Get Skeleton Code
* How to setup basic environments
* Skeleton Code explanation

In this assignment, we recommend you use `cs356-base` profile on CloudLab for implementing and testing your code.
To get the skeleton code, create a **private** repository by clicking `Use this template> Create a repository` on the [GitHub repository](https://github.com/utcs356/assignment4.git).

### Implementation

The goal of this assigment is to support reliable communications by implementing `UTCS TCP`.
In the skeleton codes, we provide `UTCS TCP` socket and APIs (in `utcs_tcp.h`):

* `utcs_socket`: creates a new socket for `UTCS TCP`. The socket includes all information about address, send/receive buffers, sliding window, congestion control, and so on.
  * When a new socket is created, a process will bind to the socket, which is in charge of sending and receiving data through the `begin_backend` function.
* `utcs_close`: closes the socket.
* `utcs_read`: reads data from the received buffer in the socket.
* `utcs_write`: writes data to the send buffer in the socket.

Examples of how the socket are created and APIs are used can be found in `server.c` and `client.c`.
A simplified version would look as follows:

```c
utcs_socket_t socket;
utcs_socket(&socket, TCP_LISTENER, portno, serverip); // Creates a socket.
utcs_write(sock, "Who's there?", 12); // Sends data with the size of 12 bytes.
int n = utcs_read(sock, buf, 12, NO_FLAG); // Reads data from the received buffer.
printf("Received: %.*s\n", n, buf);
utcs_close(&socket) // Closes the socket.
```

Your tasks are to enable reliable communications by implementing functions in `backend.c`.
Read the following descriptions and implement `TODOs` specified in the skeleton.
Feel free to change skeleton codes other than codeblocks in `TODOs` if you make sure not to change function signatures of `UTCS TCP` socket and APIs.

#### Part 1: Connection establishment and termination

The first step for reliable transmission between two entities (`INITIATOR` and `LISTENER`) is to establish connections.
To do so, you will implement TCP three-way handshake before data transmission happens.
To finish connection safely when no more data to transmit, you will perform connection teardown.

##### Three-way handshake

We describe the handshake workflow and what should be implemented as follows:

1. The client (`INITIATOR`) sends a SYN packet to the server (`LISTENER`), and the server receives the SYN packet from the client.

    * As a starting point, we include how to send SYN packets from the client side in our skeleton codes. Please check `send_pkts_handshake` function for the implementation.
    * Note that `sock->send_syn` flag is used to determine whether to send SYN packets or not.
    * When the server receives SYN, the server initialize the receive window (`sock->recv_win`). The receive window attributes should be updated based on the sequence number.

2. The server replies back with SYN+ACK, and the client receives the SYN+ACK.

    * The client updates the send/receive windows based on the acknowledge and sequence numbers.

3. The client replies back with ACK, and the server receives the ACK.

    * The server updates the send window based on the ACK packet. Both the client and server complete the initialization phase.

##### Connection teardown

When a socket is done transmitting data, the socket calls `utcs_close()` to terminate communications. We describe the expected behaviors during termination as follows. The termination process can be triggered by either server or client, whoever is ready to send `FIN` packets:

1. When there is no more data to send, the socket sets the sequence number to be included in `FIN` (Refer to the `check_dying()` function).
2. Either server or client sends a `FIN` packet (Refer to the first `if` statement in `begin_backend()`).
3.

> [!NOTE]
> We do not consider when both server and client terminate at the same time.
> (i.e., You do not have to handle scenarios to send `FIN & ACK` flags in a packet.)

#### Part 2: Flow Control

* Transmit multiple packets before an ACK by using sliding window
* Sender correctly responds to changes in the receiver’s advertised window
* Advertised window is correctly reduced when the application does not consume data
* A packet is retransmitted after three duplicate ACKs

For the ease of grading, we use static timeout in this assignment.
But, the algorithm can be implemented in more efficient manners by estimating RTT (e.g., Karn/Partridge algorithm).

#### Part 3: Congestion Control

* Implement TCP-Reno's congestion control algorithm
* In slow start, the congestion window increases exponentially
* In congestion avoidance mode, the congestion window correctly responds to loss
* Sender returns to slow start on timeout

#### Testing your implementation

* Simple server and client (text, file)
* Python test
* Change network environments by configuring Kathara parameters

### Experiments

* Capture packets and report Saw-tooth patterns
* Expeirment scenario? (Normal, Bandwidth change)

### Submission

Please submit your code (modified assignment4 repository) to the Canvas Assignments page in either `tar.gz` or `zip` format.
The naming format for the file is `assign4_groupX.[tar.gz/zip]`.


```
# directory tree.
```

### Grading

* Implementation (70%)
  * Part 1: Handshake
  * Part 2: Flow Control
  * Part 3: Congestion Control
* Experiments (30%)

### Acknowledgements

This assignment is modified from CMU Computer Networks course (CMU 15-441/641) assignments.
No part of the project may be copied and/or distributed without the express permission of the course staff.
