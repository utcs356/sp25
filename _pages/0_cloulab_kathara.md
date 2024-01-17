---
layout: page
permalink: /assignments/assignment0
title: "Assignment 0: Cloudlab and Kathara"
---

#### **Released:** 01/16/2024 <br/> **Due:**	01/25/2024
{: .no_toc}

* (The list will be replaced with the table of contents.)
{:toc}

***

### Overview
You will do your assignments for CS 356 using  [CloudLab](http://cloudlab.us/) and [Kathara](https://www.kathara.org/). CloudLab is a research facility that provides bare-metal access and control over a substantial set of computing, storage, and networking resources. If you haven’t worked in CloudLab before, you need to register a CloudLab account. Kathara is a network emulation tool that enables you to test your network programs without multiple physical servers and network devices.
This small assignment walks you through the CloudLab registration process and shows you how to start an experiment in CloudLab. In addition, you will try out Kathara.
You should submit a per-group report that shows you have successfully followed the process.
Most importantly, it introduces our policies on using CloudLab that will be enforced throughout the semester.

**NOTE**: `$ [shell_command]` indicates to execute `[shell_command]` in your terminal.

### Register a CloudLab Account
* Visit [CloudLab](https://cloudlab.us/signup.php) and create an account using your UT Austin email address as an email.
![cloudlab_registration]({{site.baseurl}}/assets/img/assignments/assignment0/cloudlab_registration.png)
	* Select `Join Existing Project` and enter `utcs356`.
	* Fill out your information. Use your UT email address as an email.
	* Create ssh key pair and upload your public key during the account setup. 
		* Ubuntu and macOS
			1. Install OpenSSH \\
			macOS: `$ brew install openssh`\\
			Ubuntu: `$ sudo apt-get install openssh-client openssh-server`  
			2. Generate a key pair with `ssh-keygen`\\
			You can use the below example as it is or try other cryptographic algorithms you prefer (see [man ssh-keygen](https://man7.org/linux/man-pages/man1/ssh-keygen.1.html))  
			Example: `$ ssh-keygen -t rsa -b 4096`
			3. Type enter without typing any character when the prompt asks for the file path and passphrase. The private key will be saved into the default location, `~/.ssh/id_rsa`. `~/.ssh/id_rsa` is your private key and `~/.ssh/id_rsa.pub` is your public key (upload this during the account registration).\\
			+) If you want to save your keys other than the default location, enter a file path (e.g., `~/foo/mykey`) to save your private key when the prompt asks for it. `~/foo/mykey.pub` would be the public key in this case.   
			+) If you want additional security, type a passphrase when the prompt asks for it.

		* Windows
			1. Install [MobaXterm](https://mobaxterm.mobatek.net/download-home-edition.html) and execute it.
			2. Click `Tools>MobaKeyGen` 
			![windows_keygen_1]({{site.baseurl}}/assets/img/assignments/assignment0/windows_keygen_1.png)	
			3. Select parameters and click `Generate`. You can use the below parameters (RSA with 4096bits) or other parameters you want.
			![windows_keygen_2]({{site.baseurl}}/assets/img/assignments/assignment0/windows_keygen_2.png)
			4. Move your cursor to generate random numbers. If you don't, the process will hang.    
			5. Copy and paste the generated public key to the account setup page. Save your public and private keys to your preferred location.  
			+) If you want additional security, type `Key passphrase` before saving the keys.  
			![windows_keygen_3]({{site.baseurl}}/assets/img/assignments/assignment0/windows_keygen_3.png)

* If you already have an account, click your username at the top right corner and then select `Start/Join Project` and type `utcs356` into the ProjectID field.

Once you complete the above steps, the instructor or TA will approve your request to join the project so that you can start an experiment.

### Start an Experiment
An experiment in CloudLab means the instantiation of a profile. You can think of a profile as a pre-configured VM image that includes OS and necessary setup. An experiment lasts only for the reserved hours, and all the changes you made on top of the profile will be discarded. Make sure that you use a private git repository to save your code.

1. To start a new experiment, go to your CloudLab dashboard and click the `Experiments` tab in the upper left corner. Then select `Start Experiment`, moving to the profile selection panel.
![start_exp_step1]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step1.png)
2. Click `Change Profile`.
![start_exp_step2]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step2.png)
3. Select a profile from the list. Choose the `cs356-base` profile in the `utcs356` project. With this profile, you can launch one machine with the Ubuntu 22.04.2 LTS image with Docker and Kathara additionally installed.
![start_exp_step3]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step3.png)
4. Click `Next` to move to the next panel (`Parameterize`).
![start_exp_step4]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step4.png)
5. Click `Next` to move to the next panel (`Finalize`). You don't need to parameterize an experiment unless explicitly mentioned.
![start_exp_step5]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step5.png)
6. Here, you should name your experiment with `CSLogin1-CSLogin2` (`CSLogin1` is the cs username of Member 1), select `utcs356` as `Project`, and your assignment group as `Group` (You will be invited. If you're not yet invited, `Group` might not appear. You're ok to proceed without selecting `Group` for this assignment). You need to specify from which cluster you want to start your experiment. Please select the Wisconsin cluster. If it fails, then try another cluster. Click `Next` to move to the next panel (`Schedule`).
![start_exp_step6]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step6.png)
7. Enter the desired experiment duration and the time/date when you want to start the experiment. If you want to start your experiment as soon as possible, skip the `Start on date/time` field. Once your experiment is ready you will receive a notification email.
![start_exp_step7]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step7.png)
8. You can navigate to your CloudLab user dashboard to see your list of active experiments. You will move to a webpage describing project details by clicking on the experiment name. 
![start_exp_step8_1]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step8_1.png)
Click the `List View` on that page, which opens a table where you can obtain the SSH login command (`ssh <cloudlab_id>@<cloudlab_host>`) to log in to your machine.
![start_exp_step8_2]({{site.baseurl}}/assets/img/assignments/assignment0/start_exp_step8_2.png)

