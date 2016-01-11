#!/do/not/execute

# Copyright (C) 2011-2015  pancake<nopcode.org>
# Copyright (C) 2011-2012  Edd Barrett <vext01@gmail.com>
# Copyright (C) 2012       Simon Ruderich <simon@ruderich.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

export RABIN2_NOPLUGINS=1
export RASM2_NOPLUGINS=1
export R2_NOPLUGINS=1

GREP="$1"
GREP=""
SKIP=0
cd `dirname $0` 2>/dev/null

# ignore encoding in sed
export LANG=C
export LC_CTYPE=C

die() {
    echo "$1"
    exit 1
}

printdiff() {
    if [ -n "${VERBOSE}" ]; then
        echo
        print_label Regression:
	echo "$0"
        print_label Command:
        echo "${R2CMD}"
        print_label File:
        echo "${FILE}"
        print_label Script:
        cat ${TMP_RAD}
    fi
}

COUNT=0
run_test() {
    COUNT=$(($COUNT+1))
    if [ -n "${ONLY}" ]; then
	if [ "${ONLY}" != "${COUNT}" ]; then
		return
        fi
    fi
    # TODO: remove which dependency
    [ -z "${R2}" ] && R2=$(which radare2)
    PD="/tmp/r2-regressions/" # XXX
    if [ -n "${R2RWD}" ]; then
      PD="${R2RWD}"
    fi
    if [ -z "${R2}" ]; then
      echo "ERROR: Cannot find radare2 program in PATH"
      exit 1
    fi

    # add a prepended program to run test eg. zzuf
    if [ -n "${PREPEND}" ]; then
      export R2="${PREPEND} ${R2}"
    fi

    if [ -n "${GREP}" ]; then
        if [ -z "`echo \"${NAME}\" | grep \"${GREP}\"`" ]; then
            return
        fi
    fi

    # Set by run_tests.sh if all tests are run - otherwise get it from test
    # name.
    if [ -z "${TEST_NAME}" ]; then
       TEST_NAME=$(basename "$0" | sed 's/\.sh$//')
    fi

    NAME_TMP="${TEST_NAME}" #`basename $NAME` #"${TEST_NAME}"
    if [ -n "${NAME}" ]; then
        if [ "$NAME_TMP" = "$NAME" ]; then
		NAME_A="${NAME_TMP}"
		NAME_B=""
              NAME_TMP="${NAME_TMP}:"
        else
		NAME_A="${NAME_TMP}"
		NAME_B="${NAME}"
              NAME_TMP="${NAME_TMP}: ${NAME}"
        fi
    fi
    [ -n "${VALGRIND}" ] && NAME_TMP="${NAME_TMP} (valgrind)"

    if [ -n "${NOCOLOR}" ]; then
        printf "[  ]  ${COUNT}  %s: %-30s" "${NAME_A}" "${NAME_B}"
    else
        printf "\033[33m[  ]  ${COUNT}  %s: \033[0m%-30s" "${NAME_A}" "${NAME_B}" #"${NAME_TMP}"
    fi

    # Check required variables.
    if [ -z "${FILE}" ]; then
        test_failed "FILE missing!"
        test_reset
        return
    fi
    if [ -z "${SHELLCMD}" -a -z "${CMDS}" ]; then
        test_failed "CMDS missing!"
        test_reset
        return
    fi
    # ${EXPECT} can be empty. Don't check it.

    # Verbose mode is always used if only a single test is run.
    if [ -z "${R2_SOURCED}" ]; then
        VERBOSE=1
    fi

    mkdir -p ${PD}
    TMP_RAD=`mktemp "${PD}/${TEST_NAME}-rad.XXXXXX"`
    if [ $? != 0 ]; then
        echo "Please set R2RWD path to something different than /tmp/r2-regressions"
        exit 1
    fi
    TMP_OUT=`mktemp "${PD}/${TEST_NAME}-out.XXXXXX"`
    TMP_ERR=`mktemp "${PD}/${TEST_NAME}-err.XXXXXX"`
    TMP_EXR=`mktemp "${PD}/${TEST_NAME}-exr.XXXXXX"` # expected error
    TMP_VAL=`mktemp "${PD}/${TEST_NAME}-val.XXXXXX"`
    TMP_EXP=`mktemp "${PD}/${TEST_NAME}-exp.XXXXXX"`

    if [ -n "${SHELLCMD}" ]; then
        R2CMD="$SHELLCMD"
    else
        # R2_ARGS must be defined by the user in cmdline f.ex -e io.vio=true
        # No colors and no user configs.
        if [ -n "${DEBUG}" ]; then
            R2ARGS="gdb --args ${R2} -e scr.color=0 -N -q -i ${TMP_RAD} ${R2_ARGS} ${ARGS} ${FILE}"
        else
            R2ARGS="${R2} -e scr.color=0 -N -q -i ${TMP_RAD} ${R2_ARGS} ${ARGS} ${FILE} > ${TMP_OUT} 2> ${TMP_ERR}"
        fi
        R2CMD=
        # Valgrind to detect memory corruption.
        if [ -n "${VALGRIND}" ]; then
			if [ -n "${VALGRIND_XML}" ]; then
				R2CMD="${VALGRIND} --xml=yes --xml-file=${TMP_VAL}.memcheck"
			else
				R2CMD="valgrind --error-exitcode=47 --log-file=${TMP_VAL}"
			fi
        fi
        R2CMD="${R2CMD} ${R2ARGS}"
        #if [ -n "${VERBOSE}" ]; then
            #echo #$R2CMD
        #fi
    fi

    # Put expected outcome and program to run in files and run the test.
    printf "%s\n" "${CMDS}" > ${TMP_RAD}
    printf "%s" "${EXPECT}" > ${TMP_EXP}
    printf "%s" "${EXPECT_ERR}" > ${TMP_EXR}
    eval "${R2CMD}"
    CODE=$?

    if [ -n "${R2_SOURCED}" ]; then
        TESTS_TOTAL=$(( TESTS_TOTAL + 1 ))
    fi

    # ${FILTER} can be used to filter out random results to create stable
    # tests.
    if [ -n "${FILTER}" ]; then
        # Filter stdout.
        FILTER_CMD="cat ${TMP_OUT} | ${FILTER} > ${TMP_OUT}.filter"
        #if [ -n "${VERBOSE}" ]; then
        #    echo "Filter (stdout):  ${FILTER}"
        #fi
        eval "${FILTER_CMD}"
        mv "${TMP_OUT}.filter" "${TMP_OUT}"

        # Filter stderr.
        FILTER_CMD="cat ${TMP_ERR} | ${FILTER} > ${TMP_ERR}.filter"
        #if [ -n "${VERBOSE}" ]; then
        #    echo "Filter (stderr):  ${FILTER}"
        #fi
        eval "${FILTER_CMD}"
        mv "${TMP_ERR}.filter" "${TMP_ERR}"
    fi

    # Check if radare2 exited with correct exit code.
    if [ -n "${EXITCODE}" ]; then
        if [ ${CODE} -eq "${EXITCODE}" ]; then
            CODE=0
            EXITCODE=
        else
            EXITCODE=${CODE}
        fi
    fi

    # Check if the output matched.
    diff "${TMP_OUT}" "${TMP_EXP}" >/dev/null
    OUT_CODE=$?
    if [ "${NOT_EXPECT}" = 1 ]; then
        if [ "${OUT_CODE}" = 0 ]; then
            OUT_CODE=1
        else
            OUT_CODE=0
        fi
    fi
    if [ "${IGNORE_ERR}" = 1 ]; then
        ERR_CODE=0
    else
        diff "${TMP_ERR}" "${TMP_EXR}" >/dev/null
        ERR_CODE=$?
        if [ "${NOT_EXPECT}" = 1 ]; then
            if [ "${ERR_CODE}" = 0 ]; then
                ERR_CODE=1
            else
                ERR_CODE=0
            fi
        fi
	if [ "${ERR_CODE}" != 0 ]; then
		cat "${TMP_ERR}"
	fi
    fi

    if [ ${CODE} -eq 47 ]; then
        test_failed "valgrind error"
        if [ -n "${VERBOSE}" ]; then
            cat "${TMP_VAL}"
            echo
        fi
    elif [ -n "${EXITCODE}" ]; then
        test_failed "wrong exit code: ${EXITCODE}"
        printdiff
    elif [ ${CODE} -ne 0 ]; then
        test_failed "radare2 crashed"
        printdiff
        if [ -n "${VERBOSE}" ]; then
            cat "${TMP_OUT}"
            cat "${TMP_ERR}"
            echo
        fi
    elif [ ${OUT_CODE} -ne 0 ]; then
        test_failed "out"
        printdiff
        if [ -n "${VERBOSE}" ]; then
            print_label Diff:
            diff -u "${TMP_EXP}" "${TMP_OUT}"
            echo
        fi
    elif [ ${ERR_CODE} -ne 0 ]; then
        test_failed "err"
        printdiff
        if [ -n "${VERBOSE}" ]; then
            diff -u "${TMP_EXR}" "${TMP_ERR}"
            echo
        fi
    else
        test_success
    fi
    rm -f "${TMP_RAD}" "${TMP_OUT}" \
	  "${TMP_ERR}" "${TMP_VAL}" \
          "${TMP_EXP}" "${TMP_EXR}"

    # Reset most variables in case the next test script doesn't set them.
    if [ "${REVERSERC}" = '1' ]; then
       export OUT_CODE=0
    fi
    test_reset

    return $OUT_CODE
}

