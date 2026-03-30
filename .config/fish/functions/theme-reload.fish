function theme-reload --description "Reload Oh My Posh theme based on theme-mode file"
    set -l mode_file ~/.config/theme-mode
    set -l mode "dark"

    if test -f $mode_file
        set mode (cat $mode_file)
    end

    if test "$mode" = "light"
        oh-my-posh init fish --config ~/.config/fish/themes/custom-light.omp.json | source
    else
        oh-my-posh init fish --config ~/.config/fish/themes/custom.omp.json | source
    end
end
