unit UButterworth;

interface
 uses System.SysUtils,Math;
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

type
  TFilterCoefficients = record
    b: array[0..8] of Double; // numérateurs
    a: array[0..8] of Double; // dénominateurs
  end;
 type
  TTableau=array of double;
  TFilterType = (ftLowPass, ftHighPass, ftBandPass);

function HighPass_Filter2(var Buf: THighPassFilter2; x: Extended): Extended;
function HighPass_Filter4(Fc:Integer;var Buf: THighPassFilter4; x: Extended): Extended;

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
function HighPass_Filter4(Fc:Integer;var Buf: THighPassFilter4; x: Extended): Extended;
Const
  // Coefficients for order=4 :  Passe haut au-delà de 2 Hz à 20 Hz

//cutoff = 1 #10#13
b1:Array[0..4] of Extended=(0.662016,-2.648063,3.972095,-2.648063,0.662016);
a1:Array[0..4] of Extended=(1.000000,-3.180639,3.861194,-2.112155,0.438265);

//cutoff = 2 #10#13
b2:Array[0..4] of Extended=(0.432847,-1.731387,2.597080,-1.731387,0.432847);
a2:Array[0..4] of Extended=(1.000000,-2.369513,2.313988,-1.054665,0.187379);

//cutoff = 3 #10#13
b3:Array[0..4] of Extended=(0.275413,-1.101653,1.652480,-1.101653,0.275413);
a3:Array[0..4] of Extended=(1.000000,-1.570399,1.275613,-0.484403,0.076197);

//cutoff = 4 #10#13
b4:Array[0..4] of Extended=(0.167179,-0.668717,1.003076,-0.668717,0.167179);
a4:Array[0..4] of Extended=(1.000000,-0.782095,0.679979,-0.182676,0.030119);

//cutoff = 5 #10#13
b5:Array[0..4] of Extended=(0.093981,-0.375923,0.563885,-0.375923,0.093981);
a5:Array[0..4] of Extended=(1.000000,0.000000,0.486029,0.000000,0.017665);


var
  y: Extended;
begin
  // Forme canonique directe IV
  Case fc of
    1: y := ( b1[0]*x  + b1[1]*Buf.x1  + b1[2]*Buf.x2  + b1[3]*Buf.x3  + b1[4]*Buf.x4
             - a1[1]*Buf.y1 - a1[2]*Buf.y2 - a1[3]*Buf.y3  - a1[4]*Buf.y4 ) / a1[0];
    2: y := ( b2[0]*x  + b2[1]*Buf.x1  + b2[2]*Buf.x2  + b2[3]*Buf.x3  + b2[4]*Buf.x4
             - a2[1]*Buf.y1 - a2[2]*Buf.y2 - a2[3]*Buf.y3  - a2[4]*Buf.y4 ) / a2[0];
    3: y := ( b3[0]*x  + b3[1]*Buf.x1  + b3[2]*Buf.x2  + b3[3]*Buf.x3  + b3[4]*Buf.x4
             - a3[1]*Buf.y1 - a3[2]*Buf.y2 - a3[3]*Buf.y3  - a3[4]*Buf.y4 ) / a3[0];
    4: y := ( b4[0]*x  + b4[1]*Buf.x1  + b4[2]*Buf.x2  + b4[3]*Buf.x3  + b4[4]*Buf.x4
             - a4[1]*Buf.y1 - a4[2]*Buf.y2 - a4[3]*Buf.y3  - a4[4]*Buf.y4 ) / a4[0];
    15: y := ( b5[0]*x  + b5[1]*Buf.x1  + b5[2]*Buf.x2  + b5[3]*Buf.x3  + b5[4]*Buf.x4
             - a5[1]*Buf.y1 - a5[2]*Buf.y2 - a5[3]*Buf.y3  - a5[4]*Buf.y4 ) / a5[0];
  End;

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
