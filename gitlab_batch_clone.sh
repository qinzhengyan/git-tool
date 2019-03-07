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
    exit 1
fi

if [ $# -ne 2 ]
  then
    echo "we need only two arguments."
    exit 1
fi

if test -n $1; then
  echo "private TOKEN is :$1"
else
  echo "please enter private TOKEN."
  exit 1
fi

if test -n $2; then
  echo "git URL is : $2"
else
  echo "please enter git URL."
  exit 1
fi

if curl --output /dev/null --silent --head --fail "$2"; then
  echo "$2 is up."
else
  echo "$2 is down."
  exit 1
fi


TOKEN=$1
URL="$2/api/v3"
PROJECT_REPO_URL_KEY="http_url_to_repo"

# check and create group dir
BASEPATH=$(cd `dirname $0`; pwd)
GROUP_IDS=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups | jq '.[] | .id')
for group_id in $GROUP_IDS
do
      group_name=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups/$group_id | jq '.name')
      group_name=${group_name//'"'/''}	
      mkdir -p $BASEPATH/$group_name
      cd $BASEPATH/$group_name/
      rm -rf *
      projects=$(curl --header "PRIVATE-TOKEN: $TOKEN" $URL/groups/$group_id/projects | jq --arg p "$PROJECT_REPO_URL_KEY" '.[] | .[$p]')
      for project in $projects
      do
	echo "git repo project url is $project"
	echo "local git repo dir is $BASEPATH/$group_name/"    
	git clone ${project//'"'/''} 
      done 
done
