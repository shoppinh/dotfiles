function fish_user_key_bindings
    bind \cf fzf_change_directory

    fzf_configure_bindings \
        --directory=\co \
        --git_status=\cg
end
