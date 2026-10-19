#!/bin/sh

code --install-extension ms-vscode.cpptools-extension-pack

mkdir -p /run/host/var/data/aluno/plc60407

echo "$(date)" >> ~/postbuild.txt

