CURRENT_PATH=$(pwd)
#echo $CURRENT_PATH

PROJECT_ROOT_PATH=$(cd $(dirname $0);pwd)
cd $PROJECT_ROOT_PATH

GIT_PATH_FILE_NAME="$PROJECT_ROOT_PATH/.git_path.txt"
GIT_INIT_STATUS_FILE_NAME="$PROJECT_ROOT_PATH/.git_initstatus.txt"
#echo $GIT_PATH_FILE_NAME
#echo $GIT_INIT_STATUS_FILE_NAME

ARG1=$1
ARG2=$2

if [ -f $GIT_PATH_FILE_NAME ];then
GITLISTS=($(cat $GIT_PATH_FILE_NAME))
fi
if [ -f $GIT_INIT_STATUS_FILE_NAME ];then
GITINITSTATUS=($(cat $GIT_INIT_STATUS_FILE_NAME))
fi

if [ "$ARG1" = "init" ];then

	if [ -f $GIT_PATH_FILE_NAME ];then
		rm -f $GIT_PATH_FILE_NAME
	fi
	if [ -f $GIT_INIT_STATUS_FILE_NAME ];then
		rm -f $GIT_INIT_STATUS_FILE_NAME
	fi
	for dir in `find ./ -type d`
	do
		if [ `basename $dir` = ".git" ];then
			echo "$PROJECT_ROOT_PATH/$dir" >> $GIT_PATH_FILE_NAME
		fi
	done
	
	GITLISTS=($(cat $GIT_PATH_FILE_NAME))
	for i in `seq 0 $((${#GITLISTS[*]}-1))`
	do
		cd ${GITLISTS[i]}
		echo $(git log -1 --pretty=format:"%H") >> $GIT_INIT_STATUS_FILE_NAME
		git branch --set-upstream-to origin/`git branch --show-current`
		cd $PROJECT_ROOT_PATH
	done

elif [ "$ARG1" = "initstatus" ]; then

	for i in `seq 0 $((${#GITLISTS[*]}-1))`
	do
		echo "${GITLISTS[i]} ==> ${GITINITSTATUS[i]}"
	done

elif [ "$ARG1" = "list" ];then
	
	for i in `seq 0 $((${#GITLISTS[*]}-1))`
	do
		echo ${GITLISTS[i]}
	done

elif [ "$ARG1" = "forall" ]; then

	CMD=$ARG2
	for i in `seq 0 $((${#GITLISTS[*]}-1))`
	do
		cd $(dirname ${GITLISTS[i]})
		pwd
		echo "$CMD"|sh
		cd $PROJECT_ROOT_PATH
	done
	
else

	SELECT_GIT_PATH=$ARG1
	CMD=$ARG2
	FIND=0
	for i in `seq 0 $((${#GITLISTS[*]}-1))`
	do
		if [ "${GITLISTS[i]}" = "${SELECT_GIT_PATH}" ];then
			cd $(dirname ${GITLISTS[i]})
			pwd
			echo "$CMD"|sh
			cd $PROJECT_ROOT_PATH
			FIND=1
		fi
	done

	if [ $FIND = 0 ];then
		echo "unknown slect git: $SELECT_GIT_PATH"
	fi

fi

