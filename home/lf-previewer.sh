#!/bin/sh

case "$1" in
#    *.tar*) tar tf "$1";;
#    *.zip) unzip -l "$1";;
#    *.rar) unrar l "$1";;
#    *.7z) 7z l "$1";;
    # *.pdf) pdftotext "$1" -;;
    # *) bat -fP --style="plain" --theme zenburn "$1";;
    *) bat --paging=never --style=plain --color=always "$1";;
#    *) highlight -O ansi "$1" || cat "$1";;
esac

