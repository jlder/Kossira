unit USort;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  System.Generics.Collections, // Pour TArray<T>
  System.Generics.Defaults;
// Pour TComparer<T> et functions de comparaison génériques

Const
  TailleMessage = 22; // taille d'un message complet (temps+Accel)

type
  TMsgWithTime = record
    TimeValue: Int64; // valeur du temps (pour tri)
    RawMsg: array [0 .. TailleMessage] of Byte;
    // message binaire complet (10 octets par message)
  end;

var
  DataBytes: TBytes; // données binaires chargées
  Buffer: TBytes;
  Offset, TotalLength: Integer;
procedure Sort(Var DataBytes: TBytes);

implementation

type
  TTimeMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x50
    Year, Month, Day, Hour, Minute, Second: Byte;
    MS_L, MS_H: Byte;
    Checksum: Byte;
  end;

function Compare(const A, B: TMsgWithTime): Integer;
begin
  if A.TimeValue < B.TimeValue then
    result := -1
  else if A.TimeValue > B.TimeValue then
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
  Msg: array [0 .. TailleMessage - 1] of Byte; // 10 octets
  TimeMsg, AccMsg: array [0 .. TailleMessage div 2 - 1] of Byte;
  List: array of TMsgWithTime;
  TempsMsg: TMsgWithTime;
  TimeVal: Int64;
  i, PairCount: Integer;
  procedure DecodeTimeFromMsg(const Msg: array of Byte; out TimeMs: Int64);
  Var
    TimeMessage: TTimeMessage;
  begin
    Move(Msg, TimeMessage, SizeOf(TimeMsg));
    TimeMs := (TimeMessage.Hour * 3600 + TimeMessage.Minute * 60 +
      TimeMessage.Second) * 1000 + SmallInt((TimeMessage.MS_H shl 8) or
      TimeMessage.MS_L);
  end;

begin
  Offset := 0; // position dans DataBytes
  SetLength(Buffer, TailleMessage); // tampon de 10 octets
  TotalLength := Length(DataBytes);
  SetLength(List, 0);
  i := 0;
  // Constitution de la liste à trier
  while i <= TotalLength - 22 do
  // Au moins 2 messages (2×11) à lire après la position i
  begin
    // Rechercher le header message temps $55 $50 parmi les 2 premiers octets
    if (DataBytes[i] = $55) and (DataBytes[i + 1] = $50) then
    begin
      // Copie des 11 octets message temps
      Move(DataBytes[i], TimeMsg[0], 11);
      // Copie des 11 octets message accélérations juste après
      Move(DataBytes[i + 11], AccMsg[0], 11);

      // Décoder le temps
      DecodeTimeFromMsg(TimeMsg, TempsMsg.TimeValue);

      // Stocker les 22 octets dans RawMsg (temps + accel)
      Move(TimeMsg[0], TempsMsg.RawMsg[0], 11);
      Move(AccMsg[0], TempsMsg.RawMsg[11], 11);

      // Ajouter dans la liste
      PairCount := Length(List);
      SetLength(List, PairCount + 1);
      List[PairCount] := TempsMsg;

      Inc(i, 22); // avancer après ce couple message
    end
    else
    begin
      // Pas un header temps valide, on avance d’un octet pour resynchroniser
      Inc(i);
    end;
  end;

  // Tri de la liste par temps croissant
  SortByTime(List);
  // Ré-écriture du fichier de données
  for i := 0 to High(List) do
  begin
    Move(List[i].RawMsg[0], DataBytes[i * TailleMessage], TailleMessage);
  end;

end;

end.
