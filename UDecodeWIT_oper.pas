unit UDecodeWIT_oper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.IOUtils, UConfAESA_Oper; // ← pour TFile et ReadAllBytes

Const
  MsgLength = 11;

type
  TParamKind = (pkTime, pkAcc, pkGyr, pkAtt);

type
  TTimeMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x50
    Year, Month, Day, Hour, Minute, Second: Byte;
    MS_L, MS_H: Byte;
    Checksum: Byte;
  end;

  TAccMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x51
    Ax_L, Ax_H, Ay_L, Ay_H, Az_L, Az_H: Byte;
    Temp_L, Temp_H: Byte;
    Checksum: Byte;
  end;

  TgyrMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x52
    Gx_L, Gx_H, Gy_L, Gy_H, Gz_L, Gz_H: Byte;
    Volt_L, Volt_H: Byte;
    Checksum: Byte;
  end;

  TAttMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x51
    Rx_L, Rx_H, Py_L, Py_H, Yz_L, Yz_H: Byte;
    Ver_L, Ver_H: Byte;
    Checksum: Byte;
  end;

type
  TBuffer = Array [0 .. MsgLength - 1] of Byte;

type
  TAcc = Record
    Ax, Ay, Az: Extended;
    Temperature: Extended;
    Success: Boolean;
  End;

type
  TGyr = Record
    gx, gy, gz: Extended;
    Voltage: Extended;
    Success: Boolean;
  End;

type
  TAtt = Record
    Roll, Pitch, Yaw: Extended;
    Version: Extended;
    Success: Boolean;
  End;

type
  TTimeRec = record
    TimeMs: Int64;
    Temps, Temps_1: Extended;
    Success_t: Boolean;
  end;

  TSample = record
    Time: TTimeRec;
    Acc: TAcc;
    Gyr: TGyr; // Optionnal
    Att: TAtt; // Optionnal
    ParamsFound: set of TParamKind;
  end;

  TFlightInfo = record
    TaxiStart, TakeOff, TouchDown, TaxiStop: Int64; // in millisecondes
    IdxTaxiStart, IdxTakeOff, IdxTouchDown, IdxTaxiStop: Integer; // indexes in Samples[]
    FlightTime: Extended;
    end;

  TTaxiInfo = record
    TaxiStart, TouchDown, TaxiStop: Int64; // in millisecondes
    IdxTaxiStart, IdxTouchDown, IdxTaxiStop: Integer; // indexes in Samples[]
    TaxiTime: Extended;
  end;

var
  AccMsg: TAccMessage;
  AttMsg: TAttMessage;
  GyrMsg: TgyrMessage;
  Acc: TAcc;
  Gyr: TGyr;
  Att: TAtt;
  Samples: array of TSample;
  DataBytes: TBytes; // données binaires chargées
  Repere: Integer; // 1 for ENU   , -1 for NED
  Swap: Boolean;
  ResultFile: TextFile;

procedure DecodeTime(const Buffer: TBuffer; var Time: TTimeRec);
// procedure DecodeAcc(const Buffer: TBuffer; var Acc: TAcc);
// procedure DecodeGyr(const Buffer: TBuffer; var Gyr: TGyr);
// procedure DecodeAtt(const Buffer: TBuffer; var Att: TAtt);
procedure ParseData(DataBytes: TBytes);

implementation

Var
  Checksum: Byte;

function CalcChecksum(const Buffer: array of Byte; Count: Integer): Byte;
var
  i: Integer;
  Sum: Integer;
begin
  Sum := 0;
  for i := 0 to Count - 1 do
    Sum := Sum + Buffer[i];
  Result := Byte(Sum and $FF);
end;

procedure DecodeTime(const Buffer: TBuffer; var Time: TTimeRec);
Var
  TimeMsg: TTimeMessage;
