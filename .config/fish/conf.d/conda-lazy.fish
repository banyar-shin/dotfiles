set -g __conda_bin $HOME/miniconda3/bin/conda
set -g __conda_hook_cache ~/.cache/fish/conda-hook.fish

function conda --description "Lazy conda wrapper: sources cached hook on first call"
    if not test -f $__conda_hook_cache
        mkdir -p (dirname $__conda_hook_cache)
        $__conda_bin shell.fish hook >$__conda_hook_cache
    end
    functions --erase conda
    source $__conda_hook_cache
    conda $argv
end
