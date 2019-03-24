#!/bin/bash

function print_job {
    echo $1
    printf "\n\e[44;1;37m${1}\e[0m\n"
}

function print_done {
    printf "\n\e[30;42;1m;Done!\e[0m\n"
}