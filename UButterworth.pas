unit UButterworth;

interface

type
  THighPassFilter2 = record
    x1, x2: Double;
    y1, y2: Double;
  end;
type
  THighPassFilter4 = record
    x1, x2,x3, x4: Double;
    y1, y2,y3, y4: Double;
  end;

function HighPass_Filter2(var Buf: THighPassFilter2; x: Extended): Extended;
function HighPass_Filter4(var Buf: THighPassFilter4; x: Extended): Extended;
function THighPass_Filter4(var Buf: THighPassFilter4; x: Extended): Extended;

implementation

function HighPass_Filter2(var Buf: THighPassFilter2; x: Extended): Extended;
const
  // Coefficients for order=2 : Passe haut au-delà de 2 Hz à 20 Hz
  b0 = 0.638945525159023; // Numerator
  b1 = -1.277891050318047;
  b2 = 0.638945525159023;
  a1 = -1.142980502539901;
  a2 = 0.412801598096189;

var
  y: Extended;
begin
  // Forme canonique directe II
  y := b0 * x + b1 * Buf.x1 + b2 * Buf.x2 - a1 * Buf.y1 - a2 * Buf.y2;

  // Décalage du buffer
  Buf.x2 := Buf.x1;
  Buf.x1 := x;
  Buf.y2 := Buf.y1;
  Buf.y1 := y;

  Result := y;
end;
function HighPass_Filter4(var Buf: THighPassFilter4; x: Extended): Extended;
Const
  // Coefficients for order=4 :  Passe haut au-delà de 2 Hz à 20 Hz

  b0 = 0.43285;
  b1 = -1.73139;
  b2 = 2.59708;
  b3 = -1.73139;
  b4 = 0.43285;
  a0 = 1.00000;
  a1 = -2.36951;
  a2 = 2.31399;
  a3 = -1.05467;
  a4 = 0.18738;

var
  y: Extended;
begin
  // Forme canonique directe IV
    y := ( b0*x  + b1*Buf.x1  + b2*Buf.x2  + b3*Buf.x3  + b4*Buf.x4
             - a1*Buf.y1 - a2*Buf.y2 - a3*Buf.y3  - a4*Buf.y4 ) / a0;

  // Décalage du buffer
  Buf.x4 := Buf.x3;
  Buf.x3 := Buf.x2;
  Buf.x2 := Buf.x1;
  Buf.x1 := x;
  Buf.y4 := Buf.y3;
  Buf.y3 := Buf.y2;
  Buf.y2 := Buf.y1;
  Buf.y1 := y;

  Result := y;
end;

function THighPass_Filter4(var Buf: THighPassFilter4; x: Extended): Extended;
Const
  // Coefficients for order=4 :  Passe haut au-delà de 5 Hz à 20 Hz

  b0 = 0.169994;
  b1 = -0.679978;
  b2 = 1.019968;
  b3 = -0.679978;
  b4 = 0.169994;
  a0 = 1.00000;
  a1 = -1.288470;
  a2 = 1.107737;
  a3 = -0.377469;
  a4 = 0.064241;

var
  y: Extended;
begin
  // Forme canonique directe IV
    y := ( b0*x  + b1*Buf.x1  + b2*Buf.x2  + b3*Buf.x3  + b4*Buf.x4
             - a1*Buf.y1 - a2*Buf.y2 - a3*Buf.y3  - a4*Buf.y4 ) / a0;

  // Décalage du buffer
  Buf.x4 := Buf.x3;
  Buf.x3 := Buf.x2;
  Buf.x2 := Buf.x1;
  Buf.x1 := x;
  Buf.y4 := Buf.y3;
  Buf.y3 := Buf.y2;
  Buf.y2 := Buf.y1;
  Buf.y1 := y;

  Result := y;
end;
end.
