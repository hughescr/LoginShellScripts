#!/bin/env bash
_subl_completions()
{
    COMPREPLY=($(compgen -f "${COMP_WORDS[-1]}"| grep -v -E '.sublime-workspace$'))
}

complete -F _subl_completions subl
