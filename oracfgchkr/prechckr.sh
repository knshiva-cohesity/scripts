#!/bin/bash

# - - - - - - - - 
# Version:  1.0
# - - - - - - - - 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Description: Script to gather pre-defined set of Oracle DB params
#
# Input: Oracle DB SID
#
# Output: Oracle DB parameters printed on stdout
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

# - - - - - - - - -
# Global Variables
# - - - - - - - - -

dbHostName=$(hostname)
dbSID=
dbport=1521
dbuserName=system
dbuserPasswd=""
dbusrlogin="<username\\password>"
osusrlogin=""
runsql=""
queries="t.sql"
USERNAME="oracle"
SUUSER=""
ORACLESID=$1
OUTPUTFILE="dbparams""_$1"
DBLAYOUTOPFILE="dblayoutop""_$1"
DBHOSTPARAMSFILE="dbhostparams""_$1"
RMANOPFILE="rmanparams""_$1"
PORTOPFILE="host_cluster_ports""_$1"
isASM=""
isRAC=""
queryop=''
rqueryop=''
GRD_HOME=""
ORA_HOME=""
NoOfRACNodes=""
ClusterName=""
txtopf=""
hosttxtopf=""
laytxtopf=""
rmantxtopf=""
porttxtopf=""
cohagntPort=50051


#dbconn() {
#	#runsql="sqlplus -s "$dbusrlogin"@\"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST="$dbHostName")(PORT="$dbPort"))(CONNECT_DATA=(SID="$dbSid")))\" @"$queries"" 
#	runsql="export ORACLE_SID=vorcl1; sqlplus -s \"/ as sysdba\" @$sql"	
#	eval "$runsql"
#}


prtchk() {
	porttxtopf=$PORTOPFILE".output"
	if [ -f $porttxtopf ]; then
		mv $porttxtopf $porttxtopf`date +%s`
	fi
	`nc -zv localhost $cohagntPort > /dev/null 2>&1` && echo "Oracle Host Port $cohagntPort: OPEN" | tee -a $porttxtopf || echo "Oracle Host Port $cohagntPort: CLOSED" | tee -a $porttxtopf
	IFS=',' read -ra iparr <<< "$clusterip"
	for ip in "${iparr[@]}"
	do
		echo "- - -"
		for i in "111" "2049" "11111"; do
			`nc -zv $ip $i > /dev/null 2>&1` && echo "Cluster Node $ip Port $i: OPEN" | tee -a $porttxtopf || echo "Cluster Node $ip Port $i: CLOSED" | tee -a $porttxtopf
		done
	done
	echo "Find the output in text format at: $porttxtopf"
}

rmanquery_op() {
export ORACLE_SID=$ORACLESID
rqueryop=`$ORACLE_HOME/bin/rman target / log="$rmantxtopf" << EOF
set echo off
$1
exit
EOF`
}

rmanquery() {
	rmantxtopf=$RMANOPFILE".output"
	if [ -f $rmantxtopf ]; then
		mv $rmantxtopf $rmantxtopf`date +%s`
	fi
	rman_cmd="show all;"
	rmanquery_op "$rman_cmd"
	echo "Find the output in text format at: $rmantxtopf"
}

runquery_op() {
query="select distinct substr(name, 1, instr(name,'/',-1)-1 ) name from v\$datafile;"
export ORACLE_SID=$ORACLESID

queryop=`$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set echo off
set newpage none
SET FEEDBACK OFF
SET HEAD OFF
SET PAGES 0
$1
exit
EOF`
}

chkrac() {
	lmsproc=`ps -eo args | awk '{print $1}' | grep "_lms"`
	lckproc=`ps -eo args | awk '{print $1}' | grep "_lck"`
	if [[ (-z $lmsproc && -z $lckproc) ]]; then
		isRAC="No"
	else
		isRAC="Yes"
	fi
	echo "RAC is running: $isRAC" | tee -a $hosttxtopf
}

dblayout () {
	laytxtopf=$DBLAYOUTOPFILE".output"
	if [ -f $laytxtopf ]; then
		mv $laytxtopf $laytxtopf`date +%s`
	fi
	for t in datafile archived_log controlfile;
	do
		query="select distinct substr(name, 1, instr(name,'/',-1)-1 ) name from v\$$t;"
		runquery_op "$query"
		for i in $queryop;
			do 
				echo "The $t path is: $i" >> $laytxtopf
				if [[ $isASM = "No" ]]; then
					echo "The mount point is: "`/bin/df -h --output=target $i | tail -n1` >> $laytxtopf
					echo "Source of mount point is: "`/bin/df -h --output=source $i | tail -n1` >> $laytxtopf
					echo "The filesystem of mount point is: "`/bin/df -h --output=fstype $i | tail -n1` >> $laytxtopf
					mntpt=`/bin/df -h --output=target $i | tail -n1`
					cat /etc/mtab  | grep $mntpt" " | awk '{print "The mount options are: " $4}' >> $laytxtopf
				fi
			done
	done

	query="select distinct substr(member, 1, instr(member,'/',-1)-1 ) name from v\$logfile;"
	runquery_op "$query"
	for i in $queryop;
		do 
			echo "The redolog file path is: $i" >> $laytxtopf
			if [[ $isASM = "No" ]]; then
				echo "The mount point is: "`/bin/df -h --output=target $i | tail -n1` >> $laytxtopf
				echo "Source of mount point is: "`/bin/df -h --output=source $i | tail -n1` >> $laytxtopf
				echo "The filesystem of mount point is: "`/bin/df -h --output=fstype $i | tail -n1` >> $laytxtopf
				mntpt=`/bin/df -h --output=target $i | tail -n1`
				cat /etc/mtab  | grep $mntpt" " | awk '{print "The mount options are: " $4}' >> $laytxtopf
			fi
		done
	echo "Find the output in text format at: $laytxtopf"
}

