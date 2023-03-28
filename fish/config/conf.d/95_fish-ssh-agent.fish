if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

set -xg SSH_AUTH_SOCK ~/.ssh/ssh-agent.local.sock

if status --is-login
and not __ssh_agent_is_started
    echo "STARTING NEW AGENT"
    __ssh_agent_start
end
