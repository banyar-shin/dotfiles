set -l _theme_mode "dark"
if test -f ~/.config/theme-mode
    set _theme_mode (cat ~/.config/theme-mode)
end

if test "$_theme_mode" = "light"
    oh-my-posh init fish --config ~/.config/fish/themes/custom-light.omp.json | source
else
    oh-my-posh init fish --config ~/.config/fish/themes/custom.omp.json | source
end