test_reset() {
    [ -z "$NAME" ] && NAME=$0
    FILE="-"
    ARGS=
    CMDS=
    NOT_EXPECT=
    EXPECT=
    EXPECT_ERR=
    IGNORE_ERR=1
    FILTER=
    EXITCODE=
    BROKEN=
    SHELLCMD=
    PREPEND=
    REVERSERC=
    ESSENTIAL=
    SKIP=
    DEBUG=
}

test_reset

test_success() {
    if [ -z "${BROKEN}" ]; then
        print_success "OK"
    else
        print_fixed "FX"
    fi

    if [ -n "${R2_SOURCED}" ]; then
        if [ -z "${BROKEN}" ]; then
            TESTS_SUCCESS=$(( TESTS_SUCCESS + 1 ))
        else
            TESTS_FIXED=$(( TESTS_FIXED + 1 ))
        fi
    fi
}

test_failed() {
    if [ -n "${REVERSERC}" ]; then
        print_success "OK"
        SKIP=1
    fi
    if [ -z "${SKIP}" -o "${SKIP}" = 0 ]; then
        if [ -n "${ESSENTIAL}" ]; then
            print_failed "EF" # essential failure
        else
            if [ -z "${BROKEN}" ]; then
                print_failed "XX"
            else
                print_broken "BR"
            fi
        fi
    fi
    FAILED="${FAILED}${TEST_NAME}:"
    if [ -n "${R2_SOURCED}" ]; then
        if [ -n "${ESSENTIAL}" ]; then
            TESTS_FATAL=$(( TESTS_FATAL + 1 ))
        else
            if [ -z "${BROKEN}" ]; then
                TESTS_FAILED=$(( TESTS_FAILED + 1 ))
            else
                TESTS_BROKEN=$(( TESTS_BROKEN + 1 ))
            fi
        fi
    fi
}

