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

In this assignment, you will implement the transport layer of a network stack. Your implementation must ensure reliable packet transmission, even in the presence of packet corruption and loss. To achieve efficient communication, you will also implement sliding window, flow control, and congestion control mechanisms.

### Environment Setup

We recommend using the `cs356-base` profile on CloudLab for implementation and testing.

1. Obtain the Skeleton Code

* Create a private repository by clicking "Use this template" > "Create a repository" on the provided [GitHub repository](https://github.com/utcs356/assignment4.git).

2. Install Dependencies

* Run the following command to install required dependencies (we recommend using CloudLab machines for development):

```bash
> bash setup/setup.sh
```

### Implementation

The objective of this assignment is to implement `UT TCP` to support reliable communication.
We provide skeleton code that includes a `UT TCP` socket and its corresponding APIs in `ut_tcp.h`:

**Provided APIs**

* `ut_socket()`: Creates a new UT TCP socket, which maintains information such as the address, send/receive buffers, sliding window, and congestion control.
  * When a socket is created, a dedicated thread binds to it, handling data transmission and reception via the begin_backend function.
* `ut_close()`: Closes the socket.
* `ut_read()`: Reads data from the receive buffer.
* `ut_write()`: Writes data to the send buffer.

**Usage Example**

You can find examples of how to create sockets and use these APIs in `server.c` and `client.c`.
A simplified version is shown below:

```c
ut_socket_t socket;
ut_socket(&socket, TCP_LISTENER, portno, serverip); // Creates a socket.
ut_write(sock, "Who's there?", 12); // Sends data with the size of 12 bytes.
int n = ut_read(sock, buf, 12, NO_FLAG); // Reads data from the received buffer.
printf("Received: %.*s\n", n, buf);
ut_close(&socket) // Closes the socket.
```

Your goal is to enable reliable communication by implementing the required functions in `backend.c`.
Carefully read the following descriptions and complete the `TODOs` specified in the skeleton code.
You may modify the skeleton code outside the TODO sections, but do not change the function signatures of the UT TCP socket and its APIs.

---

#### Part1: Connection Establishment and Termination

To enable reliable communication between two entities (`INITIATOR` and `LISTENER`), the connection must first be established. You will implement the **TCP three-way handshake** before data transmission begins. Additionally, you will handle **connection teardown** to safely terminate the connection when no more data needs to be transmitted.

**Three-Way Handshake**

The connection establishment follows this workflow:

1. **Client (`INITIATOR`) → Server (`LISTENER`): SYN**
   * The client sends a **SYN** packet to initiate the connection, and the server receives it.
   * The skeleton code provides an example of sending SYN packets in `send_pkts_handshake()`.
   * The `sock->send_syn` flag determines whether a SYN packet should be sent.
   * Upon receiving the SYN, the server initializes the **receive window (`sock->recv_win`)**, updating its attributes based on the sequence number.

2. **Server (`LISTENER`) → Client (`INITIATOR`): SYN+ACK**
   * The server responds with a **SYN+ACK** packet.
   * The client receives the SYN+ACK and updates its **send and receive windows** based on the sequence and acknowledgment numbers.

3. **Client (`INITIATOR`) → Server (`LISTENER`): ACK**
   * The client sends an **ACK** to acknowledge the connection.
   * The server receives the ACK and updates its **send window** accordingly.
   * At this point, both the client and server have successfully completed the initialization phase.

**Connection teardown**

When a socket has finished transmitting data, it calls `ut_close()` to terminate communication. Your task is to handle **receiving `FIN` packets** and **sending the corresponding `ACK` packets** as part of the termination process.

Either the **server** or **client** can initiate termination by sending a `FIN` packet when ready. The expected behavior is as follows:

1. When there is no more data to send, the socket sets the **sequence number** for the `FIN` packet (see `check_dying()`).
2. The initiating entity (server or client) sends a `FIN` packet (see the first `if` statement in `begin_backend()`).
   * Even after sending `FIN`, the socket must still be able to receive packets.
3. Upon receiving a `FIN` packet, the other entity responds with an `ACK`.
4. An entity can safely terminate its thread **after a timeout** if both of the following conditions are met (see `begin_backend()`):
   * It has received an **ACK** for its `FIN` packet.
   * It has received a **FIN** from the other entity.

```
**Note:** Simultaneous termination (where both the server and client send `FIN & ACK` in the same packet) is **not** considered in this assignment. You do not need to handle this scenario.
```

In this part, you will have to implement the following functions in `backend.c` to eatablish connections:

* `send_pkts_handshake()`
* `handle_pkt()` (Handle `FIN` packets in the function)
* `handle_pkt_handshake()`

---

#### Part2: Sliding Window and Flow Control

After completing the three-way handshake, the **server** and **client** are ready to send and receive data. To achieve efficient data transmission, you will implement **sliding window** and **flow control** mechanisms.

A **sliding window** allows the sender to transmit multiple packets before waiting for an acknowledgment (ACK). We recommend reading [Chapter 5.2](https://book.systemsapproach.org/e2e/tcp.html#sliding-window-revisited) in the P&D textbook for a deeper understanding of these concepts.

**Sliding Window at the Sender (`sock->send_win`)**

On the **sending side**, three pointers are maintained within the send buffer:

* **`last_ack`**: The last byte acknowledged by the receiver.
  * When a new ACK is received, update `last_ack` as: `last_ack = new ACK - 1`

* **`last_sent`**: The last byte sent by the socket.
  * Update `last_sent` when:
    1. Sending new packets.
    2. Retransmitting data starting from `last_ack`.

* **`last_write`**: The last byte written by the client or server using `ut_write()`.

```
              [send_win]
    ┌────────────────┬─────────────┐
    │                │             │
    └────────────────┴─────────────┘
    ^                ^             ^
last_ack         last_sent     last_write

* last_ack <= last_sent
* last_sent <= last_write
```

**Sliding Window at the Receiver (`sock->recv_win`)**

On the **receiving side**, three sequence number pointers are maintained:

* **`last_read`**: The last byte read by the client or server using `ut_read()`.
* **`next_expect`**: The next expected sequence number.
* **`last_recv`**: The last byte received.
  * There may be missing bytes between `next_expect` and `last_recv` if packets arrive out of order.

```
              [recv_win]
    ┌────────────────┬────░░░░░────┐
    │                │    ░░░░░    │
    └────────────────┴────░░░░░────┘
    ^                ^  <missing>  ^
last_read        next_expect   last_recv

* last_read < next_expect
* next_expect <= last_recv + 1
```

**Flow Control and Advertised Window**

* The **receiver’s advertised window** determines the maximum amount of data the sender can transmit.
  * The UT TCP header includes the `advertised_window` field to communicate this value.
    * The advertised window is calculated as: `advertised_window = MAX_NETWORK_BUFFER - (last_recv - last_read)`
  * The receiver updates the advertised window (`sock->send_adv_win`) as it processes incoming data.

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
  * For the ease of grading, we use static timeout in this assignment instead of using adaptive timeout methods such as Karn/Partridge algorithm.

In `backend.c`, you will implement or modify the following functions to implement the congestion control algorithm. We describe TODO items in the skeleton code. To show how the above state diagram can be implemented, we provide an example implementation of handling duplicated ACKs during the `fast recovery` state in the `handle_ack()` function:

* `handle_ack()`
* `handle_pkt()`
* `recv_pkts()`
* `send_pkts_data()`

#### Testing your implementation

We describe tools for developing and testing the implementation.

**Simple server and client**

We provide an example implementation of server and client that use UT-TCP sockets.
Please check `server.c` and `client.c` for more details.
To execute the programs, run the following commands. In this example, we assume you are running server and client in local environments.
Feel free to change the address and port in environment variables to what you prefer.

```bash
# Compile your UT TCP implementation along with server and client programs
make
```

```bash
# A terminal for server
UT_TCP_ADDR=127.0.0.1 UT_TCP_PORT=8000 ./server
```

```bash
# Another terminal for client
UT_TCP_ADDR=127.0.0.1 UT_TCP_PORT=8000 ./client
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

**Python unit test**

We provide testing tools using python `unittest` to manipulate packets and validate server and client behavior.

You can find example test cases in tests/test_ack_packets.py and sample server/client implementations in `tests/testing_[client/server].c`. Feel free to modify or add test cases as needed.

To run the Python tests, use the following command:

```bash
make
make test
```

**Kathara experiments**

You can test UT TCP under various network environments (e.g., inject losses).
For instance, you can force packet drops using the following example.
To isolate environment, we recommend to use Kathara labs.
Under `kathara-labs`, we provide two hosts (`h1`, `h2`) to be deployed using Kathara.
The following is how to test the above server and client examples under losses.

```bash
# Start Kathara environments
cd kathara-labs
kathara lstart
```

```bash
# H1 (Server)
kathara connect h1
cd /shared
# You can add packet losses using the following commands (Feel free to change the loss percentage):
# tcset eth0 --loss 1% --overwrite
UT_TCP_ADDR=10.1.1.3 UT_TCP_PORT=8000 ./server
```

```bash
# H2 (Client)
kathara connect h2
cd /shared
# You can add packet losses using the following commands (Feel free to change the loss percentage):
# tcset eth0 --loss 1% --overwrite
UT_TCP_ADDR=10.1.1.3 UT_TCP_PORT=8000 ./client
```

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

### Acknowledgement

This assignment is modified from CMU Computer Networks course (CMU 15-441/641) assignments.
No part of the project may be copied and/or distributed without the express permission of the course staff.
