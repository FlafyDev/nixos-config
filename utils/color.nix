{lib, ...}: let
  inherit (lib) mod elemAt stringLength;

  decToHex = let
    intToHex = [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      "a"
      "b"
      "c"
      "d"
      "e"
      "f"
    ];
    toHex' = q: a:
      if q > 0
      then
        (toHex'
          (q / 16)
          ((elemAt intToHex (mod q 16)) + a))
      else a;
  in
    v: let
      res = toHex' v "";
    in
      if (stringLength res == 0)
      then "00"
      else if (stringLength res == 1)
      then "0${res}"
      else res;
in {
  mkColor = r: g: b: a: rec {
    inherit r g b a;
    hex = {
      r = decToHex r;
      g = decToHex g;
      b = decToHex b;
      a = decToHex a;
    };
    toHexRGB = hex.r + hex.g + hex.b;
    toHexRGBA = hex.r + hex.g + hex.b + hex.a;
    toHexARGB = hex.a + hex.r + hex.g + hex.b;
    toHexA = hex.a;
    toDecA = a;
    toNormA = a / 255.0;
  };
}
