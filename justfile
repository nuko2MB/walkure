default: build

gaa:
    @git add --all
    git submodule foreach 'git add --all'

build *FLAGS: gaa
    nh os switch {{ flake }} {{ FLAGS }}

update *FLAGS: gaa
    just build -u {{ FLAGS }}

test *FLAGS: gaa
    nh os test {{ flake }} {{ FLAGS }}

boot *FLAGS: gaa
    nh os boot {{ flake }} {{ FLAGS }}

bootloader *FLAGS: gaa
    sudo nixos-rebuild boot --flake . --install-bootloader

run-fsh pkg *FLAGS:
    #!/usr/bin/env fish
    set pkg (string join "#" "nixpkgs" {{ pkg }})
    nix run $pkg -- {{ FLAGS }}

run pkg *FLAGS:
    #!/usr/bin/env nu
    nix run "nixpkgs#{{ pkg }}" -- {{ FLAGS }}

[no-cd]
shell-fsh +PKGS:
    #!/usr/bin/env fish
    set pkgs {{ PKGS }}
    for i in (seq (count $pkgs))
        set pkgs[$i] (string join "#" "nixpkgs" $pkgs[$i])
    end
    nix shell $pkgs

[no-cd]
shell +PKGS:
    #!/usr/bin/env nu
    let args = [ {{ PKGS }} ] | each { |s| nixpkgs#($s) }
    nix shell ...$args

[no-cd]
repl:
    nix repl --expr 'import<nixpkgs>{}'

nix := "nix --extra-experimental-features \"nix-command flakes\""
flake := ".?submodules=1"

[no-cd]
nix *args:
    {{ nix }} {{ args }}

install hostname:
    #!/usr/bin/env bash
    echo -e  "\e[91m--------------\nWarning All data on specified disks will be deleted! \n--------------\e[0m"
    read -p "Confirm (y) " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit
    fi
    sudo {{ nix }} run 'github:nix-community/disko/latest' -- -f .#{{ hostname }} -m disko
    sudo nixos-install --no-root-passwd --flake .#{{ hostname }} 

nix-update package *FLAGS='--version=branch=main':
    #!/usr/bin/env bash
    nix-update {{ package }} {{ FLAGS }}
