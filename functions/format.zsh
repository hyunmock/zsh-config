
function run_in_clean_git_env()
{
    (
        for env_var in $(git rev-parse --local-env-vars 2>/dev/null); do
            unset "$env_var"
        done
        "$@"
    )
}

function format_check()
{
    project_dir=$(realpath $(pwd))
    quiet=0

    OPTIND=1 # Reset in case getopts has been used previously in the shell.
    while getopts hd:q opt; do
        case $opt in
            h)
        cat << EOF
Option               Description                             Default
  -d arg      Project directory to be checked         current working directory
  -q arg      Quiet mode (still has some output)
EOF
                return
            ;;
            d)
                project_dir=$(realpath $OPTARG)
            ;;
            q)
                quiet=1
            ;;
            *)
            ;;
        esac
    done
    shift "$((OPTIND-1))"   # Discard the options and sentinel

    return_code=0

    pushd ${zuul_jobs_path} > /dev/null

    clang_check_cmd=(bazel run @swh_bazel_rules//clang_format:check --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- ${project_dir})
    if [[ $quiet -ne 0 ]]; then
        run_in_clean_git_env "${clang_check_cmd[@]}" > /dev/null
    else
        run_in_clean_git_env "${clang_check_cmd[@]}"
    fi
    return_code=$?
    if [ $return_code -ne 0 ]; then
        popd > /dev/null
        cat << EOF
Error: clang_format check failed
EOF
        return $return_code
    fi

    buildifier_cmd=(bazel run @buildifier_linux//file:buildifier --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- -mode=check -r ${project_dir})
    if [[ $quiet -ne 0 ]]; then
        run_in_clean_git_env "${buildifier_cmd[@]}" > /dev/null
    else
        run_in_clean_git_env "${buildifier_cmd[@]}"
    fi
    return_code=$?

    popd > /dev/null
    if [ $return_code -ne 0 ]; then
   cat << EOF
Error: buildifier check failed
EOF
    fi
    return $return_code
}


function format_fix()
{
    project_dir=$(realpath $(pwd))
    quiet=0
    OPTIND=1 # Reset in case getopts has been used previously in the shell.
    while getopts hd:q opt; do
        case $opt in
            h)
        cat << EOF
Option               Description                           Default
  -d arg      Project directory to be fixed         current working directory
  -q arg      Quiet mode (still has some output)
EOF
                return
            ;;
            d)
                project_dir=$(realpath $OPTARG)
            ;;
            q)
                quiet=1
            ;;
            *)
            ;;
        esac
    done
    shift "$((OPTIND-1))"   # Discard the options and sentinel

    pushd ${zuul_jobs_path} > /dev/null
    if [[ $quiet -ne 0 ]]; then
        run_in_clean_git_env bazel run @swh_bazel_rules//clang_format:fix --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- ${project_dir} > /dev/null
        run_in_clean_git_env bazel run @buildifier_linux//file:buildifier --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- -mode=fix -r ${project_dir} > /dev/null
    else
        run_in_clean_git_env bazel run @swh_bazel_rules//clang_format:fix --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- ${project_dir}
        run_in_clean_git_env bazel run @buildifier_linux//file:buildifier --config=gcc9 --ui_event_filters=-INFO,-DEBUG -- -mode=fix -r ${project_dir}
    fi
    popd > /dev/null
}
