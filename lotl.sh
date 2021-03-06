#!/bin/bash

readonly NOMADS=1
readonly SETTLED=2
readonly FREEMEN=3

FACTION=0

declare -a FAMILY
FACTION_OPTIONS="Nomads"
BASIC_OPTIONS="Grow"
GROW_OPTIONS=""

MY_CIV=""

declare -a OPTION_REQS

##NOMAD GROWTH
OPTION_REQS+=("Hunters Grow none Nomads")
OPTION_REQS+=("Gatherers Grow none Nomads")

OPTION_REQS+=("Warriors Grow none Hunters")

OPTION_REQS+=("Barbarians Grow none Warriors")
OPTION_REQS+=("Brutes Grow none Warriors")

OPTION_REQS+=("Veterans Grow none Barbarians")
OPTION_REQS+=("Berserkers Grow none Barbarians")

OPTION_REQS+=("Titans Grow none Brutes")

OPTION_REQS+=("Rangers Grow none Gatherers")

OPTION_REQS+=("Chieftain Grow none Gatherers Hunters")

##NOMAD EXPLORE
OPTION_REQS+=("Explore Explore lotlExplore Hunters")
OPTION_REQS+=("Explore Explore lotlExplore Rangers")

##NOMAD ATTACK
OPTION_REQS+=("Attack Attack lotlAttack Warriors")
OPTION_REQS+=("Attack Attack lotlAttack Rangers")


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

lotlCheckArray(){
    _RET=0
    echo $@
    echo ${*[-1]}
    echo ${@[1]}
    for value in ${@%${@[-1]}}
    do
        echo $value == $2
        if [[ "$value" == "$2" ]]
        then
            _RET=1
        fi
    done
    exit
}

lotlFactionSelect(){
    lotlChoiceAction "Choose your faction:" $FACTION_OPTIONS
    #FACTION=$_RET
    MY_CIV+=$_RET
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

lotlRemoveGrowOption(){
    lotlCheckArray $GROW_OPTIONS $1
    if [[ $_RET -eq 1 ]]
    then
        GROW_OPTIONS=${GROW_OPTIONS#$1}
    fi
}

lotlAddCiv(){
    MY_CIV+=" $1"
}

lotlEvaluateGrow(){
    #if $1 is in $MY_CIV do nothing
    if ! [[ $MY_CIV =~ "$1" ]]
    then
        grow=$1
        shift
        shift
        shift
        put="true"
        for i in $@
        do
            if ! [[ $MY_CIV =~ "$i" ]]
            then
                put="false"
            fi
        done
        if [[ $put == "true" ]]
        then
            GROW_OPTIONS+=" $grow"
        fi
    fi
    #else if $3 is not none store the action
    #and if all REQS $4,$5,$6,$7... are in $MY_CIV then add to GROW_OPTIONS
}

lotlEvaluateExplore(){
    #if $1 is in $MY_CIV do nothing
    if ! [[ $MY_CIV =~ "$1" ]]
    then
        action=$1
        shift
        shift
        shift
        put="true"
        for i in $@
        do
            if ! [[ $MY_CIV =~ "$i" ]]
            then
                put="false"
            fi
        done
        if [[ $put == "true" ]]
        then
            BASIC_OPTIONS+=" $action"
            MY_CIV+=" $action"
        fi
    fi
    #else if $3 is not none store the action
    #and if all REQS $4,$5,$6,$7... are in $MY_CIV then add to GROW_OPTIONS
}

lotlEvaluateAttack(){
    #if $1 is in $MY_CIV do nothing
    if ! [[ $MY_CIV =~ "$1" ]]
    then
        action=$1
        shift
        shift
        shift
        put="true"
        for i in $@
        do
            if ! [[ $MY_CIV =~ "$i" ]]
            then
                put="false"
            fi
        done
        if [[ $put == "true" ]]
        then
            BASIC_OPTIONS+=" $action"
            MY_CIV+=" $action"
        fi
    fi
    #else if $3 is not none store the action
    #and if all REQS $4,$5,$6,$7... are in $MY_CIV then add to GROW_OPTIONS
}


lotlEvaluateReq(){
    case "$2" in 
        "Grow") lotlEvaluateGrow $@
            ;;
        "Explore") lotlEvaluateExplore $@
            ;;
        "Attack") lotlEvaluateAttack $@
            ;;
        *) lotlEvaluateSpecial $@
    esac
}

lotlEvaluateCiv(){
    GROW_OPTIONS=""
    for req in `seq 0 ${#OPTION_REQS[*]}`
    do
       lotlEvaluateReq ${OPTION_REQS[req]}
      
    done
}



lotlGrowAction(){
    #lotlRemoveGrowOption "$1"
    lotlAddCiv "$1"
}

lotlFamilySelect(){
    lotlStartingFamilies $FACTION
    GROW_OPTIONS=$_RET
    lotlChoiceAction "You chose the $FACTION!\nChoose your starting family:" $GROW_OPTIONS
    lotlGrowAction $_RET
}


lotlExecuteAction(){
    case "$1" in
        "Grow") lotlChoiceAction "Choose how to grow:" $GROW_OPTIONS
            lotlGrowAction $_RET
            ;;
        "Build") lotlChoiceAction "Choose what to build:" $BUILD_OPTIONS
            lotlBuildAction
            ;;
        "Explore") lotlExploreAction
            ;;
        "Claim") lotlClaimAction
            ;;
        "Attack") lotlAttackAction
            ;;
    esac
}

lotlNextTurn(){
    lotlEvaluateCiv
    lotlChoiceAction "Choose an Action:" $BASIC_OPTIONS
    lotlExecuteAction $_RET
}

lotlStartGame(){
    while [[ -z $ENDGAME ]]
    do
        lotlNextTurn
    done
}


lotlNewGame(){
    lotlFactionSelect
    #lotlFamilySelect
    lotlStartGame
}


lotlNewGame
