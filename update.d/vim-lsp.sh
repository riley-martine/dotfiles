#!/usr/bin/env bash

set -euo pipefail

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
export tmp_dir

update_lsp () {
    set -euxo pipefail
    lsp_name="$1"
    file_extension="$2"

    vim -c ":LspUninstallServer $lsp_name" -c ":qa"
    vim "$tmp_dir/file.$file_extension" -S <(echo -e "LspInstallServer! $lsp_name\n while index(lsp_settings#installed_servers(), {'version': '', 'name': '$lsp_name'}) == -1 \n sleep 1 \n endwhile \n :qa")
}

update_lsp "bash-language-server" "sh"
update_lsp "docker-langserver" "Dockerfile"
update_lsp "marksman" "md"
update_lsp "pyright-langserver" "py"
update_lsp "ruff" "py"
update_lsp "typescript-language-server" "ts"
update_lsp "vim-language-server" "vim"
update_lsp "yaml-language-server" "yaml"
update_lsp "vscode-json-language-server" "json"
update_lsp "vscode-css-language-server" "css"
