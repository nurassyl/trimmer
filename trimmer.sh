#!/bin/bash

RED='[0;31m'
NC='[0m'


if [ "$BASH_SOURCE" != "/bin/trimmer" ]; then
	echo -e "${RED}ERROR:${NC} Please, install this utility!"
	exit 1
fi


file_is_exists() {
	if [ -f $1 ]; then
		return 1
	else
		return 0
	fi
}


trim_trailing_whitespace() {
	trimmed="$1"

	# Strip trailing whitespace.
	trimmed=$(sed -e 's/[[:space:]]*$//' <<< ${trimmed})
}


is_empty_file() {
	local lines=$1

	if [[ ${#lines[@]} == 1 && "${lines[0]}" == "" ]]; then
		return 1
	else
		return 0
	fi
}





command="find $(pwd) -type f"


# Ignore paths specified in file ".trimmerignore".
file_is_exists .trimmerignore
if [ $? -eq 1 ]; then
	while IFS= read -r line; do
		command="$command -not -path \"$(pwd)/$line\""
	done < ./.trimmerignore
fi


# Get paths.
files=()
for file in $(eval $command); do
	files+=($file)
done


for file in ${files[@]}; do
	# Get all lines of file.
	lines=()
	IFS=''
	while read -r line; do
		lines+=("$line")
	done < $file


	# Trim trailing whitespace of line.
	for (( i=0; i<${#lines[@]}; i++ )); do
		trim_trailing_whitespace "${lines[$i]}"
		lines[i]=$trimmed
	done


	# Remove leading empty line of file.
	while true; do
		is_empty_file ${lines[@]}
		if [ $? == 1 ]; then
			break
		fi

		if [ "${lines[0]}" == "" ]; then
			lines=("${lines[@]:1}")
		else
			break
		fi
	done


	# Remove trailing empty line of file.
	while true; do
		is_empty_file ${lines[@]}
		if [ $? == 1 ]; then
			break
		fi

		if [ "${lines[-1]}" == "" ]; then
			unset lines[-1]
		else
			break
		fi
	done


	# Remove file content.
	> $file


	# Write new content to file.
	for ((i=0; i<${#lines[@]}; i++)); do
		echo -e "${lines[$i]}" >> $file
	done
done
