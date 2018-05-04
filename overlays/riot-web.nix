self: super:
{
  riot-web = super.riot-web.override {
    conf = ''
      {
        "default_hs_url": "https://matrix.nyanlout.re",
        "default_is_url": "https://vector.im",
        "brand": "Nyanloutre",
        "default_theme": "dark"
      }
    '';
  };
} 
