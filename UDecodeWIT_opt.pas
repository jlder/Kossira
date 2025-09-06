unit UDecodeWIT_opt;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.IOUtils,UConfAESA; // ← pour TFile et ReadAllBytes

Const
  MsgLength = 11;

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
    Temps,Temps_1:Extended;
    Success_t: Boolean;
  end;

  TSample = record
    Time: TTimeRec;
    Acc: TAcc;
    Gyr: TGyr; // Optionnal
    Att: TAtt; // Optionnal
  end;

  TFlightInfo = record
    TaxiStart, TakeOff, TouchDown, TaxiStop: Int64; // in millisecondes
    IdxTaxiStart, IdxTakeOff, IdxTouchDown, IdxTaxiStop: Integer; // indexes in Samples[]
    FlightTime: Extended;
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

  ResultFile: TextFile;

procedure DecodeTime(const Buffer: TBuffer; var Time: TTimeRec);
procedure DecodeAcc(const Buffer: TBuffer; var Acc: TAcc);
procedure DecodeGyr(const Buffer: TBuffer; var Gyr: TGyr);
procedure DecodeAtt(const Buffer: TBuffer; var Att: TAtt);
procedure ParseData(DataBytes: TBytes; GyroPresent, AttPresent: Boolean);

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
      Time.Temps_1 := Time.Temps;
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
begin
    Acc.Success:=False;
  Move(Buffer, AccMsg, SizeOf(AccMsg));
  Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
  if Checksum = AccMsg.Checksum then
  begin
    // accélération (g)
    Acc.Ax := SmallInt((AccMsg.Ax_H shl 8) or AccMsg.Ax_L) / 2048;
    Acc.Ay := SmallInt((AccMsg.Ay_H shl 8) or AccMsg.Ay_L) / 2048;
    Acc.Az := -SmallInt((AccMsg.Az_H shl 8) or AccMsg.Az_L) / 2048 * Repere;
    Acc.Temperature := SmallInt((AccMsg.Temp_H shl 8) or AccMsg.Temp_L) / 100.0;
    if (Acc.Az >= LowG) and (Acc.Az <= HighG) then Acc.Success:=True;//Checksum is ok and accelerations are inside the valid range
    // Write(ResultFile, Acc.Ax:10:3, ',', Acc.Ay:10:3, ',', Acc.Az:10:3, ',', Acc.Temperature:5:1, ',');
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

procedure ParseData(DataBytes: TBytes; GyroPresent, AttPresent: Boolean);
var
  offset: Integer;
  S: TSample;
  Buf: TBuffer;

  function HasBytes(Count: Integer): Boolean;
  begin
    Result := (offset + Count <= Length(DataBytes));
  end;

begin
  // DataBytes := TFile.ReadAllBytes(FileName);
  SetLength(Samples, 0);
  offset := 0;

  // Synchronisation sur premier header Temps
  while HasBytes(2) do
  begin
    if (DataBytes[offset] = $55) and (DataBytes[offset + 1] = $50) then
      Break
    else
      Inc(offset);
  end;

  // Boucle principale de parsing par record
  while True do
  begin
    // Bloc Temps
    if not HasBytes(MsgLength) then
      Break;
    Move(DataBytes[offset], Buf[0], MsgLength);
    DecodeTime(Buf, S.Time);
    Inc(offset, MsgLength);

    // Bloc Acc
    if not HasBytes(MsgLength) then
      Break;
    Move(DataBytes[offset], Buf[0], MsgLength);
    DecodeAcc(Buf, S.Acc);
    Inc(offset, MsgLength);

    // Gyro optionnal
    if GyroPresent then
    begin
      if not HasBytes(MsgLength) then
        Break;
      Move(DataBytes[offset], Buf[0], MsgLength);
      DecodeGyr(Buf, S.Gyr);
      Inc(offset, MsgLength);
    end
    else
      FillChar(S.Gyr, SizeOf(S.Gyr), 0);

    // Attitude optionnal
    if AttPresent then
    begin
      if not HasBytes(MsgLength) then
        Break;
      Move(DataBytes[offset], Buf[0], MsgLength);
      DecodeAtt(Buf, S.Att);
      Inc(offset, MsgLength);
    end
    else
      FillChar(S.Att, SizeOf(S.Att), 0);

    // Add to Samples[]
    SetLength(Samples, Length(Samples) + 1);
    Samples[High(Samples)] := S;
  end;
end;

end.
