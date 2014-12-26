#1/bin/bash

# Clean up debug environment I've got that results in spam into the logs.
unset LIBGL_DEBUG
export vblank_mode=0

i=0
first=0
priming=1

rm -f before after

while true; do
	if test $priming = 1; then
		echo -n "Priming data: "
	fi

	# The printout of ministat at the end of the loop may get
	# pipelined and thus take CPU during our next test run, often
	# during the first run of the two.  To avoid systematic bias,
	# flip around which testcase runs first each time.
	if test $first -lt 1; then
		$2 $1 >> before 2> /dev/null
		$3 $1 >> after  2> /dev/null
	else
		$3 $1 >> after  2> /dev/null
		$2 $1 >> before 2> /dev/null
	fi
	first=$((1-$first))

	if test $priming = 1; then
		echo $(wc -l before), $(wc -l after)
	fi

	# Sometimes it's nice to see the numbers too, so uncomment
	# that.

	# cat before after

	if test $priming = 1; then
		if [[ $(wc -l before | awk '{print $1}') -ge 3 ]] && [[ $(wc -l after | awk '{print $1}') -ge 3 ]] ; then
			priming=0
		fi
	fi

	if test $priming = 0; then
		clear
		ministat -w 60 -n before after
	fi

	i=$(($i + 1))
done
