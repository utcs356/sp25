---
layout: page
permalink: /assignments/assignment1
title: "Assignment 1: Socket Programming and Measurement"
---
{: .no_toc}

* (The list will be replaced with the table of contents.)
{:toc}

### Part 0: Setup and Overview
#### Setup
Fork the [git repository](https://github.com/utcs356/assignment1.git) that contains Kathara labs and the skeleton code needed for this assignment. Keep your repository private.
When you want to make changes on your private repository on a CloudLab node, you have to authenticate every time you insantiate an experiment. This is because your authentication information is cleaned up upon the end of the experiment. There are three ways to authenticate your account on the reserved node.
* With VS Code:  
    * Once you install the `Github Pull Requests and Issues` extension on VS Code, you can authenticate the remote server through VS Code and a web browser. You also can clone the repository on VS Code to the remote server. 
    * Refer to [link1](https://vscode.github.com/) and [link2](https://code.visualstudio.com/docs/sourcecontrol/github).
* With personal access tokens:
    * You can generate a personal access token for the account/repositories so that you can access your repositories over HTTPS with the token. 
    * Refer to [this link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for details.
* With SSH key,
    1. Generate SSH key pair with `ssh-keygen` on the CloudLab node.
    2. Upload the generated public key to `Settings>SSH and GPG keys>New SSH key` on Github.
    3. Clone your repostiroy with the SSH option. 


Don't forget execute below for every experiment insantiation.   
* After ssh to the reserved node, type the commands below.  
    `$ sudo usermod -aG docker $USER`  
    `$ touch ~/.Xauthority`   
* Then **restart the SSH session** to make sure the changes are applied. 

#### Overview
Your task is to complete `src/iperfer.c` to meet the specifications in Part 1 and perform measurements using your program in Part2.

### Part 1: Write iperfer.c
Your task is to complete the source code for `iperfer`. `iperfer` is a program to measure the throughput between two hosts. It should be executed on one host in the server mode and then executed on the other in the client mode. Argument parsing is already implemented in the skeleton code. Refer to the below specifications for implementation details: 
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

**Report** your iperfer client results when run it for 10 seconds in the given `two_hosts_direct` topology. Two hosts, h1 and h2, are directly connected to each other in this topology. In the terminal for each host, your binary is located in `/shared` directory. This is a mirror of your local file located in `labs/two_hosts_direct/shared` directory. 

#### Notes
* **Compile**: `Makefile` is included in the directory, so you can compile your code with `$ make` and remove the compiled binary with `$ make clean`. The compiled binary will be located in the `bin` and `labs/<lab_name>/shared` directories.
* **Test within a single host**: You may want to test your program prior to Kathara experiments. In this case, execute the client mode with `127.0.0.1` as the `<server_host_ip_addr>` after executing server mode on the same node. `127.0.0.1` is the reserved IP address for local host (loopback).

### Part 2: Measurement on a virtual network
In this part of the assignment, you will use the tool you wrote (`iperfer`) and `ping` to measure a given virtual network's end-to-end bandwidth and latency, respectively. We will use `six_hosts_two_routers` topology. The virtual network toplogy is formed as follows:
* There are 6 hosts, `h[1-6]`, and 2 routers, `r[1-2]`.
* `h1`,`h2`,`h3` are connected to `r1`, and `h4`,`h5`,`h6` are connected to `r2`. `r1` and `r2` are connected with a single link.  

#### **Q1**: Basic measurements 
* Measure and report average RTT and throughput between two adjacent routers, `r1` and `r2`. 
* Measure and report average RTT and throughput between two hosts, `h1` and `h4`.

#### **Q2**: Impact of multiplexing on latency.  
* Measure and report average RTT between two hosts, `h1` and `h4`, while measuring bandwidth between `h2` and `h5`.
* How does it compare to the measured latency in Q1?

#### **Q3**: Impact of multiplexing on throughput
* Report the throughput between every pair of hosts varying the number of host pairs that conduct measurements. 
    * The host pairs are (`h1`,`h4`), (`h2`,`h5`), (`h3`,`h6`).  
* How does it compare to the measured throughput in Q1?
* What's the trend between measured throughput and the number of host pairs?

#### **Q4**: Impact of link capacity on end-to-end throughput and latency.
* Decrease link rate between `r1` and `r2` to 10Mbps. This can be done by uncomment the line #5 in the `labs/six_hosts_two_routers/r1.startup` file. You have to relaunch the Kathara lab after the change.
* Measure and report path latency and throughput between two hosts, `h1` and `h4`.
* How does it change compared to Q1? 

#### **Q5**: Impact of link latency on end-to-end throughput and latency.
* Comment the line #5 that you uncommented for the previous question.
* For each case below, measure and report path latency and throughput between two hosts, `h1` and `h4`.
    * Change link delay between `r1` and `r2` to 10ms by uncommenting the line #6. 
    * Change link delay between `r1` and `r2` to 100ms by uncommenting the line #7. Comment out line #6.
    * Change link delay between `r1` and `r2` to 1s by uncommenting the line #8. Comment out line #7.
* What's the trend between measured throughput and latency?

### Submission
You must submit:
* A tar ball file of the modified assignment1 directory.
    * `$ tar -zcvf assignment1 assign1_username1_username2.tar.gz`
    * Replace `username1` and `username2` with your CS usernames.
* A pdf file contains the Part 1 results and the measurement results for Part 2.
    * The PDF file must contain the names and eids of all group memebers.

### Grading
* `iperfer.c` implementation
	* Command line argument verification: 5%
    * Server mode implementation: 15%
    * Client mode implementation: 15%
* Part 1 results: 15%

* Part 2 results
	* Q1: 10%
    * Q2: 10%
	* Q3: 10%
	* Q4: 10%
    * Q5: 10%

### Appendix. Kathara tutorial
Kathara lab is a set of preconfigured (virtual) devices. A basic Kathara lab is a directory tree containing:  
* lab.conf ⇒ describes the network topology and the devices to be started
    * Syntax: `machine[arg]=value``
        * machine is the name of the device
        * if arg is a number ⇒ value is the name of a collision domain to which eth arg should be attached
        * if arg is not a number, then it must be an option and value the argument
* Subdirectories: contains the configuration settings for each device
* `<device_name>.startup` files that describe actions performed by devices when they are started.

To deploy virtual network, move to the Kathara lab directory then type `$ kathara lstart`. Then the xterm terminal connected to each virtual network device would appear. To terminate the deployment, type `$ kathara lclean`. Some useful kathara commands are summarized [here](https://www.kathara.org/man-pages/kathara.1.html)