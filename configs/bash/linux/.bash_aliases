# Functions

# docker compose [--env-file <env_file> ...] up [--force-recreate] <compose_up_args>
function dcu() {
    local env_files=()
    local force_recreate="--force-recreate"
    local compose_up_args=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            *.env)
                env_files+=("$1")
                shift
                ;;
            --no-force-recreate)
                force_recreate=""
                shift
                ;;
            *)
                compose_up_args+=("$1")
                shift
                ;;
        esac
    done

    local compose_up_args="${compose_up_args[@]}"
    if [[ "$compose_up_args" != *"novnc"* ]]; then
        xhost +
    fi

    local compose_cmd="docker compose"
    for env_file in "${env_files[@]}"; do
        compose_cmd+=" --env-file $env_file"
    done
    compose_cmd+=" up $force_recreate $compose_up_args"
    echo $compose_cmd
    eval $compose_cmd
}

# docker exec -it <container_id> /bin/bash
function dbash() {
    docker exec -it $1 bash
}

# Aliases
alias dcd="docker compose down"
alias dcl="docker container ls -a"
alias dcb="docker compose build --pull"

alias code="code-insiders"
