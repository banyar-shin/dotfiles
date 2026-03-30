function ws --description "Manage and open Zed workspaces"
    set -l ws_dir ~/.config/workspaces
    set -l cmd $argv[1]

    # Default: open workspace
    if test -z "$cmd"
        set cmd "open"
        set -a argv "default"
    end

    switch $cmd
        case edit
            set -l name (test -n "$argv[2]" && echo $argv[2] || echo "default")
            set -l file "$ws_dir/$name.toml"
            if not test -f "$file"
                echo "Workspace '$name' not found. Use: ws new $name"
                return 1
            end
            zed "$file"

        case list ls
            echo "Workspaces:"
            for f in $ws_dir/*.toml
                set -l name (basename $f .toml)
                set -l count (grep -c '^path = ' $f 2>/dev/null || echo 0)
                echo "  $name ($count paths)"
            end

        case new
            set -l name $argv[2]
            if test -z "$name"
                echo "Usage: ws new <name>"
                return 1
            end
            set -l file "$ws_dir/$name.toml"
            if test -f "$file"
                echo "Workspace '$name' already exists. Use: ws edit $name"
                return 1
            end
            echo "# Zed Workspace: $name

[workspace]
name = \"$name\"

# [[paths]]
# path = \"~/some/project\"
# label = \"my project\"" > $file
            echo "Created workspace '$name'. Use: ws edit $name"

        case add
            set -l target $argv[2]
            set -l name (test -n "$argv[3]" && echo $argv[3] || echo "default")
            if test -z "$target"
                echo "Usage: ws add <path> [workspace]"
                return 1
            end
            set -l resolved (realpath "$target" 2>/dev/null || echo "$target")
            set -l label (basename "$resolved")
            echo "
[[paths]]
path = \"$resolved\"
label = \"$label\"" >> "$ws_dir/$name.toml"
            echo "Added '$resolved' to workspace '$name'"

        case rm remove
            set -l target $argv[2]
            set -l name (test -n "$argv[3]" && echo $argv[3] || echo "default")
            if test -z "$target"
                echo "Usage: ws rm <path> [workspace]"
                return 1
            end
            set -l file "$ws_dir/$name.toml"
            set -l resolved (realpath "$target" 2>/dev/null || echo "$target")
            # Remove the [[paths]] block containing this path
            set -l tmp (mktemp)
            awk -v target="$resolved" '
                /^\[\[paths\]\]/ { block = ""; capture = 1 }
                capture { block = block $0 "\n"; if (/^path = /) { if (index($0, target)) { skip = 1 } }; if (/^$/ || (/^\[/ && !/^\[\[paths\]\]/)) { capture = 0; if (!skip) { printf "%s", block }; skip = 0; next } ; next }
                { print }
            ' "$file" > "$tmp"
            mv "$tmp" "$file"
            echo "Removed '$resolved' from workspace '$name'"

        case sync
            node ~/.config/workspaces/sync-obsidian.js

        case info
            set -l name $argv[2]
            if test -n "$name"
                node ~/.config/workspaces/parse-projects.js --info $name
            else
                node ~/.config/workspaces/parse-projects.js --info
            end

        case open '*'
            set -l name $cmd
            if test "$cmd" = "open"
                set name (test -n "$argv[2]" && echo $argv[2] || echo "default")
            end
            set -l file "$ws_dir/$name.toml"
            if not test -f "$file"
                echo "Workspace '$name' not found. Available:"
                ws list
                return 1
            end
            set -l dirs
            for p in (grep '^path = ' "$file" | sed 's/^path = "//;s/"$//')
                set -l expanded (eval echo $p)
                if test -d "$expanded"
                    set -a dirs "$expanded"
                else
                    echo "Warning: '$expanded' not found, skipping"
                end
            end
            if test (count $dirs) -eq 0
                echo "No valid paths in workspace '$name'. Use: ws edit $name"
                return 1
            end
            echo "Opening workspace '$name' with "(count $dirs)" projects..."
            zed $dirs
    end
end
