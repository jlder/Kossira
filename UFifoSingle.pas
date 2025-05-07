unit UFifoSingle;

interface

uses
  System.SysUtils, Math;

Type
  TFifo = record
    Data: array of Extended;
    Count: Integer;
    Start: Integer;
    Tail: Integer; // Ne pas utiliser le nom de variable end en Pascal;)
  end;

VAr
  FIFO_DEPTH :Integer;

procedure InitFifo(FIFO_DEPTH:Integer;var Fifo: TFifo);
function IsFifoFull(const Fifo: TFifo; FIFO_DEPTH: Integer): Boolean;
function IsFifoEmpty(const Fifo: TFifo): Boolean;
procedure Enqueue(var Fifo: TFifo; const NewPoint: Extended);
procedure Dequeue(var Fifo: TFifo; VAr OldPoint: Extended);

implementation

procedure InitFifo(FIFO_DEPTH:Integer;var Fifo: TFifo);
Var
  i: Integer;
begin
  Setlength(Fifo.Data, FIFO_DEPTH);
  Fifo.Count := 0;
  Fifo.Start := 0;
  Fifo.Tail := 0;
end;

function IsFifoFull(const Fifo: TFifo; FIFO_DEPTH: Integer): Boolean;
begin
  Result := Fifo.Count >= FIFO_DEPTH;
end;

function IsFifoEmpty(const Fifo: TFifo): Boolean;
begin
  Result := Fifo.Count = 0;
end;


procedure Enqueue(var Fifo: TFifo; const NewPoint: Extended);
var
  OldPoint: Extended;
begin
  if IsFifoFull(Fifo, FIFO_DEPTH) then
  begin
    // Remove oldest point from sum
    OldPoint := Fifo.Data[Fifo.Tail];
    // Move tail
    Fifo.Tail := (Fifo.Tail + 1) mod FIFO_DEPTH;
  end
  else
    Inc(Fifo.Count);

  // Add new point
  Fifo.Data[Fifo.Start] := NewPoint;

  // Move Start
  Fifo.Start := (Fifo.Start + 1) mod FIFO_DEPTH;
end;

procedure Dequeue(var Fifo: TFifo; var OldPoint: Extended);
begin
  if IsFifoEmpty(Fifo) then
    raise Exception.Create('Fifo is empty');

  // Get oldest point
  OldPoint := Fifo.Data[Fifo.Tail];


  // Move tail
  Fifo.Tail := (Fifo.Tail + 1) mod FIFO_DEPTH;
  Dec(Fifo.Count);
end;



end.
