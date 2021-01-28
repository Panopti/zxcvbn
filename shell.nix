let pkgs = import ./pin.nix { };
in pkgs.stdenv.mkDerivation {
  name = "watchdog-shell";
  buildInputs = with pkgs; [ nodejs ];
  shellHook = ''
    ROOT=`pwd`

    function setup {
      npm install
    }

    function watch {
      npm run build
      npm run watch
    }
    
    echo "To Commands: watch"
  '';
}
