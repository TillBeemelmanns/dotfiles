# ULHPC (iris/aion) interactive session helpers: all si-* commands live here.
# Replaces si / si-gpu / si-bigmem from /etc/profile.d/slurm.sh (si is renamed si-cpu).
# Extra salloc options are passed through, e.g. `si-hopper -c 8 --mem 64G -t 4:00:00`.
# Works in bash and zsh.

unset -f si si-gpu si-bigmem 2>/dev/null

# Session on the shared interactive partition, selected by node constraint.
_si_constraint() {
    local constraint=$1
    shift
    echo "# salloc -p interactive --qos debug -C ${constraint} $*"
    salloc -p interactive --qos debug -C "$constraint" "$@"
}

si-cpu() {
    local constraints="batch"
    local -a opts
    while [ $# -gt 0 ]; do
        case $1 in
            -C|--constraint) shift; constraints="${constraints},$1" ;;
            *) opts+=("$1") ;;
        esac
        shift
    done
    _si_constraint "$constraints" "${opts[@]}"
}

si-gpu() {
    if [ "$ULHPC_CLUSTER" = "aion" ]; then
        echo "Job submission canceled: you can't submit GPU jobs on Aion."
        return
    fi
    case " $* " in
        *" -G"*|*" --gres"*) ;;
        *) echo '# /!\ WARNING: append -G 1 to really reserve a GPU'; set -- "$@" -G 1 ;;
    esac
    _si_constraint gpu "$@"
}

si-bigmem() {
    if [ "$ULHPC_CLUSTER" = "aion" ]; then
        echo "Job submission canceled: you can't submit Bigmem jobs on Aion."
        return
    fi
    _si_constraint bigmem "$@"
}

# Session on a dedicated GPU partition.
_si_partition() {
    local partition=$1 qos=$2
    shift 2
    case " $* " in
        *" -G"*|*" --gres"*) ;;
        *) echo '# /!\ WARNING: append -G 1 to really reserve a GPU'; set -- "$@" -G 1 ;;
    esac
    echo "# salloc -p ${partition} --qos ${qos} $*"
    salloc -p "$partition" --qos "$qos" "$@"
}

# besteffort: your account has no iris-hopper QOS; jobs may be preempted
si-hopper()      { _si_partition hopper      besteffort      "$@"; }
si-l40s()        { _si_partition l40s        iris-snt        "$@"; }
