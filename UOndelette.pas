unit UOndelette;

interface

uses
  SysUtils, Math,UconfAesa_Oper;

procedure DWT_Daubechies4(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
procedure DWT_2Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);
procedure DWT_Daubechies8(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
procedure DWT_4Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);

procedure DWT_Coiflet6(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
procedure DWT_3Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);


implementation

{const
  // Coefficients Daubechies 4
  h: array[0..3] of Double = (
    (1 + Sqrt(3))/ (4 * Sqrt(2)),
    (3 + Sqrt(3))/ (4 * Sqrt(2));
    (3 - Sqrt(3))/ (4 * Sqrt(2));
    (1 - Sqrt(3))/ (4 * Sqrt(2))
  );

  g: array[0..3] of Double = (  // High pass coefficients derived from h
    h[3], -h[2], h[1], -h[0]
  ); }
const
  // Coefficients Daubechies 4 calculés et déclarés ici simplement
  h: array[0..3] of Double = (
    0.4829629131445341,
    0.8365163037378079,
    0.2241438680420134,
   -0.1294095225512603
  );

  g: array[0..3] of Double = (
   -0.1294095225512603,
   -0.2241438680420134,
    0.8365163037378079,
   -0.4829629131445341
  );
{  // Coefficients Daubechies 8 (Db8), longueur 8  1 et 3 Hz
  h8: array[0..7] of Double = (
    0.2303778133088964,
    0.7148465705529154,
    0.6308807679298587,
   -0.0279837694168599,
   -0.1870348117190931,
    0.0308413818355607,
    0.0328830116668852,
   -0.0105974017850690
  );

  // Coefficients haute fréquence associés (g)
  g8: array[0..7] of Double = (
   -0.0105974017850690,
   -0.0328830116668852,
    0.0308413818355607,
    0.1870348117190931,
   -0.0279837694168599,
   -0.6308807679298587,
    0.7148465705529154,
   -0.2303778133088964
  ); }

  // Coefficients Daubechies 8 (Db8), longueur 8  0.5 et 5 Hz
  h8: array[0..7] of Double = (
    0.2303778133088964,
    0.7148465705529154,
    0.6308807679298587,
   -0.0279837694168599,
   -0.1870348117190931,
    0.0308413818355607,
    0.0328830116668852,
   -0.0105974017850690
  );

  g8: array[0..7] of Double = (
   -0.0105974017850690,
   -0.0328830116668852,
    0.0308413818355607,
    0.1870348117190931,
   -0.0279837694168599,
   -0.6308807679298587,
    0.7148465705529154,
   -0.2303778133088964
  );
const
  // Coefficients Coiflet 6 (length 12)
  h6: array[0..11] of Double = (
    -0.01565572813546454,
    -0.0727326195128539,
     0.38486484686420286,
     0.8525720202122554,
     0.3378976624578092,
    -0.0727326195128539,
    -0.01565572813546454,
     0.026670057900950818,
     0.02309857827243678,
    -0.10526485328869354,
    -0.035233259935308,
     0.13501102001025458
  );

  // Calculé selon la propriété quadrature mirror filter (QMF)
  g6: array[0..11] of Double = (
    -0.13501102001025458, 0.035233259935308, 0.10526485328869354, 0.02309857827243678, -0.026670057900950818,-0.01565572813546454,
    0.0727326195128539, 0.3378976624578092, -0.8525720202122554, 0.38486484686420286, 0.0727326195128539, -0.01565572813546454  );


// Convolution et sous-échantillonnage par 2
procedure DWT_Daubechies4(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
var
  i, len, j: Integer;
  halfLen: Integer;
begin
  len := Length(Signal);
  if len < 4 then
  begin
    Approx := nil;
    Detail := nil;
    Exit;
  end;

  halfLen := len div 2;
  SetLength(Approx, halfLen);
  SetLength(Detail, halfLen);

  for i := 0 to halfLen - 1 do
  begin
    Approx[i] := 0;
    Detail[i] := 0;
    for j := 0 to 3 do
    begin
      // Indice circulaire (modulo)
      Approx[i] := Approx[i] + h[j] * Signal[(2 * i + j) mod len];
      Detail[i] := Detail[i] + g[j] * Signal[(2 * i + j) mod len];
    end;
  end;
end;

procedure DWT_Daubechies8(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
var
  i, j, len, halfLen, idx: Integer;
begin
  len := Length(Signal);
  if len < 8 then
  begin
    Approx := nil;
    Detail := nil;
    Exit;
  end;

  halfLen := len div 2;
  SetLength(Approx, halfLen);
  SetLength(Detail, halfLen);

  for i := 0 to halfLen - 1 do
  begin
    Approx[i] := 0;
    Detail[i] := 0;
    for j := 0 to 7 do
    begin
      idx := (2 * i + j) mod len;  // indice circulaire
      Approx[i] := Approx[i] + h8[j] * Signal[idx];
      Detail[i] := Detail[i] + g8[j] * Signal[idx];
    end;
  end;
end;

procedure DWT_Coiflet6(const Signal: TExtendedArray; out Approx, Detail: TExtendedArray);
var
  i, j, len, halfLen, idx: Integer;
begin
  len := Length(Signal);
  if len < 12 then
  begin
    Approx := nil;
    Detail := nil;
    Exit;
  end;

  halfLen := len div 2;
  SetLength(Approx, halfLen);
  SetLength(Detail, halfLen);

  for i := 0 to halfLen - 1 do
  begin
    Approx[i] := 0;
    Detail[i] := 0;
    for j := 0 to 11 do
    begin
      idx := (2 * i + j) mod len;  // indice circulaire
      Approx[i] := Approx[i] + h6[j] * Signal[idx];
      Detail[i] := Detail[i] + g6[j] * Signal[idx];
    end;
  end;
end;


procedure DWT_2Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);
var
  Approx1: TExtendedArray;
begin
  // Niveau 1 : decompose Signal en Approx1 + Detail1
  DWT_Daubechies4(Signal, Approx1, Detail1);

  // Niveau 2 : decompose Approx1 en Approx2 + Detail2
  DWT_Daubechies4(Approx1, Approx2, Detail2);
end;

procedure DWT_4Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);
var
  Approx1: TExtendedArray;
begin
  // Niveau 1 : decompose Signal en Approx1 + Detail1
  DWT_Daubechies8(Signal, Approx1, Detail1);

  // Niveau 2 : decompose Approx1 en Approx2 + Detail2
  DWT_Daubechies8(Approx1, Approx2, Detail2);
end;

procedure DWT_3Levels(const Signal: TExtendedArray; out Approx2, Detail2, Detail1: TExtendedArray);
var
  Approx1: TExtendedArray;
begin
  // Niveau 1 : Signal -> Approx1 + Detail1
  DWT_Coiflet6(Signal, Approx1, Detail1);
  // Niveau 2 : Approx1 -> Approx2 + Detail2
  DWT_Coiflet6(Approx1, Approx2, Detail2);
end;


end.


