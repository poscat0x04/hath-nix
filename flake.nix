{
  description = "Hentai@Home nix overlays and modules";

  outputs = { ... }:
    {
      nixosModules = {
        hath = import ./modules/hath.nix;
      };

      overlay = import ./overlay.nix;
    };
}
