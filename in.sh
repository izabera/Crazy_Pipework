#!/bin/bash
exec {savedstdout}>&1
INAME=nc



proc_cmd2()
{
	if [[ $1 =~ ^client=.* ]]
	then
		client=${1#"client="}
		echo "mod:ready:in"
		sed -un '/^user:key=/p;
			/^client=/p;
			/^user:resize:/p;
			/^user:client-time=/p;
			/^file:send:/p; 
			/^file:accept:/p
			'
		# grep '^game:key=.*' # doesnt really filter 
	elif [[ $1 =~ ^get-client.* ]]
	then
		echo out:cat-client
		exit 0
	fi
}

in_init()
{
		if [ $STANDALONE_SERVER ]
		then
			while read command
			do 
				proc_cmd2 "$command"
			done <&$stdin 
			# for manual server start - wait for client
		else
			while read -t .1 command
			do
				proc_cmd2 "$command"
			done <&$stdin
			# for *inetd
		fi
		echo in:init; 

		NULL_CLIENT=1 exec bash ./client.sh
}

proc_cmd()
{
	if [[ $1 =~ ^in:init ]]
	then
		echo "mod:get_stdin:in"
		wait_for in:stdin= stdin
		in_init
	fi
}

#echo "mod:use:blah blah"
while read command; do proc_cmd $command; done


exit
