calc() {
    awk "BEGIN { print $*; }"
}

zfs_reduced() {
    DOCKER_PATH="storage/system/"
    output=`\zfs $@`
    echo -n $output | grep -v "$DOCKER_PATH.*legacy"

    used=`\echo $output | grep "$DOCKER_PATH.*legacy" | awk -F ' ' '{print $2}'`
    total_kb=`echo $used | grep K | sed 's/.$//' | awk '{sum += $1} END {print sum}'`
    total_mb=`echo $used | grep M | sed 's/.$//' | awk '{sum += $1} END {print sum}'`
    total_gb=`echo $used | grep G | sed 's/.$//' | awk '{sum += $1} END {print sum}'`
    total_tb=`echo $used | grep T | sed 's/.$//' | awk '{sum += $1} END {print sum}'`

    total=`calc "${total_kb:=0} / 1000. + ${total_mb:=0} + ${total_gb:=0} * 1000 +  ${total_tb:=0} * 1000 * 1000"`
    count=`echo -n $used | wc -l`
    if (( $count > 0 )); then
        echo "$count entries are omitted occupying a total of ${total%.*} MB."
    fi
}

compdef zfs_reduced=zfs
alias zfs=zfs_reduced