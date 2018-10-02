#!/usr/bin/env mksh
# -*- mode: sh -*-
#-
# Copyright © 2018
#	mirabilos <t.glaser@tarent.de>
#
# Provided that these terms and disclaimer and all copyright notices
# are retained or reproduced in an accompanying document, permission
# is granted to deal in this work without restriction, including un‐
# limited rights to use, publicly perform, distribute, sell, modify,
# merge, give away, or sublicence.
#
# This work is provided “AS IS” and WITHOUT WARRANTY of any kind, to
# the utmost extent permitted by applicable law, neither express nor
# implied; without malicious intent or gross negligence. In no event
# may a licensor, author or contributor be held liable for indirect,
# direct, other damage, loss, or other issues arising in any way out
# of dealing in the work, even if advised of the possibility of such
# damage or existence of a defect, except proven that it results out
# of said person’s immediate fault when using the work as intended.
#-
# Pipe a Maven POM’s <plugins> element’s content without the plugins
# element itself through this to sort them.

LC_ALL=C; export LC_ALL
unset LANGUAGE

set -e
cr=$'\r'
lf=$'\n'
(( ${#cr} == 1 ))
set -o pipefail

# offsets in element array
OgroupId=1
OartifactId=0
Oversion=5
Oextensions=6
Oexecutions=7
Odependencies=8
Ogoals=9
Oinherited=2
Oconfiguration=10
Oprecomments=4
Oincomments=3

exec 4<&0
(
	print '<toplevel>'
	tr "$cr" "$lf" <&4
	print '</toplevel>'
) | xmlstarlet fo -e UTF-8 -t - |&

die() {
	print -ru2 -- "E: $*"
	print -ru2 -- "N: line: ${line@Q}"
	exit 1
}

set -A sortlines
IFS= read -pr line
[[ $line = '<?xml version="1.0" encoding="UTF-8"?>' ]] || \
    die unexpected first line not XML declaration
IFS= read -pr line
[[ $line = '<toplevel>' ]] || die unexpected second line not start tag

set -A el
el[OgroupId]=org.apache.maven.plugins
state=0
while IFS= read -pr line; do
	case $state:$line {
	(0:'<!--'*)
		el[oprecomments]+=$line ;;
	(1:'<!--'*)
		el[oincomments]+=$line ;;
	(0:'</toplevel>')
		state=9 ;;
	(0:'	<plugin>')
		state=1 ;;
	(1:'	</plugin>')
		if [[ -n ${el[Odependencies]} ]]; then
			line=${el[Odependencies]}
			el[Odependencies]=$(mksh "$0" <<<"$line") || \
			    die could not sort dependencies
		fi
		sortlines+=("${el[0]}$cr${el[1]}$cr${el[2]}$cr${el[3]}$cr${el[4]}$cr${el[5]}$cr${el[6]}$cr${el[7]}$cr${el[8]}$cr${el[9]}$cr${el[10]}")
		set -A el
		el[OgroupId]=org.apache.maven.plugins
		state=0 ;;
	(1:'		<'@(artifactId|version|extensions|executions|dependencies|goals|inherited|configuration)'/>')
		;;
	(1:'		<groupId>'*'</groupId>')
		x=${line#'		<groupId>'}
		el[OgroupId]=${x%'</groupId>'} ;;
	(1:'		<groupId>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</groupId>' ]] && break
			x+=$line
		done
		[[ $line = '		</groupId>' ]] || \
		    die unterminated tag groupId
		[[ -n $x ]] || die empty groupId
		el[OgroupId]=$x ;;
	(1:'		<artifactId>'*'</artifactId>')
		x=${line#'		<artifactId>'}
		el[OartifactId]=${x%'</artifactId>'} ;;
	(1:'		<artifactId>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</artifactId>' ]] && break
			x+=$line
		done
		[[ $line = '		</artifactId>' ]] || \
		    die unterminated tag artifactId
		el[OartifactId]=$x ;;
	(1:'		<version>'*'</version>')
		x=${line#'		<version>'}
		el[Oversion]=${x%'</version>'} ;;
	(1:'		<version>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</version>' ]] && break
			x+=$line
		done
		[[ $line = '		</version>' ]] || \
		    die unterminated tag version
		el[Oversion]=$x ;;
	(1:'		<extensions>'*'</extensions>')
		x=${line#'		<extensions>'}
		el[Oextensions]=${x%'</extensions>'} ;;
	(1:'		<extensions>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</extensions>' ]] && break
			x+=$line
		done
		[[ $line = '		</extensions>' ]] || \
		    die unterminated tag extensions
		el[Oextensions]=$x ;;
	(1:'		<executions>'*'</executions>')
		x=${line#'		<executions>'}
		el[Oexecutions]=${x%'</executions>'} ;;
	(1:'		<executions>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</executions>' ]] && break
			x+=$line
		done
		[[ $line = '		</executions>' ]] || \
		    die unterminated tag executions
		el[Oexecutions]=$x ;;
	(1:'		<dependencies>'*'</dependencies>')
		x=${line#'		<dependencies>'}
		el[Odependencies]=${x%'</dependencies>'} ;;
	(1:'		<dependencies>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</dependencies>' ]] && break
			x+=$line
		done
		[[ $line = '		</dependencies>' ]] || \
		    die unterminated tag dependencies
		el[Odependencies]=$x ;;
	(1:'		<goals>'*'</goals>')
		x=${line#'		<goals>'}
		el[Ogoals]=${x%'</goals>'} ;;
	(1:'		<goals>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</goals>' ]] && break
			x+=$line
		done
		[[ $line = '		</goals>' ]] || \
		    die unterminated tag goals
		el[Ogoals]=$x ;;
	(1:'		<inherited>'*'</inherited>')
		x=${line#'		<inherited>'}
		el[Oinherited]=${x%'</inherited>'} ;;
	(1:'		<inherited>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</inherited>' ]] && break
			x+=$line
		done
		[[ $line = '		</inherited>' ]] || \
		    die unterminated tag inherited
		el[Oinherited]=$x ;;
	(1:'		<configuration>'*'</configuration>')
		x=${line#'		<configuration>'}
		el[Oconfiguration]=${x%'</configuration>'} ;;
	(1:'		<configuration>')
		x=
		while IFS= read -pr line; do
			[[ $line = '		</configuration>' ]] && break
			x+=$line
		done
		[[ $line = '		</configuration>' ]] || \
		    die unterminated tag configuration
		el[Oconfiguration]=$x ;;
	(*)
		die illegal line in state $state ;;
	}
done
(( state == 9 )) || die unexpected last line not end tag

for x in "${sortlines[@]}"; do
	print -r -- "$x"
done | sort -u |&

while IFS="$cr" read -prA el; do
	[[ -n ${el[Oprecomments]} ]] && print -r -- "${el[Oprecomments]}"
	print -r -- '<plugin>'
	[[ -n ${el[Oincomments]} ]] && print -r -- "${el[Oincomments]}"
	[[ -n ${el[OgroupId]} ]] && print -r -- "<groupId>${el[OgroupId]}</groupId>"
	[[ -n ${el[OartifactId]} ]] && print -r -- "<artifactId>${el[OartifactId]}</artifactId>"
	[[ -n ${el[Oversion]} ]] && print -r -- "<version>${el[Oversion]}</version>"
	[[ -n ${el[Oextensions]} ]] && print -r -- "<extensions>${el[Oextensions]}</extensions>"
	[[ -n ${el[Oexecutions]} ]] && print -r -- "<executions>${el[Oexecutions]}</executions>"
	[[ -n ${el[Odependencies]} ]] && print -r -- "<dependencies>${el[Odependencies]}</dependencies>"
	[[ -n ${el[Ogoals]} ]] && print -r -- "<goals>${el[Ogoals]}</goals>"
	[[ -n ${el[Oinherited]} ]] && print -r -- "<inherited>${el[Oinherited]}</inherited>"
	[[ -n ${el[Oconfiguration]} ]] && print -r -- "<configuration>${el[Oconfiguration]}</configuration>"
	print -r -- '</plugin>'
done

exit 0
