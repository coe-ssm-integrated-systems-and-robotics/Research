#!/bin/bash

function print_job {
    printf "\n\e[44;37;1m===================================================================\e[0m\n"
    printf "\e[44;1;37m %-66s\e[0m\n" "${1}"
    printf "\e[44;37;1m===================================================================\e[0m\n\n"
}

function print_done {
    printf "\n\e[30;42;1m===================================================================\e[0m\n"
    printf "\e[30;42;1m==                         Done!                                 ==\e[0m\n"
    printf "\e[30;42;1m===================================================================\e[0m\n\n"
}

function print_finished_install{
printf "\n\e[30;42;1m=============================================================\e[0m\n"
printf "\e[30;42;1m===                 Installation is DONE!                 ===\e[0m\n"
printf "\e[30;42;1m=============================================================\e[0m\n"
}