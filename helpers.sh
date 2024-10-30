#!/bin/bash

alias k="kubectl"
alias kn="kubectl -n beta"
alias kp="kubectl get pods -A"
alias knp="kubectl get pods -n beta"

alias ks="kubectl get svc -A"
alias kns="kubectl get svc -n beta"

alias kl="kubectl logs"
alias kd="kubectl describe"
alias kln="kubectl -n beta logs"
alias kdn="kubectl -n beta describe"

alias ks="kubectl -n kube-system"
alias ksd="kubectl -n kube-system describe"
alias ksl="kubectl -n kube-system logs"

POD_ID=""

find_pod_id() {
  local namespace=${1:-default}
  local query=$2
  kubectl -n $namespace get pods | grep $query | cut -d ' ' -f1
}

process_pod() {
  local command=$1
  local namespace=${2:-default}
  local  pod_id=$3
  kubectl -n $namespace $command pods/$pod_id
}

grep_pod_id() {
  local namespace=${1:-default}
  local query=$2

  local pod_id=$(find_pod_id $namespace $query)
  local num_of_ids=$(echo $pod_id | wc -w)
    
  if (( $num_of_ids > 1 )); then
    echo Multiple pods found 
    echo Enter p od index to select
    
    while : ; do
      local idx=0
      while read line; do
	idx=$((idx+1))
	echo "$idx) $line"
      done <<< "$pod_id"

      read idx

      if (( idx >= 1 && idx <= $num_of_ids )); then
        pod_id=$(echo "$pod_id" | sed -n "${idx}p")	      
	break	
      fi

      echo "You entered invalid choise, please try again"
    done
  fi
  POD_ID=$pod_id
}

process_pod_grep() {
  local command=$1
  local namespace=${2:-default}
  local query=$3

  grep_pod_id $namespace $query

  if [ -n $POD_ID ]; then
    process_pod $command $namespace $POD_ID
  fi
}

get_pod_info_grep() {
  local namespace=${1:-default}
  local query=$2

  grep_pod_id $namespace $query

  if [ -n $POD_ID ]; then
    kubectl -n $namespace get pods/$POD_ID -o yaml
  fi
}

exec_pod_grep() {
  local namespace=${1:-default}
  local query=$2
  local command=${3:-/bin/sh}

  grep_pod_id $namespace $query

  if [ -n $POD_ID ]; then
    kubectl -n $namespace exec -it $POD_ID  -- $command
  fi
}


alias kspi="find_pod_id kube-system"

alias ksdpi="process_pod describe kube-system"
alias kslpi="process_pod logs kube-system"

alias kse="exec_pod_grep kube-system"
alias ksp="kubectl -n kube-system get pods"

alias kip="get_pod_info_grep default"

alias ksip="get_pod_info_grep kube-system"
alias ksdp="process_pod_grep describe kube-system"
alias kslp="process_pod_grep logs kube-system"