if [ -n "${TRAVIS}" ]; then
    NL="\n"
else
    NL="\r"
fi

print_success() {
    if [ -n "${NOOK}" ]; then
        printf "\033[2K\r"
    else
        if [ -n "${NOCOLOR}" ]; then
            printf "%b" "${NL}[${*}]\n"
        else
            printf "%b" "${NL}\033[32m[${*}]\033[0m\n"
        fi
    fi
}

print_broken() {
if [ -n "${NOCOLOR}" ]; then
    printf "%b" "${NL}[${*}]\n"
else
    printf "%b" "${NL}\033[34m[${*}]\033[0m\n"
fi
}

print_failed() {
if [ -n "${NOCOLOR}" ]; then
    printf "%b" "${NL}[${*}]\n"
else
    printf "%b" "${NL}\033[31m[${*}]\033[0m\n"
fi
}

print_fixed() {
if [ -n "${NOCOLOR}" ]; then
    printf "%b" "${NL}[${*}]\n"
else
    printf "%b" "${NL}\033[33m[${*}]\033[0m\n"
fi
}

print_label() {
if [ -n "${NOCOLOR}" ]; then
    printf "%s\n" $@
else
    printf "\033[35m%s \033[0m" $@
fi
}

print_found_nonexec() {
MSG="Found non-executeable file '$1', skipping. (If it's a test, use chmod +x)"
if [ -n "${NOCOLOR}" ]; then
    printf "%s\n" "$MSG"
else
    printf "\033[1;31m%s\033[0m\n" "$MSG"
fi
}

print_report() {
    if [ ! -z "${NOREPORT}" ]; then
        return
    fi

    echo
    echo "=== Report ==="
    echo
    printf "      SUCCESS"
    if [ "${TESTS_SUCCESS}" -gt 0 ]; then
        print_success "${TESTS_SUCCESS}"
    else
        print_failed "${TESTS_SUCCESS}"
    fi
    printf "      FIXED"
    if [ "${TESTS_FIXED}" -gt 0 ]; then
        print_fixed   "${TESTS_FIXED}"
    else
        print_fixed   0
    fi
    printf "      BROKEN"
    if [ "${TESTS_BROKEN}" -gt 0 ]; then
        print_broken "${TESTS_BROKEN}"
    else
        print_broken 0
    fi
    printf "      FATAL"
    if [ "${TESTS_FATAL}" -gt 0 ]; then
        print_failed "${TESTS_FATAL}"
    else
        print_failed 0
    fi
    printf "      FAILED"
    if [ "${TESTS_FAILED}" -gt 0 ]; then
        print_failed  "${TESTS_FAILED}"
    else
        print_failed  0
    fi
    printf "      TOTAL${NL}"
    print_label "[${TESTS_TOTAL}]"

    dc -V > /dev/null 2>&1
    if [ $? = 0 ]; then
      BADBOYS=$((${TESTS_BROKEN}+${TESTS_FAILED}+${TESTS_FATAL}))
      BN=`echo "100 ${BADBOYS} * ${TESTS_TOTAL} / n" | dc`
      printf "      BROKENNESS${NL}"
      print_label "[${BN}%]"
      echo
    else
      printf " TOTAL${NL}"
      echo
    fi
}

save_stats(){
    cd $R
    V=`radare2 -v 2>/dev/null| grep ^rada| awk '{print $5}'`
    touch stats.csv
    grep -v "^$V" stats.csv > .stats.csv
    echo "$V,${TESTS_SUCCESS},${TESTS_FIXED},${TESTS_BROKEN},${TESTS_FAILED},${TESTS_FATAL},${FAILED}" >> .stats.csv
    sort .stats.csv > stats.csv
    rm -f .stats.csv
}

