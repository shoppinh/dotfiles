set --query XDG_DATA_HOME || set --local XDG_DATA_HOME ~/.local/share
set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist
set --query nvm_data || set --global nvm_data $XDG_DATA_HOME/nvm

# Reuse Node versions installed by nvm-sh (zsh/bash) inside nvm.fish.
if test -d $HOME/.nvm/versions/node
    for ver_dir in $HOME/.nvm/versions/node/*
        set --local ver (basename $ver_dir)
        if not test -e $nvm_data/$ver
            command ln -s $ver_dir $nvm_data/$ver
        end
    end
end

if not set --query nvm_default_version
    set --global nvm_default_version v22.19.0
end

function __nvm_export_nvm_bin --on-variable nvm_current_version
    if set --query nvm_current_version
        set --global NVM_BIN $nvm_data/$nvm_current_version/bin
    else
        set --erase NVM_BIN
    end
end

function _nvm_install --on-event nvm_install
    test ! -d $nvm_data && command mkdir -p $nvm_data
    echo "Downloading the Node distribution index..." 2>/dev/null
    _nvm_index_update
end

function _nvm_update --on-event nvm_update
    set --query --universal nvm_data && set --erase --universal nvm_data
    set --query --universal nvm_mirror && set --erase --universal nvm_mirror
    set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist
end

function _nvm_uninstall --on-event nvm_uninstall
    command rm -rf $nvm_data

    set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version

    set --names | string replace --filter --regex -- "^nvm" "set --erase nvm" | source
    functions --erase (functions --all | string match --entire --regex -- "^_nvm_")
end

if status is-interactive && set --query nvm_default_version && ! set --query nvm_current_version
    nvm use --silent $nvm_default_version
end
