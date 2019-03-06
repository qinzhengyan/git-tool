#!/bin/bash
if command -v jq >/dev/null 2>&1; then
  echo "jq parser found";
else
  echo "this script requires the 'jq' json parser (https://stedolan.github.io/jq/).";
  exit 1;
fi

if [ $# -eq 0 ]
  then
    echo "No arguments,we need two arguments."
    exit 1;
fi

if [ $# -ne 2 ]
  then
    echo "we need only two arguments."
    exit 1;
fi

if test -n $1; then
  echo "private token is :$1"
else
  echo "please enter private token."
  exit 1;
fi

if test -n $2; then
  echo "git url is : $2"
else
  echo "please enter git url."
  exit 1
fi


TOKEN=$1;
URL="$2/api/v3"
PREFIX="http_url_to_repo"

# check and create group dir
basepath=$(cd `dirname $0`; pwd)
groups_ids=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups | jq '.[] | .id')
for group_id in $groups_ids
do
      group_name=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups/$group_id | jq '.name')
      group_name=${group_name//'"'/''}	
      mkdir -p $basepath/$group_name
      cd $basepath/$group_name/
      rm -rf *
      projects=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups/$group_id/projects | jq --arg p "$PREFIX" '.[] | .[$p]')
      for project in $projects
      do
	echo "git repo project url is $project"
	echo "local git repo dir is $basepath/$group_name/"    
	git clone ${project//'"'/''} 
      done 
done
