#!/bin/bash
upDateTime=`date +'%Y-%m-%d %H:%M:%S'`
#while [ $# != 0 ];do
#	${fileList}="${fileLList} $1"
#	shift
#done
fileList="$1 $2 $3 $4 $5 $6 $7 $8"
git add ${fileList}                      >> /dev/null
git commit -m "${upDateTime}-${fileList}" >> /dev/null
git push -u origin master		 >> /dev/null

echo "+------------------------------------------------------------+"
echo "|                                                            |"
echo "|              add and push file :${fileList}                 "
echo "|              update time is: ${upDateTime}                  "
echo "|                                                            |"	
echo "+------------------------------------------------------------+"
