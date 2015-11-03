#!/bin/bash

readonly NOMADS=1
readonly SETTLED=2
readonly FREEMEN=3

FACTION=0

declare -a FAMILY
FACTION_OPTIONS="\"Nomads\""
BASIC_OPTIONS="Grow"
GROW_OPTIONS=""

MY_CIV=""

lotlChoiceAction(){
    _RET=""
    message=$1
    shift
    while [[ $_RET == "" ]]
    do
        clear
        echo -e $message
        choicenum=0
        for arg in "$@"
        do
            let "choicenum++"
            echo  "$choicenum) $arg"
        done
        
        result=0
        echo "Choose: (1-$choicenum)"
        read result
        if [[ "`seq $choicenum`" =~ "$result" && "$result" != "" ]]
        then
            tmp=($@)
            _RET=${tmp[result-1]}
        fi

    done
}

lotlFactionSelect(){
    lotlChoiceAction "Choose your faction:" $FACTION_OPTIONS
    FACTION=$_RET
}

lotlStartingFamilies(){
    case "$1" in
        "Nomads") _RET="\"Hunters\" \"Gatherers\""
            ;;
        "Settled") _RET="\"Builders\" \"Farmers\" \"Villagers\""
            ;;
        "Freemen") _RET="\"Woodcutters\" \"Fishermen\""
    esac
}



lotlGrowAction(){
    lotlRemoveGrowOption "$1"
    lotlAddCiv "$1"
}

lotlFamilySelect(){
    lotlStartingFamilies $FACTION
    GROW_OPTIONS=$_RET
    lotlChoiceAction "You chose the $FACTION!\nChoose your starting family:" $GROW_OPTIONS
    case "$_RET" in
        1) 
    esac
}


lotlExecuteAction(){
    case "$1" in
        "Grow") lotlGrowAction
    esac
}

lotlNextTurn(){
    lotlChoiceAction "Choose an Action:" $BASIC_OPTIONS
    lotlExecuteAction $_RET
}

lotlStartGame(){
    while [[ -n $ENDGAME ]]
    do
        lotlNextTurn
    done
}


lotlNewGame(){
    lotlFactionSelect
    lotlFamilySelect
    lotlStartGame
}


lotlNewGame
