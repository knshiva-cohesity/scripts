# Oracle DB Configuration Checker
Warning: this code is provided on a best effort basis and is not in any way officially supported or sanctioned by Cohesity. The code is intentionally kept simple to retain value as example code. The code in this repository is provided as-is and the author accepts no liability for damages resulting from its use.

This tool when run on a Host running Oracle DB (Standalone or RAC) provides output grouped as below:
* Host parameters
* Oracle DB parameters
* Oracle DB Layout
* RMAN Config
* Host and Cohesity Cluster Ports availability

The output is displayed on the terminal and logged in text format (default) files for each group.

# Dependencies
bash shell
	
# Supported on Linux
Tested on RHEL and Oracle Linux 7.9 running Oracle 19c
	
# Download the script
	Login to Linux host, where Oracle DB is running, switch to Oracle user account.
	[oracle@linux ]$ curl -Ok "https://raw.githubusercontent.com/knshiva-cohesity/scripts/main/oracfgchkr/{prechckr.sh,cmds.input,t.sql}"
	[oracle@linux ]$ chmod +x prechckr.sh
 
# Parameters
* Mandatory - Oracle DB SID
* Optional  - List of Cohesity Cluster nodes, output file format (csv)
		
# Example
    [oracle@oracle-rac2-dbt1 ~]$ ./prechckr.sh 
    Welcome to Cohesity Pre-Checker Tool! 
    Provided args are incorrect, refer Usage below... 
    Usage: 
    [oracle@oracle-rac2-dbt1 ~]$ ./prechckr.sh <oracle sid> ["<List of Cluster Node IPs>"] [csv | json]
  
    Example: 
    [oracle@oracle-rac2-dbt1 ~]$ ./prechckr.sh orcl "10.1.2.1,10.1.2.2,10.1.2.3"

# Sample run and output
	[oracle@knsrhel84 ~]$ ./prechckr.sh bang "10.15.15.60"
	Welcome to Cohesity Pre-Checker Tool!
	Found bang in running state...
	
	* * * * * * * * * * * * * * * * * * * * *
	* * * * *  O S   P a r a m s  * * * * * *
	* * * * * * * * * * * * * * * * * * * * *
	
	Operating System: "Red Hat Enterprise Linux 8.4 (Ootpa)"
	Number of CPUs on the host: 4
	Total Memory on the host: MemTotal:       16211648 kB
	SELinux status:                 disabled
	NFS Client Utils installed: Yes
	Cohesity Agent installed: Yes
	Cohesity Agent running: Yes
	ASM is running: No
	RAC is running: No
	ORACLE HOME is : /u01/app/oracle/product/19.0.0/dbhome_1
	Find the output in text format at: dbhostparams_bang.output
	
	* * * * * * * * * * * * * * * * * * * * *
	* * * * *  D B   P a r a m s  * * * * * *
	* * * * * * * * * * * * * * * * * * * * *
	
	The DB version is: 19.3.0.0.0
	The DB edition is: Oracle Database 19c Enterprise Edition
	dNFS enabled: No
	The DB instance is: bang
	The DB ID is: 3133429336
	The DB Name is: BANG
	The DB Unique name is: bang
	The DB Platform name is: Linux x86 64-bit
	The DB log mode is: ARCHIVELOG
	The DB flashback is: NO
	Is this CDB/Multitenant?: NO
	The Number of PDBs: 0
	The DB status is: OPEN
	The DB size based on segments in GiB: 2.13
	The Total bigfile Datasize in GiB:
	The Biggest bigfile in GiB:
	The allocated DB size based on datafile in GiB: 2.53
	The total datafiles in the DB is: 4
	The total tablespaces in the DB is: 5
	Bigfile tablespace count: 0
	Bigfile Data size in MiB:
	TEMP datafile count is: 1
	The daily redo size in MiB is: 575.7
	The daily change rate in %: 4.41
	The DB Block size in bytes: 8192
	The DB spfile is present: YES
	Patchlevel is: Database Release Update : 19.3.0.0.190416 (29517242)
	Is it Cluster: FALSE
	Cluster DB Instances: 1
	SGA MAX SIze: 4.640625
	SGA Target size in GiB: 4.64
	PGA Target size in GiB: 1.55
	Is it GoldenGate config: YES
	Is it Exadata enabled: NO
	Is Block Change Tracking enabled: DISABLED
	Archive Log Config: dg_config=(bang,pune)
	Archive Lag Target: 0
	Total tablespace count: 5
	TDE enabled: NO
	TSE enabled: NO
	Encrypted tablespace count: 0
	Encrypted Datasize in MiB:
	FRA configured:
	FRA size in GiB: 0
	Are datafiles on ASM: No
	Are archive log files on ASM: No
	Are REDO log files on ASM: No
	Is Control file on ASM: No
	Find the output in text format at: dbparams_bang.output
	
	* * * * * * * * * * * * * * * * * * * * *
	* * * * *  D B   L a y o u t  * * * * * *
	* * * * * * * * * * * * * * * * * * * * *
	
	Find the output in text format at: dblayoutop_bang.output
	
	* * * * * * * * * * * * * * * * * * * * *
	* * * * *  R M A N   C o n f i g  * * * *
	* * * * * * * * * * * * * * * * * * * * *
	
	Find the output in text format at: rmanparams_bang.output
	
	* * * * * * * * * * * * * * * * * * * * *
	* * * * *  P O R T   Q u e r y  * * * * *
	* * * * * * * * * * * * * * * * * * * * *
	
	Oracle Host Port 50051: CLOSED
	- - -
	Cluster Node 10.15.15.60 Port 111: OPEN
	Cluster Node 10.15.15.60 Port 2049: OPEN
	Cluster Node 10.15.15.60 Port 11111: OPEN
	Find the output in text format at: host_cluster_ports_bang.output
	
	[oracle@knsrhel84 ~]$ ls -l *output
	-rw-r--r-- 1 oracle oinstall  367 Nov 12 10:33 dbhostparams_bang.output
	-rw-r--r-- 1 oracle oinstall 1019 Nov 12 10:33 dblayoutop_bang.output
	-rw-r--r-- 1 oracle oinstall 1442 Nov 12 10:33 dbparams_bang.output
	-rw-r--r-- 1 oracle oinstall  154 Nov 12 10:33 host_cluster_ports_bang.output
	-rw-r--r-- 1 oracle oinstall 1359 Nov 12 10:33 rmanparams_bang.output
