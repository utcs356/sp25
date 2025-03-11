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
Also, to enable efficient communication, you will implement sliding window, flow control and congestion control.

### Environment Setup

In this assignment, we recommend you use `cs356-base` profile on CloudLab for implementing and testing your code.
To get the skeleton code, create a **private** repository by clicking `Use this template> Create a repository` on the [GitHub repository](https://github.com/utcs356/assignment4.git).

Install dependencies by running the following command (We recommend you to use CloudLab machines for development):
```bash
> bash setup/setup.sh
```

### Implementation

The goal of this assigment is to support reliable communications by implementing `UTCS TCP`.
In the skeleton codes, we provide `UTCS TCP` socket and APIs (in `utcs_tcp.h`):

* `utcs_socket`: creates a new socket for `UTCS TCP`. The socket includes all information about address, send/receive buffers, sliding window, congestion control, and so on.
  * When a new socket is created, a thread will bind to the socket, which is in charge of sending and receiving data through the `begin_backend` function.
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

#### Part1: Connection establishment and termination

The first step for reliable transmission between two entities (`INITIATOR` and `LISTENER`) is to establish connections.
To do so, you will implement TCP three-way handshake before data transmission happens.
To finish connection safely when no more data to transmit, you will perform connection teardown.

**Three-way handshake**

We first describe the handshake workflow:

1. The client (`INITIATOR`) sends a SYN packet to the server (`LISTENER`), and the server receives the SYN packet from the client.

    * As a starting point, we include how to send SYN packets from the client side in our skeleton codes. Please check `send_pkts_handshake()` function for the implementation.
    * Note that `sock->send_syn` flag is used to determine whether to send SYN packets or not.
    * When the server receives SYN, the server initialize the receive window (`sock->recv_win`). The receive window attributes should be updated based on the sequence number.

2. The server replies back with SYN+ACK, and the client receives the SYN+ACK.

    * The client updates the send/receive windows based on the acknowledge and sequence numbers.

3. The client replies back with ACK, and the server receives the ACK.

    * The server updates the send window based on the ACK packet. Both the client and server complete the initialization phase.

**Connection teardown**

When a socket is done transmitting data, the socket calls `utcs_close()` to terminate communications. We describe the expected behaviors during termination from one side as follows.
Your task is to handle when receiving `FIN` packets and sending corresponding `ACK` packets.
The termination process can be triggered by either server or client, whoever is ready to send `FIN` packets:

1. When there is no more data to send, the socket sets the sequence number to be included in `FIN` (Refer to the `check_dying()` function).
2. Either server or client sends a `FIN` packet (Refer to the first `if` statement in `begin_backend()`). Even after sending `FIN`, it should be able to receive packets.
3. When the other entity receives `FIN`, it sends back with an `ACK` packet.

When one entity 1) receives an `ACK` after sending `FIN`, and 2) receives `FIN` from the other entity, then it can exit the thread after timeout (Refer to `begin_backend()`).

```
NOTE: We do not consider when both server and client terminate at the same time.
(i.e., You do not have to handle scenarios to send `FIN & ACK` flags in a packet.)
```

In this part, you will have to implement the following functions in `backend.c` to eatablish connections:

* `send_pkts_handshake()`
* `handle_pkt()` (To handle `FIN` packets)
* `handle_pkt_handshake()`

#### Part2: Sliding Window and Flow Control

