#!/bin/bash -eu

PROG=ck-latexdiff.sh
DIR=diff
FLAGS="--flatten"
DATE=$(date +%y%m%d_%H%M%S)
CONFIG_DIR=${HOME}/.config/latex


#################################################
# command arguments
#################################################
WITH_DEL=false
EXIST_SUFFIX_ARG=false
ARGS=
for arg in $@
do
	case $arg in
		-h | --help)
			echo "Usage: "
			echo "$(basename $0) [ --suffix=* ] [ -w or --with-del ]"
			echo "	[ --not-rm-diffsrc ]"
			echo "	[ latexdiff-options ] [ latexdiff-vc-options ]"
			echo "	-r [rev1] [-r rev2] file1.tex [ file2.tex ]"
			echo ""
			echo "--suffix=*        Filename suffix [default: \"_diff<wd>_<date text>\"]"
			echo "-w or --with-del  Flag to show text before modified."
			echo "--not-rm-diffsrc  Flag not to remove diff src files."
			echo "-h  or  --help    Show this help text."
			exit 1;;
		-w | --with-del)
			WITH_DEL=true;;
		--suffix=*)
			SUFFIX=${arg#--suffix=}
			EXIST_SUFFIX_ARG=true;;
		*)
			ARGS="$ARGS $arg";;
	esac
done


if "${WITH_DEL}"; then
	${EXIST_SUFFIX_ARG} || SUFFIX=_diffwd_${DATE}
	PREAMBLE_TEX=${CONFIG_DIR}/diffpreamble-withdel.tex
	ADD_TEX=\\color{red}\\highLight[yellow]{\#1}
	DEL_TEX=\\color{cyan}\\strikeThrough[cyan]{\#1}
	MATH_MARKUP=1
else
	${EXIST_SUFFIX_ARG} || SUFFIX=_diff_${DATE}
	PREAMBLE_TEX=${HOME}/.config/latex/diffpreamble.tex
	ADD_TEX=\\color{red}\#1
	DEL_TEX=""
	MATH_MARKUP=3
fi

LATEXDIFF_ARGS="\
	${FLAGS} \
	--preamble=${PREAMBLE_TEX} \
	--math-markup=${MATH_MARKUP} \
	--dir=${DIR} \
	--diffsuffix=${SUFFIX} \
	$ARGS" 




#################################################
# create preamble texfile if not exist
#################################################
if [ ! -f ${PREAMBLE_TEX} ]; then
	echo "preamble texfile for latexdiff is not found."
	echo "=> \"${PREAMBLE_TEX}\" is auto-generated."
	mkdir -p ${CONFIG_DIR}

cat <<EOF > ${PREAMBLE_TEX}
%DIF PREAMBLE EXTENSION
%DIF UNDERLINE PREAMBLE

%---begin MODIFIED---
\\RequirePackage[cmyk]{xcolor}
\\RequirePackage{luacolor,lua-ul}
\\providecommand{\\DIFadd}[1]{{\\protect${ADD_TEX}}}
\\providecommand{\\DIFdel}[1]{{\\protect${DEL_TEX}}}
%---end MODIFIED---

%DIF SAFE PREAMBLE
\\providecommand{\\DIFaddbegin}{}
\\providecommand{\\DIFaddend}{}
\\providecommand{\\DIFdelbegin}{}
\\providecommand{\\DIFdelend}{}
\\providecommand{\\DIFmodbegin}{}
\\providecommand{\\DIFmodend}{}

%DIF FLOATSAFE PREAMBLE
\\providecommand{\\DIFaddFL}[1]{\\DIFadd{#1}}
\\providecommand{\\DIFdelFL}[1]{\\DIFdel{#1}}
\\providecommand{\\DIFaddbeginFL}{}
\\providecommand{\\DIFaddendFL}{}
\\providecommand{\\DIFdelbeginFL}{}
\\providecommand{\\DIFdelendFL}{}
EOF

fi




#################################################
# main
#################################################
${PROG} ${LATEXDIFF_ARGS}

