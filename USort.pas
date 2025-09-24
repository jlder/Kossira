unit USort;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  System.Generics.Collections, // Pour TArray<T>
  System.Generics.Defaults,// Pour TComparer<T> et functions de comparaison génériques
  UConfAESA,UDecodeWIT_opt;

type
  TMsgWithTime = record
    Time: INT64; // valeur du temps (pour tri)
    RawMsg: array of Byte;
    // message binaire complet (10 octets par message)
  end;

var
  TotalLength: Integer;
procedure Sort(Var DataBytes: TBytes);

implementation

function Compare(const A, B: TMsgWithTime): Integer;
begin
  if A.Time < B.Time then
    result := -1
  else if A.Time > B.Time then
    result := 1
  else
    result := 0;
end;

procedure SortByTime(var List: array of TMsgWithTime);
begin
  TArray.Sort<TMsgWithTime>(List, TComparer<TMsgWithTime>.Construct(Compare));
end;

procedure Sort(Var DataBytes: TBytes);
var
  TimeMsg: TBuffer;
  List: array of TMsgWithTime;
  TempsMsg: TMsgWithTime;
  TimeRec:TTimeRec;
  i, PairCount: Integer;
  Nb_Messages,TailleMessages:Integer;

begin
  Nb_Messages:=2;
  TailleMessages:=MsgLength*Nb_Messages;
  SetLength(TempsMsg.RawMsg,TailleMessages);
  TotalLength := Length(DataBytes);
  SetLength(List, 0);
  i := 0;
  // Constitution de la liste à trier
  while i <= TotalLength - TailleMessages do
  // Au moins 2 messages (2×11) à lire après la position i
  begin
    // Rechercher le header message temps $55 $50 parmi les 2 premiers octets
    if (DataBytes[i] = $55) and (DataBytes[i + 1] = $50) then
    begin
      // Copie des TailleMessages bytes message
      Move(DataBytes[i], TempsMsg.RawMsg[0], TailleMessages);
      // Copie des MsgLength bytes message temps
      Move(TempsMsg.RawMsg[0], TimeMsg[0], MsgLength);

      // Time parsing
      DecodeTime(TimeMsg, TimeRec);

      TempsMsg.Time:=TimeRec.TimeMs;
      // Add to the list
      PairCount := Length(List);
      SetLength(List, PairCount + 1);
      List[PairCount] := TempsMsg;

      Inc(i, TailleMessages); // shift to TailleMessages bytes in DataBytes
    end
    else
    begin
      // The header is not recognized, go ahead to next byte
      Inc(i);
    end;
  end;

  // Sort the list for increasing time
  SortByTime(List);
  // Save the list to the new DataBytes
  for i := 0 to High(List) do
  begin
    Move(List[i].RawMsg[0], DataBytes[i * MsgLength], MsgLength);
  end;

end;

end.