Now, server and client are ready to send and receive data after completing three-way handshake. For efficient data transmission, your goal is to implement a sliding window and flow control. Sliding window allows the sender to transmit multiple packets before waiting for an acknowledgment (ACK). We recommend you to read [Chapter 5.2](https://book.systemsapproach.org/e2e/tcp.html#sliding-window-revisited) in the P&D textbook to understand how sliding window and flow control work.

1. Sliding window:
    * At the sending side, three pointers are maintained into the send buffer (`sock->send_win`): `last_ack`, `last_sent`, and `last_write`. The following invariants hold for the three pointers:

        ```
        * `last_ack` <= `last_sent`
        * `last_sent` <= `last_write`
        ```

    * A similar set of pointers (sequence numbers) are maintained on the receiving side (`sock->recv_win`): `last_read`, `next_expect`, and `last_recv`. The following relationships hold for the three pointers:

        ```
        last_read < next_expect
        next_expect <= last_recv + 1
        ```

2. Flow control: Use the receiver’s advertised window as the maximum window size when sending packets.
    * UTCS TCP header includes the `advertised_window` field.
    * The receiver updates the advertised window (`sock->send_adv_win`) as it receives data.

In `backend.c`, you will have to implement the following functions to support sliding window and flow control:

* `send_pkts_data()`
* `handle_pkt()`
* `updated_received_buf()`


#### Part3: Congestion Control

In this part, you will implement congestion control following TCP Reno algorithm.
You can control congestion window and slow start threshold through `sock->cong_win` and `sock->slow_start_thresh`.

When implementing congestion control, the size of your sending window should now be the minimum of the congestion window and the advertised window. You should additionally make sure that the total amount of data buffered for the application (unread data, both ordered and unordered bytes) is less than `MAX_NETWORK_BUFFER`.

Now we describe how TCP Reno works:

![TCP Reno Congestion Control State Diagram]({{site.baseurl}}/assets/img/assignments/assignment4/tcp_reno.png)
The above figure shows the full TCP Reno congestion control state diagram
(Extracted from `Computer Networking: A Top-Down Approach (7th Edition)` by Kurose and Ross).

* During the `slow start` state, the congestion window increases by `MSS` (Additive Increase) for each new ACK. Transit to the `congestion avoidance` state when the congestion window is larger than the slow start threshold.
* In `congestion avoidance` state, the congestion window is adjusted as follows for each new ACK:
  * `new congestion window` = `current congestion window` + `MSS` * (`MSS` / `current congestion window`)
* `Fast recovery` state enables to recover more quickly is to retransmit whenever you see three duplicate ACKs.
  * Implement retransmission on the receipt of three duplicate ACKs (i.e., state transitions from `slow start` to `fast recovery`).
  * When duplicated ACKs continue after three duplicate ACKs, transmit new segments while increasing the congestion window size by `MSS`.
  * When new ACKs are received, transit to the `congestion avoidance` state.
* Sender returns to slow start on timeout. The slow start threshold is halved and the congestion window size is reset to `MSS`.
  * For the ease of grading, we use static timeout in this assignment instead of using more efficient methods such as Karn/Partridge algorithm.

In `backend.c`, you will implement or modify the following functions to implement the congestion control algorithm. We describe TODO items in the skeleton code:

* `handle_ack()`
* `handle_pkt()`
* `recv_pkts()`
* `send_pkts_data()`

#### Testing your implementation

We describe tools for developing and testing the implementation.

**Simple server and client**
We provide an example implementation of server and client that use UTCS-TCP sockets.
Please check `server.c` and `client.c` for more details.
To execute the programs, run the following commands. In this example, we assume you are running server and client in local environments.
Feel free to change the address and port in environment variables to what you prefer.

```bash
# Compile your UTCS TCP implementation along with server and client programs
make
```

```bash
# A terminal for server
UTCS_TCP_ADDR=127.0.0.1 UTCS_TCP_PORT=8000 ./server
```

```bash
# Another terminal for client
UTCS_TCP_ADDR=127.0.0.1 UTCS_TCP_PORT=8000 ./client
```

We expect server and client to finish communications successfully after a few seconds.
You can check the correctness of data transmission using the following command:
(We expect no outputs to appear. The command will print out messages when the files are different.)

```bash
diff tests/random.input tests/random.output
```

To test with different sizes, feel free to create random files with the following command and replace `tests/random.input`:

```bash
# Creates a file with 10 blocks each with 1MB => a 10MB file
dd if=/dev/urandom of=tests/random.input bs=1M count=10
```

**Change network environments by configuring Kathara parameters**


### Experiments

* Capture packets and report Saw-tooth patterns
* Expeirment scenario? (Normal, Bandwidth change)

### Submission

Please submit your **code** (assignment4 repository) and **report** on Canvas.
The naming format for the code and report is `assign4_groupX.[tar.gz/zip]` and `assign4_groupX.pdf` respectively.

### Grading

* Implementation (70%)
  * Handshake
  * Flow Control
  * Congestion Control
* Experiments (30%)

### Acknowledgements

This assignment is modified from CMU Computer Networks course (CMU 15-441/641) assignments.
No part of the project may be copied and/or distributed without the express permission of the course staff.