begin
  if Buffer[1] = $50 then
  begin
    // Message temps
    // Lire le reste (8 octets)
    Time.Success_t := False;
    Move(Buffer, TimeMsg, SizeOf(TimeMsg));
    Checksum := CalcChecksum(Buffer, MsgLength - 1); // 9 first bytes
    if Checksum = TimeMsg.Checksum then
    begin
      // Message temps valide, traiter ici
      Time.TimeMs := (TimeMsg.Hour * 3600 + TimeMsg.Minute * 60 + TimeMsg.Second) * 1000 + SmallInt((TimeMsg.MS_H shl 8) or TimeMsg.MS_L);
      Time.Success_t := True;
    end;
    if Time.Success_t then
    begin
      Time.Temps := Time.TimeMs / 1000.0;
      // Write(ResultFile, temps:10:3, ',', (Temps - Temps_1):8:3, ',');
    end
    else
    begin
      // Writeln(ResultFile, 'Erreur checksum temps');
    end;
  end;

end;

procedure DecodeAcc(const Buffer: TBuffer; var Acc: TAcc);
Var
  ac: Extended;
begin
  Acc.Success := False;
  Move(Buffer, AccMsg, SizeOf(AccMsg));
  Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
  if Checksum = AccMsg.Checksum then
  begin
    // accélération (g)
    Acc.Ax := SmallInt((AccMsg.Ax_H shl 8) or AccMsg.Ax_L) / 2048;
    Acc.Ay := SmallInt((AccMsg.Ay_H shl 8) or AccMsg.Ay_L) / 2048;
    Acc.Az := -SmallInt((AccMsg.Az_H shl 8) or AccMsg.Az_L) / 2048 * Repere;
    if Swap then // Swap Ax<->Az
    begin
      ac := Acc.Ax;
      Acc.Ax := -Acc.Az * Repere;
      Acc.Az := -ac * Repere;
      Swap := True;
    end;

    // Write(ResultFile, Acc.Ax:10:3, ',', Acc.Ay:10:3, ',', Acc.Az:10:3, ',', Acc.Temperature:5:1, ',');
    Acc.Temperature := SmallInt((AccMsg.Temp_H shl 8) or AccMsg.Temp_L) / 100.0;
    if (Acc.Az >= LowG) and (Acc.Az <= HighG) then
      Acc.Success := True; // Checksum is ok and accelerations are inside the valid range
  end
  else
    // Writeln(ResultFile, 'Erreur checksum acc');
end;

procedure DecodeGyr(const Buffer: TBuffer; var Gyr: TGyr);
begin
  Gyr.Success := False;
  Move(Buffer, GyrMsg, SizeOf(AccMsg));
  Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
  if Checksum = GyrMsg.Checksum then
  begin
    // Message accélération valide, traiter ici
    Gyr.gx := SmallInt((GyrMsg.Gx_H shl 8) or GyrMsg.Gx_L) / 16.384;
    Gyr.gy := SmallInt((GyrMsg.Gy_H shl 8) or GyrMsg.Gy_L) / 16.384;
    Gyr.gz := SmallInt((GyrMsg.Gz_H shl 8) or GyrMsg.Gz_L) / 16.384;
    Gyr.Voltage := SmallInt((GyrMsg.Volt_H shl 8) or GyrMsg.Volt_L) / 100.0;
    Gyr.Success := True;
    // Write(ResultFile, Gyr.gx:10:3, ',', Gyr.gy:10:3, ',', Gyr.gz:10:3, ',', Gyr.Voltage:5:2, ',');
  end
  else
    // Writeln(ResultFile, 'Erreur checksum acc');
end;

procedure DecodeAtt(const Buffer: TBuffer; var Att: TAtt);
begin
  Att.Success := False;
  Move(Buffer, AttMsg, SizeOf(AccMsg));
  Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
  if Checksum = AttMsg.Checksum then
  begin
    // attitude (rd)
    Att.Roll := SmallInt((AttMsg.Rx_H shl 8) or AttMsg.Rx_L) / 10430;
    Att.Pitch := SmallInt((AttMsg.Py_H shl 8) or AttMsg.Py_L) / 10430;
    Att.Yaw := SmallInt((AttMsg.Yz_H shl 8) or AttMsg.Yz_L) / 10430;
    Att.Version := SmallInt((AttMsg.Ver_H shl 8) or AttMsg.Ver_L);
    Att.Success := True;
    // Writeln(ResultFile, Att.Roll:10:3, ',', Att.Pitch:10:3, ',', Att.Yaw:10:3, ',', Att.Version:6:0);
  end
  else
    // Writeln(ResultFile, 'Erreur checksum acc');
end;

