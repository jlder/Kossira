unit UFifo;

interface

uses
  System.SysUtils, Math;

Type
  TPoint3D = record
    TAS, X, Y: Extended;
  end;

  TFifo = record
    Data: array of TPoint3D;
    Count: Integer;
    FSums: array [0 .. 10] of Extended;
    Start: Integer;
    Tail: Integer; // Ne pas utiliser le nom de variable end en Pascal;)
  end;

Const
  Fenetre_min = 10;

procedure InitFifo(FIFO_DEPTH: Integer; var Fifo: TFifo);
function IsFifoFull(const Fifo: TFifo; FIFO_DEPTH: Integer): Boolean;
function IsFifoEmpty(const Fifo: TFifo): Boolean;
procedure ResizeFIFO(var Fifo: TFifo; NewDepth: Integer);
procedure Enqueue(FIFO_DEPTH: Integer; var Fifo: TFifo; const NewPoint: TPoint3D);
procedure Dequeue(FIFO_DEPTH: Integer; var Fifo: TFifo; VAr OldPoint: TPoint3D);
function AddPoint(FIFO_DEPTH: Integer; var Fifo: TFifo; TAS, X, Y: Extended): TPoint3D;

implementation

procedure InitFifo(FIFO_DEPTH: Integer; var Fifo: TFifo);
Var
  i: Integer;
begin
  Setlength(Fifo.Data, FIFO_DEPTH);
  Fifo.Count := 0;
  Fifo.Start := 0;
  Fifo.Tail := 0;
  for i := 0 To 10 do
    Fifo.FSums[i] := 0.0;
end;

function IsFifoFull(const Fifo: TFifo; FIFO_DEPTH: Integer): Boolean;
begin
  Result := Fifo.Count >= FIFO_DEPTH;
end;

function IsFifoEmpty(const Fifo: TFifo): Boolean;
begin
  Result := Fifo.Count = 0;
end;

procedure UpdateSums(var Fifo: TFifo; P: TPoint3D; Add: Boolean);
var
  Factor: Integer;
  tas2, r2: Extended;
begin
  if Add then
    Factor := 1
  else
    Factor := -1;

  Fifo.FSums[0] := Fifo.FSums[0] + Factor * P.X;
  Fifo.FSums[1] := Fifo.FSums[1] + Factor * P.Y;
  Fifo.FSums[2] := Fifo.FSums[2] + Factor * Sqr(P.X);
  Fifo.FSums[3] := Fifo.FSums[3] + Factor * Sqr(P.Y);
  Fifo.FSums[4] := Fifo.FSums[4] + Factor * P.X * P.Y;
  r2 := Sqr(P.X) + Sqr(P.Y);
  Fifo.FSums[5] := Fifo.FSums[5] + Factor * r2;
  Fifo.FSums[6] := Fifo.FSums[6] + Factor * P.X * r2;
  Fifo.FSums[7] := Fifo.FSums[7] + Factor * P.Y * r2;

  tas2 := P.TAS * P.TAS;
  Fifo.FSums[8] := Fifo.FSums[8] + Factor * tas2;
  Fifo.FSums[9] := Fifo.FSums[9] + Factor * P.X * tas2;
  Fifo.FSums[10] := Fifo.FSums[10] + Factor * P.Y * tas2;
end;

procedure Enqueue(FIFO_DEPTH: Integer; var Fifo: TFifo; const NewPoint: TPoint3D);
var
  OldPoint: TPoint3D;
begin
  if IsFifoFull(Fifo, FIFO_DEPTH) then
  begin
    // Remove oldest point from sum
    OldPoint := Fifo.Data[Fifo.Tail];
    UpdateSums(Fifo, OldPoint, False);
    // Move tail
    Fifo.Tail := (Fifo.Tail + 1) mod FIFO_DEPTH;
  end
  else
    Inc(Fifo.Count);

  // Add new point
  Fifo.Data[Fifo.Start] := NewPoint;
  UpdateSums(Fifo, NewPoint, True);

  // Move Start
  Fifo.Start := (Fifo.Start + 1) mod FIFO_DEPTH;
end;

procedure Dequeue(FIFO_DEPTH: Integer; var Fifo: TFifo; var OldPoint: TPoint3D);
begin
  if IsFifoEmpty(Fifo) then
    raise Exception.Create('Fifo is empty');

  // Get oldest point
  OldPoint := Fifo.Data[Fifo.Tail];

  // Update sums
  UpdateSums(Fifo, OldPoint, False);

  // Move tail
  Fifo.Tail := (Fifo.Tail + 1) mod FIFO_DEPTH;
  Dec(Fifo.Count);
end;

procedure ResizeFIFO(var Fifo: TFifo; NewDepth: Integer);
var
  i, j, OldIndex: Integer;
begin
  Setlength(Fifo.Data, NewDepth);
  // On va ré-initialiser complètement la Fifo car c'est plus sûr que de chercher à être astucieux
  // Mise à zéro de toutes les sommes
  for j := 0 to 10 do
    Fifo.FSums[j] := 0;

  // Copier les données dans le nouveau tableau
  for i := 0 to Min(Fifo.Count, NewDepth) - 1 do
  begin
    OldIndex := (Fifo.Start + i) mod Length(Fifo.Data);
    Fifo.Data[i] := Fifo.Data[OldIndex];
    UpdateSums(Fifo, Fifo.Data[i], True);
  end;

  // Mettre à jour les pointeurs dela FIFO
  Fifo.Start := 0;
  Fifo.Tail := Min(Fifo.Count, NewDepth) mod Min(Fifo.Count, NewDepth);
  Fifo.Count := Min(Fifo.Count, NewDepth);
end;

function AddPoint(FIFO_DEPTH: Integer; var Fifo: TFifo; TAS, X, Y: Extended): TPoint3D;
var
  N: Integer;
  MeanX, MeanY, Sxx, Syy, Sxy, Szx, Szy: Extended;
  A: array [0 .. 1, 0 .. 1] of Extended;
  B: array [0 .. 1] of Extended;
  det: Extended;
  P: TPoint3D;

begin
  P.X := X;
  P.Y := Y;
  P.TAS := TAS;

  Enqueue(FIFO_DEPTH, Fifo, P);
  Result.X := 0.0;
  Result.Y := 0.0;
  Result.TAS := 0.0;

  if Fifo.Count >=Fenetre_min then
  begin
    N := Fifo.Count;
    MeanX := Fifo.FSums[0] / N;
    MeanY := Fifo.FSums[1] / N;

    Sxx := Fifo.FSums[2] - N * Sqr(MeanX);
    Syy := Fifo.FSums[3] - N * Sqr(MeanY);
    Sxy := Fifo.FSums[4] - N * MeanX * MeanY;
    Szx := 0.5 * ((Fifo.FSums[6] - Fifo.FSums[9]) - MeanX * (Fifo.FSums[5] - Fifo.FSums[8]));
    Szy := 0.5 * ((Fifo.FSums[7] - Fifo.FSums[10]) - MeanY * (Fifo.FSums[5] - Fifo.FSums[8]));

    A[0, 0] := Sxx;
    A[0, 1] := Sxy;
    A[1, 0] := Sxy;
    A[1, 1] := Syy;

    B[0] := Szx;
    B[1] := Szy;

    det := A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0];
    if det <> 0.0 then
    begin
      Result.X := (B[0] * A[1, 1] - B[1] * A[0, 1]) / det;
      Result.Y := (A[0, 0] * B[1] - A[1, 0] * B[0]) / det;
      Result.TAS := det;
    end;
  end;
end;

end.
