{
  kagebi = {
    modules = [ ./kagebi/kagebi.nix ];
    system = "x86_64-linux";
  };
  ayu = {
    modules = [ ./ayu/ayu.nix ];
    system = "x86_64-linux";
  };
  vm = {
    modules = [ ./vm/vm.nix ];
    system = "x86_64-linux";
  };
}
