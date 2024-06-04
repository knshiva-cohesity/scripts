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
TBD
 
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
