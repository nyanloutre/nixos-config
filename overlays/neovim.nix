self: super:
{
  neovim = super.neovim.override {
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set shiftwidth=2
        set softtabstop=2
        set expandtab
        set background=dark
      '';
      packages.myVimPackage = with super.vimPlugins; {
        start = [
          vim-startify  airline             sensible
          polyglot      ale                 fugitive
        ];
        opt = [ ];
      };
    };
  };
} 
