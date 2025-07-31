unit UButterworth;

interface
type
  THighPassFilter = record
    x1, x2: Double;
    y1, y2: Double;
  end;
function HighPass_Filter(var Buf: THighPassFilter; x: Extended): Extended;

implementation
const
  // Calculés via outils DSP standard (ex : MATLAB, scipy.signal.butter)
  b0 =  0.638945525159023; // Numerator
  b1 = -1.277891050318047;
  b2 =  0.638945525159023;
  a1 = -1.142980502539901;
  a2 =  0.412801598096189;

function HighPass_Filter(var Buf: THighPassFilter; x: Extended): Extended;
var
  y: Extended;
begin
  // Forme canonique directe II
  y := b0*x + b1*Buf.x1 + b2*Buf.x2 - a1*Buf.y1 - a2*Buf.y2;

  // Décalage du buffer
  Buf.x2 := Buf.x1;
  Buf.x1 := x;
  Buf.y2 := Buf.y1;
  Buf.y1 := y;

  Result := y;
end;

end.