chkasm() {
	asmproc=`ps -eo args | awk '{print $1}' | grep -i "asm_pmon_+ASM"`
	if [[ -z $asmproc ]]; then
		isASM="No"
	else
		isASM="Yes"
	fi
	echo "ASM is running: $isASM" | tee -a $hosttxtopf
}

dbparams() {
	txtopf=$OUTPUTFILE".output"
	if [ -f $txtopf ]; then
		mv $txtopf $txtopf`date +%s`
	fi
	export ORACLE_SID=$ORACLESID;sqlplus -s "/ as sysdba" @t.sql | tee $txtopf
	echo "Find the output in text format at: $txtopf"
}

OSParams() {
	hosttxtopf=$DBHOSTPARAMSFILE".output"
	if [[ -f $hosttxtopf ]]; then
		mv $hosttxtopf $hosttxtopf`date +%s`
	fi
	sh ./cmds.input | tee $hosttxtopf
	chkasm 
	chkrac

	if [[ $isASM = "Yes" ]]; then
		GRD_HOME=`cat /etc/oratab | grep "+ASM" | cut -d ':' -f2`
		echo "GRID HOME is : $GRD_HOME" | tee -a $hosttxtopf
	fi
	ORA_HOME=`cat /etc/oratab | grep -w $ORACLESID | cut -d ':' -f2`
	echo "ORACLE HOME is : $ORA_HOME" | tee -a $hosttxtopf

	if [[ $isRAC = "Yes" ]]; then
		NoOfRACNodes=`$GRD_HOME/bin/olsnodes | wc -l`
		echo "Number of nodes in RAC : $NoOfRACNodes" | tee -a $hosttxtopf
		ClusterName=`$GRD_HOME/bin/olsnodes -c`
		echo "Cluster Name is : $ClusterName" | tee -a $hosttxtopf
		echo `$GRD_HOME/bin/srvctl config scan | grep "SCAN name" | cut -d',' -f1` | tee -a $hosttxtopf
	fi
	echo "Find the output in text format at: $hosttxtopf"
}

usage() {
	echo "Usage of script is as below"
	echo "./prechckr.sh"
}

main() {
	echo -e "\n* * * * * * * * * * * * * * * * * * * * *"
	echo "* * * * *  O S   P a r a m s  * * * * * *"
	echo -e "* * * * * * * * * * * * * * * * * * * * *\n"
	OSParams
	echo -e "\n* * * * * * * * * * * * * * * * * * * * *"
	echo "* * * * *  D B   P a r a m s  * * * * * *"
	echo -e "* * * * * * * * * * * * * * * * * * * * *\n"
	dbparams
	echo -e "\n* * * * * * * * * * * * * * * * * * * * *"
	echo "* * * * *  D B   L a y o u t  * * * * * *"
	echo -e "* * * * * * * * * * * * * * * * * * * * *\n"
	dblayout
	echo -e "\n* * * * * * * * * * * * * * * * * * * * *"
	echo "* * * * *  R M A N   C o n f i g  * * * *"
	echo -e "* * * * * * * * * * * * * * * * * * * * *\n"
	rmanquery
	echo -e "\n* * * * * * * * * * * * * * * * * * * * *"
	echo "* * * * *  P O R T   Q u e r y  * * * * *"
	echo -e "* * * * * * * * * * * * * * * * * * * * *\n"
	prtchk

	if [ ! -z $fileformat ]; then
		case $fileformat in
		   "csv")
			hstcsvopf=$DBHOSTPARAMSFILE".csv"
			`sed 's/:/,/g' $hosttxtopf > $hstcsvopf`
			echo -e "\nFind the output in .csv format at: $hstcsvopf"
			csvopf=$OUTPUTFILE".csv"
			`sed 's/:/,/g' $txtopf > $csvopf`
			echo "Find the output in .csv format at: $csvopf"
			dblytcsvopf=$DBLAYOUTOPFILE".csv"
			`sed 's/:/,/g' $laytxtopf > $dblytcsvopf`
			echo "Find the output in .csv format at: $dblytcsvopf"
			portcsvopf=$PORTOPFILE".csv"
			`sed 's/:/,/g' $porttxtopf > $portcsvopf`
			echo "Find the output in .csv format at: $portcsvopf"
			;;
		   "json")
			jsonopf=$OUTPUTFILE".json"
			echo "JSON format yet to implement"
			;;
		   *)
			echo "Unsupported format"
			;;
		esac
	fi
}


echo "Welcome to Cohesity Pre-Checker Tool!"
if [ $# -lt 1 ]; then
	echo "Provided args are incorrect, refer Usage below..."
	echo "Usage:
	./prechckr.sh <oracle sid> [\"<List of Cluster Node IPs>\"] [csv | json]
	"
	echo "Example:
	./prechckr.sh orcl \"10.1.2.1,10.1.2.2,10.1.2.3\"
	"
	exit
fi

clusterip=$2
fileformat=$3
myproc=ora_pmon_$1
dbproc=`ps -eo args | awk '{print $1}' | grep -w $myproc`
if [[ -z $dbproc || ($myproc != $dbproc) ]]; then
        echo "Specified DB is not running, provide a valid DB in running state..."
        exit
fi
echo "Found $1 in running state..."

main
