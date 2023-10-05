#!/bin/bash
# Christopher Sargent 09202023
set -x #echo on

# Add date time stamp to root and jboss prompts/history's
echo "export PROMPT_COMMAND='echo -n \[\$(date +%F-%T)\]\ '" >> /root/.bashrc && echo "export HISTTIMEFORMAT='%F-%T '" >> /root/.bashrc && source /root/.bashrc

# Add ll alias 
echo "alias ll='ls -alF'" >> /root/.bashrc && source /root/.bashrc
