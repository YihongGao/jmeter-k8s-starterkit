#!/usr/bin/env bash

#=== FUNCTION ================================================================
#        NAME: logit
# DESCRIPTION: Log into file and screen.
# PARAMETER - 1 : Level (ERROR, INFO)
#           - 2 : Message
#
#===============================================================================
logit()
{
    case "$1" in
        "INFO")
            echo -e " [\e[94m $1 \e[0m] [ $(date '+%d-%m-%y %H:%M:%S') ] $2 \e[0m" ;;
        "WARN")
            echo -e " [\e[93m $1 \e[0m] [ $(date '+%d-%m-%y %H:%M:%S') ]  \e[93m $2 \e[0m " && sleep 2 ;;
        "ERROR")
            echo -e " [\e[91m $1 \e[0m] [ $(date '+%d-%m-%y %H:%M:%S') ]  $2 \e[0m " ;;
    esac
}

#=== FUNCTION ================================================================
#        NAME: usage
# DESCRIPTION: Helper of the function
# PARAMETER - None
#
#===============================================================================
usage()
{
  logit "INFO" "-j <filename.jmx>"
  logit "INFO" "-n <namespace>"
  logit "INFO" "-c flag to split and copy csv if you use csv in your test"
  logit "INFO" "-m flag to copy fragmented jmx present in scenario/project/module if you use include controller and external test fragment"
  logit "INFO" "-i <injectorNumber> to scale slaves pods to the desired number of JMeter injectors"
  logit "INFO" "-r flag to enable report generation at the end of the test"
  exit 1
}

job_name=$1; shift

### Parsing the arguments ###
while getopts 'hn:' option;
    do
      case $option in
        n	)	namespace=${OPTARG}   ;;
        h   )   usage ;;
        ?   )   usage ;;
      esac
done

if [ "$#" -eq 0 ]
  then
    usage
fi

### CHECKING VARS ###
if [ -z "${job_name}" ] || [[ "${job_name}" == -* ]] ; then
    logit "ERROR" "Job name not provided!"
    usage
fi

if [ -z "${namespace}" ]; then
    logit "ERROR" "Namespace not provided!"
    usage
    namespace=$(awk '{print $NF}' "${PWD}/namespace_export")
fi

master_pod=$(kubectl get pod -n "${namespace}" | grep jmeter-master | awk '{print $1}')

kubectl -n "${namespace}" exec -c jmmaster -ti "${master_pod}" -- bash /opt/jmeter/apache-jmeter/bin/stoptest.sh