9. Try to login to the machine by executing the provided SSH command in your terminal. This step will only work if you have uploaded your SSH public key to your CloudLab account. Add your public key if you did not add it during the registration ([here](https://www.cloudlab.us/ssh-keys.php)). 
	* Ubuntu and macOS : `$ ssh <cloudlab_id>@<cloudlab_host>`
	* Windows:  On the MobaXterm window,
		1. Click `Session`.
		2. On the SSH tab, type `<cloudlab_host>` on `Remote host`, select the `Specify username` checkbox, and type 	`<cloudlab_id>`. Select the `X11-Forwarding` and `Use private key` checkboxes. Click the blue file icon and select the private key file you saved in the previous step. Launch an SSH session by clicking on `OK`.  
	![windows_ssh_setup]({{site.baseurl}}/assets/img/assignments/assignment0/windows_ssh_setup.png)	

**If you find yourself stuck on any of the above steps, don’t hesitate to post a question to Ed!**

### Tasks
#### Part 1: Check for the Available Resources
Check for the number of CPU cores available (use `$ sudo lshw -class cpu` or `$ lscpu`) and memory available (use `$ free -h`) on the node you reserved. 
**Report** the available resources in your report. 
#### Part 2: Executing Kathará
Throughout the assignments, we will use [Kathará](https://www.kathara.org/), an open-source container-based network emulation system. With the network emulation tools like Kathará, we can test (network) applications without multiple servers and network devices.

1. Setup  
After ssh to the reserved node, type the commands below.  
`$ sudo usermod -aG docker $USER`  
`$ touch ~/.Xauthority`   
Then **restart the SSH session** to make sure the changes are applied.    

2. Install and enable remote application display  
Kathará launches each network node as a container and spawns an Xterm terminal for each node. To access the terminals on your local machine, you must install an X display server and enable X11 forwarding on your local computer.
	* For Mac, install [XQuartz](https://www.xquartz.org/).
	Execute Xterm by clicking `XQuartz>Applications>Terminal`.  
	![xquartz_xterm]({{site.baseurl}}/assets/img/assignments/assignment0/xquartz_xterm.png)   
	Then type below on your local machine.    
	`$ ssh -X <cloudlab_id>@<cloudlab_host>` (add `-X` flag to the `[ssh_command]`)  
	`-X` flag enables X11 forwarding, which allows us to access remote application display.

	* For Linux, Xterm is installed by default. You just need to type the below command on your local machine.  
	`$ ssh -X <cloudlab_id>@<cloudlab_host>` (add `-X` flag to the `[ssh_command]`)

	* For Windows, MobaXterm will use Xterm for SSH sessions by default.

3. Type basic commands on the Kathara node.   
Run the below commands.   
`$ git clone https://github.com/utcs356/assignment1.git`  
`$ cd assignment1/labs/two_hosts_direct`  
`$ kathara lstart`  
Wait for Xterm popups. 2 terminals should appear.
Each terminal is connected to the virtual network device on the virtual network generated by Kathará. There are two virtual network devices in this Kathara lab, `h1` and `h2`.  
Run `$ ifconfig` to identify the network interfaces and their IP addresses on each device (terminal). ([man ifconfig](https://man7.org/linux/man-pages/man8/ifconfig.8.html))   
**Report** the IP address of the network interface attached to each device.

**NOTE:** Don't forget `$ kathara lclean` when your Kathara experiment is done.  
**NOTE:** You should follow these steps to run Kathará commands throughout the assignments.

#### Deliverable
Your report should be a pdf file named `assign0_groupX.pdf`, where `X` is your group number. Your report must include your group’s number, members, and their EIDs. Please submit one report per group.


### Policies on Using CloudLab Resources
* Please read and follow Cloudlab's [Acceptable Use Policy](https://www.cloudlab.us/aup.php).
* CloudLab gives users 16 hours to start with, and users can extend it longer. You can manage your time efficiently and only hold onto those nodes when working on the assignment. 
* You should use a private git repository to manage your code and terminate the nodes when you are not using them. If you do need to extend the nodes, do not extend them by more than one day. We will terminate any cluster running for more than 48 hours.
* As a member of the `utcs356` project, you have permission to create new experiments in the default group in addition to the group you are invited to. Stick to your own group and use naming formats as mentioned. For more information related to this, please refer to https://deanofstudents.utexas.edu/conduct/academicintegrity.php
* Each cluster has different hardware. For more information on CloudLab's hardware, please refer to [this](http://docs.cloudlab.us/hardware.html).
