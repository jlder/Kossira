unit UFFT;

interface

type
  TComplex = record
    Re, Im: Extended;
  end;

Var
  IFFT: Integer;
  amplitude: Array [0 .. 255] of Extended;

procedure FFT(var Buffer: array of TComplex; Inverse: Boolean = False);

implementation

uses Math;

function CAdd(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re + B.Re;
  Result.Im := A.Im + B.Im;
end;

function CSub(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re - B.Re;
  Result.Im := A.Im - B.Im;
end;

function CMul(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re * B.Re - A.Im * B.Im;
  Result.Im := A.Re * B.Im + A.Im * B.Re;
end;

procedure FFT(var Buffer: array of TComplex; Inverse: Boolean = False);
var
  N, K, J, L, M: Integer;
  A, T, U, Temp: TComplex;
  E, Angle, Sign: Double;
begin
  N := Length(Buffer);
  if N = 0 then
    Exit;

  // Bit reversal reordering
  J := 0;
  for IFFT := 0 to N - 2 do
  begin
    if IFFT < J then
    begin
      Temp := Buffer[IFFT];
      Buffer[IFFT] := Buffer[J];
      Buffer[J] := Temp;
    end;
    M := N shr 1;
    while (J >= M) and (M >= 2) do
    begin
      J := J - M;
      M := M shr 1;
    end;
    J := J + M;
  end;

  // Main FFT loop
  Sign := IfThen(Inverse, 1.0, -1.0);
  L := 2;
  while L <= N do
  begin
    E := 2 * Pi / L;
    for K := 0 to L div 2 - 1 do
    begin
      Angle := K * E * Sign;
      U.Re := Cos(Angle);
      U.Im := Sin(Angle);
      for IFFT := K to N - 1 do
      begin
        if (IFFT mod L) = K then
        begin
          T := CMul(U, Buffer[IFFT + L div 2]);
          Buffer[IFFT + L div 2] := CSub(Buffer[IFFT], T);
          Buffer[IFFT] := CAdd(Buffer[IFFT], T);
        end;
      end;
    end;
    L := L shl 1;
  end;

  // For Inverse-FFT, normalize the result
  if Inverse then
    for IFFT := 0 to N - 1 do
    begin
      Buffer[IFFT].Re := Buffer[IFFT].Re / N;
      Buffer[IFFT].Im := Buffer[IFFT].Im / N;
    end;
  for IFFT := 0 to N - 1 do
    amplitude[IFFT] := sqrt(Buffer[IFFT].Re * Buffer[IFFT].Re + Buffer[IFFT].Im
      * Buffer[IFFT].Im)
end;

end.
