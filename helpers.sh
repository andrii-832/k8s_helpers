#!/bin/bash

POD_ID=""

find_pod_id() {
  local namespace=$1
  local query=$2
  kubectl -n $namespace get pods | grep $query | cut -d ' ' -f1
}

process_pod() {
  local command=$1
  local namespace=$2
  local pod_id=$3
  kubectl -n $namespace $command pods/$pod_id
}

grep_pod_id() {
  local namespace=${1:-default}
  local query=$2

  local pod_id=$(find_pod_id $namespace $query)
  local num_of_ids=$(echo $pod_id | wc -w)

  if (($num_of_ids > 1)); then
    echo Multiple pods found
    echo Enter p od index to select

    while :; do
      local idx=0
      while read line; do
        idx=$((idx + 1))
        echo "$idx) $line"
      done <<<"$pod_id"

      read idx

      if ((idx >= 1 && idx <= $num_of_ids)); then
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

get_pod_info() {
  local namespace=${1:-default}
  local POD_ID=$2
  kubectl -n $namespace get pods/$POD_ID -o yaml
}

get_pod_info_grep() {
  local namespace=${1:-default}
  local query=$2

  grep_pod_id $namespace $query

  if [ -n $POD_ID ]; then
    get_pod_info $namespace $POD_ID
  fi
}

exec_pod() {
  local namespace=${1:-default}
  local POD_ID=$2
  local command=${3:-/bin/sh}
  kubectl -n $namespace exec -it $POD_ID -- $command
}

exec_pod_grep() {
  local namespace=${1:-default}
  local query=$2
  local command=${3:-/bin/sh}

  grep_pod_id $namespace $query

  if [ -n $POD_ID ]; then
    # kubectl -n $namespace exec -it $POD_ID -- $command
    exec_pod $namespace $POD_ID $command
  fi
}

alias k="kubectl"
alias kn="kubectl -n $K8S_NAMESPASE"
alias ks="kubectl -n kube-system"

alias kpa="k get pods -A"
alias knp="kn get pods"
alias ksp="ks get pods"

alias ksa="k get svc -A"
alias kns="kn get svc"
alias kss="ks get svc"

# get pod id
alias kspg="find_pod_id kube-system"
alias knpg="find_pod_id $K8S_NAMESPASE"

# describe pod
alias kndp="process_pod describe $K8S_NAMESPASE"
alias ksdp="process_pod describe kube-system"
alias ksdpg="process_pod_grep describe kube-system"
alias kndpg="process_pod_grep describe $K8S_NAMESPASE"

# logs pod
alias knlp="process_pod logs $K8S_NAMESPASE"
alias kslp="process_pod logs kube-system"
alias kslpg="process_pod_grep logs kube-system"
alias knlpg="process_pod_grep logs $K8S_NAMESPASE"

# info pod grep
alias ksip="get_pod_info kube-system"
alias knip="get_pod_info $K8S_NAMESPASE"
alias ksipg="get_pod_info_grep kube-system"
alias knipg="get_pod_info_grep $K8S_NAMESPASE"

# exec pod grep
alias ksep="exec_pod kube-system"
alias knep="exec_pod $K8S_NAMESPASE"
alias ksepg="exec_pod_grep kube-system"
alias knepg="exec_pod_grep $K8S_NAMESPASE"