procedure ParseData(DataBytes: TBytes);
Const
  HeaderLength = 2;
  PID_TIME = 20565; // $5550 temps, header constitué de 0x55 0x50
  PID_ACC = 20821; // $5551 Accélération, header constitué de 0x55 0x51
  PID_GYRO = 21077; // $5552 Gyroscope, header 0x55 0x52
  PID_ATT = 21333; // $5553 Attitude, header 0x55 0x53
Var
  ParamID: Word;
  offset: Integer;
  S: TSample;
  Buf: TBuffer;

  function HasBytes(Count: Integer): Boolean;
  begin
    Result := (offset + Count <= Length(DataBytes));
  end;
  function DecodeHeader(const Buf: array of Byte): Word;
  begin
    // Header sur 2 octets : combine les deux bytes
    Result := Buf[0] + (Buf[1] shl 8);
  end;
  procedure ClearSample(var S: TSample);
  begin
    FillChar(S.Time, SizeOf(S.Time), 0);
    FillChar(S.Acc, SizeOf(S.Acc), 0);
    FillChar(S.Gyr, SizeOf(S.Gyr), 0);
    FillChar(S.Att, SizeOf(S.Att), 0);
    S.ParamsFound := [];
  end;
  function AllParamsForSampleReady(const S: TSample): Boolean;
  begin
    if not(pkTime in S.ParamsFound) then
      Exit(False);
    if not(pkAcc in S.ParamsFound) then
      Exit(False);
    // Trame complète si temps et acc décodés,
    // + tous paramètres optionnels déjà rencontrés
    Result := (pkGyr in S.ParamsFound) or not(pkGyr in S.ParamsFound) and (pkAtt in S.ParamsFound) or not(pkAtt in S.ParamsFound);
  end;

begin
  // DataBytes := TFile.ReadAllBytes(FileName);
  SetLength(Samples, 0);
  offset := 0;
  Swap := False;
  // Synchronisation sur premier header Temps
  while HasBytes(2) do
  begin
    if (DataBytes[offset] = $55) and (DataBytes[offset + 1] = $50) then
      Break
    else
      Inc(offset);
  end;

  // Boucle principale de parsing par record
  ClearSample(S);
  while True do
  begin
    if not(HasBytes(HeaderLength) and HasBytes(MsgLength)) then
      Break;
    Move(DataBytes[offset], Buf[0], MsgLength);
    ParamID := DecodeHeader(Buf); // lit le type/identifiant du bloc à décoder
    // Inc(offset, HeaderLength);

    case ParamID of
      PID_TIME:
        begin
          DecodeTime(Buf, S.Time);
          Include(S.ParamsFound, pkTime);
        end;
      PID_ACC:
        begin
          DecodeAcc(Buf, S.Acc);
          Include(S.ParamsFound, pkAcc);
          if (Offset<10*MsgLength) and Not Swap and (Abs(S.Acc.Ax) > Abs(S.Acc.Az)) then // Swap Ax<->Az
            Swap := True;
        end;
      PID_GYRO:
        begin
          DecodeGyr(Buf, S.Gyr);
          Include(S.ParamsFound, pkGyr);
        end;
      PID_ATT:
        begin
          DecodeAtt(Buf, S.Att);
          Include(S.ParamsFound, pkAtt);
        end;
    else
      ClearSample(S); // ignorer ou traiter les paramètres inconnus
    end;
    Inc(offset, MsgLength);

    // On continue jusqu'à épuisement des DataBytes (le while True break en fin de lecture)

    // Ajoute à Samples[] si tous paramètres attendus sont présents ou selon logique métier
    // (exemple simple : on ajoute à chaque fin de lot)
    if AllParamsForSampleReady(S) then
    begin
      SetLength(Samples, Length(Samples) + 1);
      if High(Samples)>0 then
        begin
        S.Time.Temps_1 := Samples[High(Samples)-1].Time.Temps;
        if S.Time.Temps_1>S.Time.Temps then
          begin
          S.Time.Temps:=S.Time.Temps+86400;
          S.Time.TimeMs:=Round(S.Time.Temps*1000.0);
          S.Time.Temps_1:=86400;
          end;
        end;
      Samples[High(Samples)] := S;
      ClearSample(S);
    end;
  end;

end;

end.
