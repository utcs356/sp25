---
layout: page
permalink: /assignments/assignment0
title: "Assignment 0: Cloudlab and Kathara"
---

#### **Released:** 01/16/2024 <br/> **Due:**	01/23/2024

### Overview
You will do your assignments for CS 356 using  [CloudLab](http://cloudlab.us/) . CloudLab is a research facility that provides bare-metal access and control over a substantial set of computing, storage, and networking resources. If you haven’t worked in CloudLab before, you need to register a CloudLab account.
This small assignment walks you through the CloudLab registration process and shows you how to start an experiment in CloudLab.
Most importantly, it introduces our policies on using CloudLab that will be enforced throughout the semester.


### Register a CloudLab account
* Visit https://cloudlab.us and create an account using your UT Austin email address as login.
	* Create ssh key pair and upload your public key during the account setup. 
		1. Install OpenSSH 
		`$ brew install openssh` for macOS.
		`$ sudo apt-get install openssh-client openssh-server` for Ubuntu.

		2. Generate a key pair with `ssh-keygen`, you can use the below command as it is or try other cryptographic algorithms you prefer (see [man ssh-keygen](https://man7.org/linux/man-pages/man1/ssh-keygen.1.html))
	`$ ssh-keygen -t rsa -b 4096`
		3. Enter a file location to save the key when the prompt asks for it
		4. `<your_key_path>/.ssh/id_rsa`  is your private key and `<your_key_path>/.ssh/id_rsa.pub` is your public key (upload this during the account registration).  
	* Click `Join Existing Project` and enter `utcs356`. 

* If you already have an account, click your username at the top right corner and then select  `Start/Join Project`, Type `utcs356` into the ProjectID field.

### Start An Experiment
* To start a new experiment, go to your CloudLab dashboard and click on the Experiments tab in the upper left corner, then select Start Experiment. This will lead to the profile selection panel.
* Click on Change Profile, and select a profile from the list. For example, if you choose the `cs356-base` profile in the `utcs356` project you will be able to launch 1 machine with the Ubuntu 22.04.2 LTS image with Docker and Kathara additionally installed.
* Select the profile and click on Next to move to the next panel. Here you should name your experiment with CSLogin1_CSLogin2 (CSLogin1 is the cs username of Member 1), select `utcs356` as the project and your respective group (you were/will be invited). Students from other groups will not be able to login to your experiment machine, so your assignment files are safe :)
* You also need to specify from which cluster you want to start your experiment. Each cluster has different hardware. For more information on the hardware CloudLab provides, please refer to  [this](http://docs.cloudlab.us/hardware.html). Please select the Wisconsin cluster, if it fails, then try another cluster.
* Once you select the cluster you can instantiate the experiment by entering the time and day when you want to start the experiment. Once your experiment is ready you will receive a notification email. You can navigate to your CloudLab user dashboard where you can see your list of active experiments.
* On clicking on the experiment name, you will be navigated to a webpage describing project details. Click on the list view on that page which opens a table where you can obtain the ssh login command to log in to your machine.
* Try to login to the machine and check for the number of CPU cores available and memory available on the node. This step will only work if you have uploaded your ssh key to your CloudLab account ( [here](https://www.cloudlab.us/ssh-keys.php) ).
* **If you find yourself stuck on any of the above steps, don’t hesitate to post a question to Ed!**


### Policies on Using CloudLab Resources
* The nodes you receive from CloudLab are real hardware machines sitting in different clusters. Therefore, we ask you not to hold the nodes for too long.
* CloudLab gives users 16 hours to start with, and users can extend it for a longer time. Manage your time efficiently and only hold onto those nodes when you are working on the assignment. 
* You should use a private git repository to manage your code, and you must terminate the nodes when you are not using them. If you do have a need to extend the nodes, do not extend them by more than 1 day. We will terminate any cluster running for more than 48 hours.
* As a member of the `utcs356` project, you have permission to create new experiments in the default group in addition to the group are you invited to. Stick to your own group and use naming formats as mentioned. For more information related to this, please refer to https://deanofstudents.utexas.edu/conduct/academicintegrity.php
