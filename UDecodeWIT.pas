unit UDecodeWIT;

interface

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
  TBuffer = Array [0 .. 10] of Byte;

type
  TAcc = Record
    Ax, Ay, Az: Extended;
    Temperature: Extended;
    Success_a: Boolean;
  End;

type
  TGyr = Record
    gx, gy, gz: Extended;
    Voltage: Extended;
    Success_g: Boolean;
  End;

type
  TAtt = Record
    Roll, Pitch, Yaw: Extended;
    Version: Extended;
    Success_At: Boolean;
  End;

Var
  AccMsg: TAccMessage;
  AttMsg: TAttMessage;
  GyrMsg: TgyrMessage;
  Temps: Extended;
  Success_t: Boolean;
  Acc: TAcc;
  Gyr: TGyr;
  Att: TAtt;
  Temps_1: Extended;
  ResultFile: TextFile;
  ParseResults: array of Boolean;
  Acknowledge: Boolean;

procedure DecodeTime(Buffer: TBuffer; Var Temps: Extended; Var Success_t: Boolean);
procedure DecodeAcc(Buffer: TBuffer; Var Acc: TAcc);
procedure DecodeGyr(Buffer: TBuffer; Var Gyr: TGyr);
procedure DecodeAtt(Buffer: TBuffer; Var Att: TAtt);

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

procedure DecodeTime(Buffer: TBuffer; Var Temps: Extended; Var Success_t: Boolean);
Var
  TimeMsg: TTimeMessage;

begin
  if Buffer[1] = $50 then
  begin
    // Message temps
    // Lire le reste (8 octets)
    Success_t := False;
    Move(Buffer, TimeMsg, SizeOf(TimeMsg));
    Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
    if Checksum = TimeMsg.Checksum then
    begin
      // Message temps valide, traiter ici
      Temps := TimeMsg.Hour * 3600 + TimeMsg.Minute * 60 + TimeMsg.Second + SmallInt((TimeMsg.MS_H shl 8) or TimeMsg.MS_L) / 1000.0;
      Success_t := True;
    end;
    if Success_t then
    begin
      Write(ResultFile, Temps:10:3, ',', (Temps - Temps_1):8:3, ',');
      Temps_1 := Temps;
      ParseResults[0] := True;
    end
    else
    begin
      Writeln(ResultFile, 'Erreur checksum temps');
      ParseResults[0] := False;
    end;
  end;

end;

procedure DecodeAcc(Buffer: TBuffer; Var Acc: TAcc);
begin
              // Lire le reste (8 octets)
              Move(Buffer, AccMsg, SizeOf(AccMsg));
              Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
              if Checksum = AccMsg.Checksum then
              begin
                // Message accélération valide, traiter ici
                Acc.ax := SmallInt((AccMsg.Ax_H shl 8) or AccMsg.Ax_L) / 2048.0;
                Acc.ay := SmallInt((AccMsg.Ay_H shl 8) or AccMsg.Ay_L) / 2048.0;
                Acc.az := SmallInt((AccMsg.Az_H shl 8) or AccMsg.Az_L) / 2048.0;
                Acc.Temperature := SmallInt((AccMsg.Temp_H shl 8) or AccMsg.Temp_L) / 100.0;
                Write(ResultFile, Acc.ax:10:3, ',', Acc.ay:10:3, ',', Acc.az:10:3, ',', Acc.Temperature:5:1, ',');
                ParseResults[1] := True;
              end
              else
                Writeln(ResultFile, 'Erreur checksum acc');
end;

procedure DecodeGyr(Buffer: TBuffer; Var Gyr: TGyr);
begin
              Move(Buffer, GyrMsg, SizeOf(AccMsg));
              Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
              if Checksum = GyrMsg.Checksum then
              begin
                // Message accélération valide, traiter ici
                Gyr.gx := SmallInt((GyrMsg.Gx_H shl 8) or GyrMsg.Gx_L) / 16.384;
                Gyr.gy := SmallInt((GyrMsg.Gy_H shl 8) or GyrMsg.Gy_L) / 16.384;
                Gyr.gz := SmallInt((GyrMsg.Gz_H shl 8) or GyrMsg.Gz_L) / 16.384;
                Gyr.Voltage := SmallInt((GyrMsg.Volt_H shl 8) or GyrMsg.Volt_L) / 100.0;
                Write(ResultFile, Gyr.gx:10:3, ',', Gyr.gy:10:3, ',', Gyr.gz:10:3, ',', Gyr.Voltage:5:2, ',');
                ParseResults[2] := True;
              end
              else
                Writeln(ResultFile, 'Erreur checksum acc');
end;

procedure DecodeAtt(Buffer: TBuffer; Var Att: TAtt);
begin
              // Lire le reste (8 octets)
              Move(Buffer, AttMsg, SizeOf(AccMsg));
              Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
              if Checksum = AttMsg.Checksum then
              begin
                // Message accélération valide, traiter ici
                Att.Roll := SmallInt((AttMsg.Rx_H shl 8) or AttMsg.Rx_L) / 182.044;
                Att.Pitch := SmallInt((AttMsg.Py_H shl 8) or AttMsg.Py_L) / 182.044;
                Att.Yaw := SmallInt((AttMsg.Yz_H shl 8) or AttMsg.Yz_L) / 182.044;
                Att.Version := SmallInt((AttMsg.Ver_H shl 8) or AttMsg.Ver_L);
                Writeln(ResultFile, Att.Roll:10:3, ',', Att.Pitch:10:3, ',', Att.Yaw:10:3, ',', Att.Version:6:0);
                ParseResults[3] := True;
              end
              else
                Writeln(ResultFile, 'Erreur checksum acc');
end;

end.
