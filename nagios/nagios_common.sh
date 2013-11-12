#!/bin/bash

readonly OK=0
readonly STATUS_WARNING=1
readonly STATUS_CRITICAL=2

print_usage() {
	local prog_name=$( basename $0 )
        echo "Usage: ${prog_name} [options]"
        echo
        echo "Options:"
        echo -e "\t -w [value]           set warning value"
        echo -e "\t -c [value]           set critical value"
        echo
        echo "If no options are given, ${prog_name} will print only status."
        echo
}

parse_cmd_arguments(){
  if [ "$#" -gt 0 ]; then
    while getopts ":c:w:" options; do
      case "${options}" in
        c)
          readonly CRITICAL=${OPTARG}
        ;;
        w)
          readonly WARNING=${OPTARG}
        ;;
        *)
          echo "Unknow option" > 2
          print_usage
        ;;
       esac
     done
     shift $((OPTIND-1))
  fi
}

check_value(){
	local -r value="$1"
	local -r warning="$2"
	local -r critical="$3"

	[ "${critical}" ] && \
	    if [ ${value} -ge ${critical} ]; then
	      echo -n "[CRITICAL]  "
	      return ${STATUS_CRITICAL}
	    fi

	[ "${warning}" ] && \
	    if [ ${value} -ge ${warning} ]; then
	      echo -n "[WARNING]  "
	      return ${STATUS_WARNING}
	    fi

	return ${OK}
}

time_to_hours(){
    # time might include days or not:
    # 1:10:44:35, 23:33:01
    # !!!! do further checks to time parameter
    local -r time=$1
    IFS=":" read -ra time_fields <<< "${time}"
    if [ ${#time_fields[@]} -eq 4 ]; then
        hours=${time_fields[1]}
    else
	hours=${time_fields[0]}
    fi
    echo ${hours}
    return ${OK}
}

