# get info using moab commands
# you can adapt this library to your resource manager, just keep the function names and semantics

readonly MOAB_PATH_UNDEFINE=16
readonly COMMAND_NOT_AVAILABLE=32
readonly TOTAL_QUEUE_PROCESSORS=5
readonly USED_QUEUE_PROCESSORS=3

check_moab_command(){
    if [ -z ${MOAB_PATH} ]; then
	echo MOAB path undefined 1>&2
	return ${MOAB_PATH_UNDEFINED}
    fi
    readonly command=$1
    if [ ! -x ${MOAB_PATH}/${command} ]; then
	echo Command ${command} not available 1>&2
	return ${COMMAND_NOT_AVAILABLE}
    fi
    return ${OK}
}


get_queue_time(){
    local err=${OK}
    check_moab_command "checkjob"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi
    err=${OK}
    readonly job_id=$1
    result=($( ${MOAB_PATH}/checkjob ${job_id} | grep Queued))
    err=$?
    queue_time=${result[3]}
    echo "${queue_time}"
    return ${err}
}

get_jobs_in_queue(){
    local err=${OK}
    check_moab_command "showq"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/showq -i | egrep -v 'jobs|Total|JOBID|eligible' | sed "/^$/d" ))
    echo ${fields[0]}
    return ${OK}
}

get_blocked_jobs(){
    local err=${OK}
    check_moab_command "showq"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/showq -b | grep "blocked job" | tail -1 ))
    echo ${fields[0]}
    return ${OK}
}

get_active_jobs(){
    local err=${OK}
    check_moab_command "showq"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/showq -r | grep "local jobs" ))
    echo ${fields[0]}
    return ${OK}
}


# $1 = which info field (used / total). See QUEUE_PROCESSORS constants.
get_queue_processors(){
    local err=${OK}
    local -r field=$1
    check_moab_command "showq"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/showq | grep processor | sed "s/  */ /g" ))
    echo ${fields[${field}]}

    return ${OK}
}

get_total_processors(){
    get_queue_processors ${TOTAL_QUEUE_PROCESSORS}
}

get_used_processors(){
    get_queue_processors ${USED_QUEUE_PROCESSORS}
}

get_idle_processors(){
    local -r used=$( get_used_processors )
    local -r total=$( get_total_processors )
    local -r idle=$(( total - used ))
    echo ${idle}
    return ${OK}
}

get_idle_nodes(){
    local err=${OK}
    local -r field=$1
    check_moab_command "mdiag"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/mdiag -n | grep "Total Nodes" ))
    echo ${fields[6]}

    return ${OK}
}

get_down_nodes(){
    local err=${OK}
    local -r field=$1
    check_moab_command "mdiag"
    err=$?
    if [ ${err} -ne ${OK} ]; then
	return ${err}
    fi

    local -r fields=($( ${MOAB_PATH}/mdiag -n | grep "Total Nodes" | tr \) " " ))
    echo ${fields[8]}

    return ${OK}
}

# if you don't have green computing features, 
# simply don't define the GREEN_MDIAG variable.
# if you do, provide a script with the expected output,
# or adapt this function to your script
get_green_nodes(){
    local err=${OK}
    local -r field=$1

    if [ -z ${GREEN_MDIAG} ]; then
	# green features not available...
	echo 0
	return ${OK}
    fi

    if [ ! -x ${GREEN_MDIAG} ]; then
	echo Green diag command not available 1>&2
	return ${COMMAND_NOT_AVAILABLE}
    fi

    local -r fields=($( ${GREEN_MDIAG} | grep "Total Nodes" ))
    echo ${fields[6]}

    return ${OK}
}

