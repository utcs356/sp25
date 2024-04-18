---
layout: page
permalink: /assignments/assignment5
title: "Assignment 5: Hierarchical DNS"
---

### Part 0: Setup and Overview
#### Setup
In this assignment, we recommend you use `cs356-base` or `cs356-p4` profile on CloudLab for implementing and testing your code.
To get the skeleton code, create a **private** repository by clicking `Use this template> Create a repository` on the [GitHub repository](https://github.com/utcs356/assignment5.git).

#### Overview
In this assignment, you will implement DNS servers that enable a client to access nodes with domains instead of raw IP addresses. Your task is to complete the implementation of DNS nameservers for the `utexas.edu` zone and `cs.utexas.edu` zone (Part 1) and a local DNS server that can handle the query iteratively (Part 2). We provide you with a DNS library that does tedious jobs such as message parsing on behalf of you. Refer to the Appendix for more details on the library. For simplicity, you can assume there are no incoming queries other than `A, AAAA, NS` queries.

You will run this experiment on top of Kathara. The Kathara topology is depicted below. The Kathara lab is located in the `[a5_directory]/labs/dns`.    
![a5_topology]({{site.baseurl}}/assets/img/assignments/assignment5/A5_topology.png)   

### Part 1: Writing DNS servers
Your task is to complete `ut-dns.c` and `cs-dns.c` in the `[a5_directory]/labs/dns/shared/src` directory. `ut-dns.c` and `cs-dns.c` are the nameservers for `utexas.edu` and `cs.utexas.edu`, respectively. The implementation of the two servers should be almost the same except for the DNS records they store. We recommend you implement `ut-dns.c` first, copy and paste it to `cs-dns.c`, and change it a bit. Note that they are **NOT** recursive nor iterative DNS servers, so their responses are only based on their own DNS records.

The overview for this part of the assignment is depicted below.    
![a5_p1]({{site.baseurl}}/assets/img/assignments/assignment5/A5_P1.png)   

#### Specification
You can find the step-by-step specifications in the starter codes as well.
* The servers should receive a message on top of UDP. Note that a UDP server doesn't have to `listen()` and `accept()` since it is connectionless, unlike TCP (what we did in A1). Also, the UDP server should use `sendto()`/`recvfrom()` to set/get a client's address along with sending/receiving a message.
* Initialize a server-wide context (e.g., DNS records) using TDNSInit(). The context will be used for future DNS-related operations such as searching for a DNS record.
* Create a zone using `TDNSCreateZone` and add records to the server `TDNSAddRecord`. You should be able to infer the contents of records from the comments in the source code and the topology figure.
* Receive a message continuously and parse it using `TDNSParseMsg()`.
* If the received message is a query for A, AAAA, or NS, find the corresponding record using `TDNSFind()` and return the response. Ignore all the other messages.

#### Test your implementation
1. Compile your code with `$ make` in the lab's shared directory (`[a5_directory]/labs/dns/shared`). The compiled binary would be in the `[a5_directory]/labs/dns/shared/bin` directory.
2. Run a server on the corresponding Kathara node. Make sure to start an experiment with `$ kathara lstart`.   
For testing `ut-dns.c`,     
`$ kathara connect ut_dns`   
`$ ./shared/bin/ut-dns`    
For testing `cs-dns.c`,    
`$ kathara connect cs_dns`   
`$ ./shared/bin/cs-dns`    
3. Send A queries and check the response with `$ dig`.    
`$ kathara connect h1`   
* For testing `ut-dns.c`, run below on `h1`.   
`$ dig @40.0.0.20 A www.utexas.edu`      
`$ dig @40.0.0.20 A thisshouldfail.utexas.edu`     
`$ dig @40.0.0.20 A cs.utexas.edu`     
`$ dig @40.0.0.20 A aquila.cs.utexas.edu`     
* For testing `cs-dns.c`, run below on `h1`.   
`$ dig @50.0.0.30 A cs.utexas.edu`     
`$ dig @50.0.0.30 A aquila.cs.utexas.edu`     
`$ dig @40.0.0.20 A thisshouldfail.cs.utexas.edu`     

### Part 2: An Iterative Local DNS Server
Your task is to complete `local-dns.c` in the `[a5_directory]/labs/dns/shared/src` directory. `local-dns.c` is a default nameserver for the on-campus network. Note that it is an iterative DNS server, so its response should be always an answer or error. If it receives a DNS record that indicates delegation (referral), it should resolve a query iteratively.
The below figure is an example of an iterative query resolution that is possible in our setup.     
![a5_p2]({{site.baseurl}}/assets/img/assignments/assignment5/A5_P2.png)    

#### Specification
You can find the step-by-step specifications in the source code as well.
* The servers should receive a message on top of UDP.
* Initialize a server-wide context (e.g., DNS records) using TDNSInit(). The context will be used for future DNS-related operations such as searching for a DNS record.
* Create a zone using `TDNSCreateZone` and add records to the server `TDNSAddRecord`. You should be able to infer the contents of records from the comments in the source code and the topology figure.
* Receive a message continuously and parse it using `TDNSParseMsg()`.
* If the received message is a query for A, AAAA, or NS, find the corresponding record using `TDNSFind()`. Ignore all the other messages.
    1. If the record is found and the record indicates delegation, send an iterative query to the corresponding nameserver. Note that the server should store a per-query context using `putAddrQID()` and `putNSQID()` for future response handling.
    2. If the record is found and the record doesn't indicate delegation, send a response back to the client.
    3. If the record is not found, send a response back to the client. (The library would set the error flag.)
* If the received message is a response
    1. and it is an authoritative response (i.e., final response), add the NS information to the response and send it to the original client. Delete a per-query context using `delAddrQID()` and `putNSQID()`. You can retrieve the NS and client address information for the response using `getNSbyQID()` and `getAddrbyQID()`. You can add the NS information to the response using `TDNSPutNStoMessage()`.  
    2. and it is a non-authoritative response (i.e., it indicates delegation), send an iterative query to the corresponding nameserver. You can extract the query from the response using `TDNSGetIterQuery()`. The server should update a per-query context using `putNSQID()`.

### Test your implementation
1. Compile your code with `$ make` in the lab's shared directory (`[a5_directory]/labs/dns/shared`). The compiled binary would be in the `[a5_directory]/labs/dns/shared/bin` directory.
2. Run the DNS servers on the corresponding Kathara nodes. 
* Run a Kathara experiment.  
`$ kathara lstart`   
* Run the UT nameserver.  
`$ kathara connect ut_dns`   
`$ ./shared/bin/ut-dns`    
* Run the CS nameserver.  
`$ kathara connect cs_dns`   
`$ ./shared/bin/cs-dns`  
* Run the local DNS server.    
`$ kathara connect local_dns`    
`$ ./shared/bin/local-dns`    
3. Configure the local DNS server on `h1`.    
`$ kathara connect h1`         
`$ echo "nameserver 20.0.0.10" >> /etc/resolv.conf`   
4. Send A queries and check the response with `$ dig` on `h1`.       
`$ dig A ns.utexas.edu`       
`$ dig A www.utexas.edu`     
`$ dig A abc.utexas.edu`     
`$ dig A cs.utexas.edu`      
`$ dig A aquila.cs.utexas.edu`    
`$ dig A abc.utexas.edu`   
5. Try to use domain names with `$ ping`.    
The `-n` flag is necessary since the servers ignore a reverse query (PTR).   
`$ ping -n www.utexas.edu`    
`$ ping -n aquila.cs.utexas.edu`    

### Submission
Please submit your code (modified assignment5 repository) to the Canvas Assignments page in either `tar.gz` or `zip` format.  
The naming format for the file is `assign5_groupX.[tar.gz/zip]`.

### Appendix: TDNS Library 
The header file is in `[a5_directory]/labs/dns/shared/src/lib/tdns/tdns-c.h`. For the exact usage, refer to the comments and declarations below.

```c
/* Macros */
#define MAX_RESPONSE 2048

#define TDNS_QUERY 0
#define TDNS_RESPONSE 1

enum TDNSType
{
  A = 1, NS = 2, CNAME = 5, SOA=6, PTR=12, MX=15, TXT=16, AAAA = 28, SRV=33, NAPTR=35, DS=43, RRSIG=46,
  NSEC=47, DNSKEY=48, NSEC3=50, OPT=41, IXFR = 251, AXFR = 252, ANY = 255, CAA = 257
};


/* Server-wide context */
/* Maintains DNS records in a hierarchical manner */
/* and per-query contexts for handling iterative queries */
/* In the assignment, the server can contain only two kinds of records. */
/* One contains an IP address, and the other points to another nameserver */
struct TDNSServerContext;


/* Result for TDNSParseMsg */
struct TDNSParseResult {
  struct dnsheader *dh; /* parsed dnsheader, you need this in Part 2 */
  uint16_t qtype; /* query type, the value should be one of enum TDNSType values */
  const char *qname; /* query name (i.e. domain name for A type query) */
  uint16_t qclass; /* query class */

  /* Below are for handling a referral response (delegation). */ 
  /* These should be NULL if it's not a referral response */
  const char *nsIP;  /* an IP address to the nameserver */
  const char *nsDomain; /* an IP address to the nameserver */
};

/* Result for TDNSFind function */
struct TDNSFindResult {
  char serialized[MAX_RESPONSE]; /* a DNS response string based on the search result */
  ssize_t len; /* the response string's length */
  
  /* Below is for delegation */
  const char *delegate_ip; /* IP to the nameserver to which a server delegates a query */
};

/*************************/
/* For both Part 1 and 2 */
/*************************/

/* Initializes the server context and returns a pointer to the server context */
/* This context will be used for future TDNS library function calls */
struct TDNSServerContext *TDNSInit(void);

/* Creates a zone for the given domain, zoneurl */
/* e.g., TDNSCreateZone(ctx, "google.com") */
void TDNSCreateZone (struct TDNSServerContext *ctx, const char *zoneurl);

/* Adds either an NS record or A record for the subdomain in the zone */
/* A record example*/
/* e.g., TDNSAddRecord(ctx, "google.com", "www", "123.123.123.123", NULL) */
/* NS record example */
/* Below will also implicitly create a maps.google.com zone */
/* e.g., TDNSAddRecord(ctx, "google.com", "maps", NULL, "ns.maps.google.com")*/
/* Then you can add an IP for ns.maps.google.com like below */
/* e.g., TDNSAddRecord(ctx, "maps.google.com", "ns", "111.111.111.111", NULL)*/
void TDNSAddRecord (struct TDNSServerContext *ctx, const char *zoneurl, const char *subdomain, const char *IPv4, const char* NS);

/* Parses a DNS message and stores the result in `parsed` */
/* Returns 0 if the message is a query, 1 if it's a response */ */
/* Note: Don't forget to specify the size of the message! */
/* If the message is a referral response, parsed->nsIP and parsed->nsDomain will contain */
/* the IP address and domain name for the referred nameserver */
uint8_t TDNSParseMsg (const char *message, uint64_t size, struct TDNSParseResult *parsed);

/* Finds a DNS record for the query represented by `parsed` and stores the result in `result`*/
/* Returns 0 if it fails to find a corresponding record */
/* Returns 1 if it finds a corresponding record */
/* If the record indicates delegation, result->delegate_ip (or parsed->nsIP) will store */
/* the IP address to which it delegates the query */
/* parsed->nsDomain will store the domain name to which it delegates the query. */
uint8_t TDNSFind (struct TDNSServerContext* context, struct TDNSParseResult *parsed, struct TDNSFindResult *result);

/**************/
/* for Part 2 */
/**************/

/* Extracts a query from a parsed DNS message and stores it in serialized */
/* Returns the size of the serialized query in bytes. */
/* This is useful when you extract a query from a referral response. */
ssize_t TDNSGetIterQuery(struct TDNSParseResult *parsed, char *serialized);

/* Puts NS information to a DNS message */
/* message will be updated, and the updated length will be returned. */
/* This should be used when you get the final answer from a nameserver */
/* to let a client know the trajectory. */
uint64_t TDNSPutNStoMessage (char *message, uint64_t size, struct TDNSParseResult *parsed, const char* nsIP, const char* nsDomain);

/* For maintaining per-query contexts */
void putAddrQID(struct TDNSServerContext* context, uint16_t qid, struct sockaddr_in *addr);
void getAddrbyQID(struct TDNSServerContext* context, uint16_t qid, struct sockaddr_in *addr);
void delAddrQID(struct TDNSServerContext* context, uint16_t qid);
void putNSQID(struct TDNSServerContext* context, uint16_t qid, const char *nsIP, const char *nsDomain);
void getNSbyQID(struct TDNSServerContext* context, uint16_t qid, const char **nsIP, const char **nsDomain);
void delNSQID(struct TDNSServerContext* context, uint16_t qid);

```


### Acknowledgements
The C DNS library used in this assignment built on top of the `tdns` c++ library from the [`hello-dns`](https://powerdns.org/hello-dns/) project.
