eval $(ssh-agent)

function cleanup {
    echo "Killing SSH-Agent"
	eval $(ssh-agent -k)
}

trap cleanup EXIT
