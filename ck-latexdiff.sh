#!/bin/bash -eu

#################################################
# command arguments
#################################################
DIR=diff
SUFFIX=_diff_$(date +%y%m%d_%H%M%S)
NOT_RM_DIFFSRC=false

ARGS=
for arg in $@
do
	case $arg in
		-h | --help)
			echo "Usage: "
			echo "$(basename $0) [ --dir=* ] [ --diffsuffix=* ] [ --not-rm-diffsrc ]"
			echo "	[ latexdiff-options ] [ latexdiff-vc-options ]"
			echo "	-r [rev1] [-r rev2] file1.tex [ file2.tex ]"
			echo ""
			echo "--dir              Out-directory [default: \"diff\"]"
			echo "--diffsuffix       Filename suffix [default: \"_diff_\$date\"]"
			echo "--not-rm-diffsrc   Flag not to remove diff src files."
			echo "-h  or  --help     Show this help text."
			exit 1;;
		--dir=*)
			DIR=${arg#--dir=};;
		--diffsuffix=*)
			SUFFIX=${arg#--diffsuffix=};;
		--not-rm-diffsrc)
			NOT_RM_DIFFSRC=true;;		
		*)
			ARGS="$ARGS $arg";;
	esac
done
LATEXDIFF_VC_ARGS=$ARGS

if [ ! -z "$DIR" ]; then
	LATEXDIFF_VC_ARGS="--dir=$DIR $LATEXDIFF_VC_ARGS"
fi




#################################################
# get last element with ".tex" fmt in arguments
#################################################
array=()
for v in $ARGS
do
	if [[ $v =~ \.tex$ ]]; then
		array+=($v)
	fi
done
texargs=${array[@]}
lastindex=$((${#array[@]}-1))

# check len is not zero
if [ -z "$texargs" ]; then
	echo "Usage: arguments are same as those of latexdiff-vc"
	echo ""
	echo "error: please specify tex filename as follows:"
	echo "$0 [ --dir=* ] [ --diffsuffix=* ] [ --not-rm-diffsrc ]"
	echo "	[ latexdiff-options ] [ latexdiff-vc-options ]"
	echo "	-r [rev1] [-r rev2] file1.tex [ file2.tex ...]"
	exit 1
fi

# get tex filename
texfile=${array[$lastindex]}
difftexfile_tmp=$DIR/$(basename $texfile)
difftexfile=${difftexfile_tmp%.tex}${SUFFIX}.tex




#################################################
# main
#################################################
echo -e "======================================="
echo "latexdiff-vc"
echo -e "=======================================\n"
echo "latexdiff-vc $LATEXDIFF_VC_ARGS"

latexdiff-vc $LATEXDIFF_VC_ARGS


echo -e "\nRunning: mv \"$difftexfile_tmp\" \"$difftexfile\""
mv $difftexfile_tmp $difftexfile


echo -e "\n======================================="
echo "latexmk"
echo -e "=======================================\n"
latexmk $difftexfile -output-directory=$DIR




#################################################
# clean
#################################################
latexmk $difftexfile -output-directory=$DIR -c

rmfiles=()
for v in $(ls ${difftexfile%.tex}.*)
do
	if [[ ! $v =~ \.pdf$ ]]; then
		rmfiles+=($v)
	fi
done

$NOT_RM_DIFFSRC || echo -e "\nRunning: rm ${rmfiles[@]}"
$NOT_RM_DIFFSRC || rm ${rmfiles[@]}

