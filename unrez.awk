#!/usr/bin/awk -f
# 
# unrez.awk
#
# Transform hex data from a Rez file into a set of files in the rsrsc directory,
# one for each resource, which is suitable for building using this Makefile and
# MakeAPPL.
#
# Usage:
#	./unrez.awk Thing.r
# where Thing.r was obtained from DeRez (MPW may be required):
#	DeRez Thing.rsrc -o Thing.r
# where Thing.rsrc is some file with a resource fork.

BEGIN {
	system("mkdir rsrc")
}

/^data/ {
	type = substr($2, 2, 4)
	if (match($3, "[0-9]+")) {
		id = substr($3, RSTART, RLENGTH)
	} else {
		print("Unable to find resource ID")
		id = 0
	}
	file = "rsrc/" type "/" id ".hex"
	system("mkdir -p rsrc/" type)
}

/^\s*\$/ {
	if (match($0, "\"[0-9A-F ]*\"")) {
		print substr($0, RSTART+1, RLENGTH-2) > file
	}
}
