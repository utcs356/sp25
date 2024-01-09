---
layout: page
permalink: /assignments/assignment1
title: "Assignment 1: Socket Programming and Measurement"
---
### Part 0: Setup and Overview
Clone the git repository contains the skeleton code for this assignment.  
`$ git clone `  
`Makefile` is included in the directory, so you can compile your code with `$ make` and clean the binary with `$ make clean`.
Your task is to complete `src/iperfer.c` to meet the specifications in Part 1 and perform measurements using your program.  


### Part 1: Write iperfer.c
* Client mode: Send TCP packets to a specific host for a specified time window and track how much data was sent during the time window.
    * Usage: `./iperfer -c -h <server_host_ipaddr> -p <server_tcp_port> -t <duration>`  
        * `-c` indicates the client mode.  
        * `-h <server_host_ipaddr>` specifies the IP address of a server to connect.   
        * `-p <server_tcp_port>` specifies the TCP port number of a server to connect.  
        * `-t <duration>` specifies the duration for which the program will send data.
    * Specification
        * Error handling: check port number, check the required parameters are given.
        * Create a socket with `socket` then `connect` to the server specified by command line arguments.  
        (`<server_host_ipaddr>` and `<server_tcp_port>`)  
        * Data should be sent in chunks of 1000bytes and the data should be all zeros.
        * The program should close the connection and stop after the specified time (`<duration>`) has passed.  
        * When the connection is closed, the program should print out the elapsed time, the total number of bytes sent (in kilobytes), and the rate at which the program sent data (in Mbps) (1kilobyte=1000bytes, 1megabit = 1,000,000 bits = 125,000 bytes)


* Server mode: open a socket and make it listen on the specified port.
    * Usage: `./iperfer -s -p <server_tcp_port>`   
        * `-s` indicates the server mode.
        * `-p <server_tcp_port>` specifies the TCP port number to which the server will bind.
    * Specification
        * Error handling: check the given port number is between 1 and 65535.  
        * Create socket with `socket`.
        * `bind` socket to the given port (`<server_tcp_port>`) and `listen` for TCP connections.
        * Then wait for the client connection with `accept`.
        * After the connection is established, received data in chunks of 1000bytes
        * When the connection is closed, the program should print out the elapsed time, the total number of bytes received (in kilobytes), and the rate at which the program received data (in Mbps) (1kilobyte=1000bytes, 1megabit = 1,000,000 bits = 125,000 bytes)

**Report** your iperfer client results when run it for 10 seconds in the given `two_hosts_direct` topology. Two hosts, h1 and h2, are directly connected in this topology.


### Part 2: Measurement on a virtual network
In this part of the assignment, you will use the tool you wrote (iperfer) and ping to measure a given virtual network's end-to-end bandwidth and latency. We will use `six_hosts_two_routers` topology. The virtual network toplogy is formed as follows:
* There are 6 hosts, `h[1-6]`, and 2 routers, `r[1-2]`.
* `h1`,`h2`,`h3` are connected to `r1`, and `h4`,`h5`,`h6` are connected to `r2`. `r1` and `r2` are connected with a single link.  
Q1: Measure and report link latency and throughput between two adjacent routers, `r1` and `r2`.  
Q2: Measure and report path latency and throughput between two hosts, `h1` and `h4`.  
Q3: Effects of multiplexing 
We will study what happens when multiple hosts connected to `r1` simultaneously talk to hosts connected to `r2`. Report the average RTT and bandwidth measurement varying the number of host pairs. The host pairs are (`h1`,`h4`), (`h2`,`h5`), (`h3`,`h6`).  
Q4: Increase the bandwidth of the link between `r1` and `r2` and repeat 3.  

### Submission and grading
You must submit:
* A tar ball file of the modified assignment1 directory.
    * `$ tar -zcvf assignment1 assign1_username1_username2.tar.gz`
    * Replace `username1` and `username2` with your CS usernames.
* A pdf file contains the Part 1 results and the measurement results for Part 2.
    * The PDF file must contain the names and eids of all group memebers.

### Grading:
* correctness of iperfer.py
	* Based on our test cases: 40%
	* TODO: test case / rubric
* Part 1 results
    * client-side result screenshot: 10%
	* server-side result screenshot: 10%
* Measurement results and your explanation of results.
	* Q1 10% - do the numbers match the link bandwidth and latency?
    * Q2 10% - do the numbers match the link bandwidth and latency?
	* Q3 10% - do the numbers decrease when adding more host pairs?
	* Q4 10% - are the numbers are better than Q3?

### Appendix. Kathara tutorial
Kathara lab is a set of preconfigured (virtual) devices. A basic Kathara lab is a directory tree containing:  
* lab.conf ⇒ describes the network topology and the devices to be started
    * Syntax: `machine[arg]=value``
        * machine is the name of the device
        * if arg is a number ⇒ value is the name of a collision domain to which eth arg should be attached
        * if arg is not a number, then it must be an option and value the argument
* Subdirectories: contains the configuration settings for each device
* `<device_name>.startup` files that describe actions performed by devices when they are started shell script that is executed right after its startup