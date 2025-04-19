unit FilterButterworth;

interface

Uses Math;

type
  Table = Array [0 .. 2] of Extended;

type
  TButterworthCoefficients = record
    a: array [1 .. 4] of Double; // Coefficients pour l'entrée (b coefficients)
    b: array [0 .. 4] of Double; // Coefficients pour la sortie (a coefficients)
  end;

type
  TFilterButterworth = class
  private
    // Tampons pour le filtre
    FxBuffer: array [0 .. 2] of Extended;
    FyBuffer: array [0 .. 2] of Extended;
    FxBuffer4: array [0 .. 4] of Extended;
    FyBuffer4: array [0 .. 4] of Extended;

    // Dernière valeur filtrée pour la dérivée
    FLastFiltered: Extended;

    // Coefficients du filtre Butterworth
    // const a: array[0..2] of Double = (1.0, -1.5610180758007182, 0.6413515380575631);
    // const b: array[0..2] of Double = (0.020083365564211235, 0.04016673112842247, 0.020083365564211235);
  public
    constructor Create;
    // Filtrage passe-bas
    function LowPassFilter(NewSample: Extended): Extended;
    function LowPassFilter4(NewSample: Extended): Extended;
    // Processus complet : filtrage
    procedure ProcessData(dt, NewSample: Extended; out FilteredValue: Extended);
    procedure DesignFilter(dt,fc: Extended; Var a, b: Table);
    function CalculateButterworthCoefficients(dt, fc: Extended): TButterworthCoefficients;
  end;


Var
  a, b: Table;
  ButterworthCoefficients: TButterworthCoefficients;

implementation

function TFilterButterworth.CalculateButterworthCoefficients(dt, fc: Extended): TButterworthCoefficients;
var
  omega_c: Extended; // Fréquence de coupure normalisée
  tan_wc: Extended; // Tangente de la fréquence
  q: array [1 .. 2] of Extended; // Poles de l'ordre 4 Butterworth
  k1, k2: Extended; // Facteurs intermédiaires
  norm: Extended; // Normalisation
begin
  // Fréquence de coupure normalisée
  omega_c := 2.0 * Pi * fc * dt;
  tan_wc := tan(omega_c / 2.0);

  // Poles de l'ordre 4 Butterworth
  q[1] := sqrt(2.0);
  q[2] := 0;

  // Facteurs intermédiaires
  k1 := tan_wc * tan_wc;
  k2 := sqrt(2.0) * tan_wc;

  // Coefficients pour la fonction de transfert
  norm := 1 / (1 + k2 + k1);

  Result.b[0] := k1 * norm;
  Result.b[1] := 2.0 * Result.b[0];
  Result.b[2] := Result.b[0];
  Result.a[1] := 2.0 * (k1 - 1) * norm;
  Result.a[2] := (1.0 - k2 + k1) * norm;
  Result.a[3] := 0.0;
  Result.a[4] := 0.0;
end;

{ TFilterDerivative }
procedure TFilterButterworth.DesignFilter(dt,fc: Extended; Var a, b: Table);
var
  K: Extended;
  norm: Extended;
begin
  // Calcul des coefficients pour un filtre passe-bas Butterworth d'ordre 2
  K := tan(Pi * fc * dt);
  norm := 1 / (1 + sqrt(2) * K + K * K);
  // Coefficients du numérateur (b)
  b[0] := K * K * norm;
  b[1] := 2 * b[0];
  b[2] := b[0];
  // Coefficients du dénominateur (a)
  a[0] := 1; // a0 est toujours 1
  a[1] := 2 * (K * K - 1) * norm;
  a[2] := (1 - sqrt(2) * K + K * K) * norm;

  ButterworthCoefficients := CalculateButterworthCoefficients(dt, fc);
end;

constructor TFilterButterworth.Create;
begin
  // Initialisation des tampons à zéro
  FillChar(FxBuffer, SizeOf(FxBuffer), 0);
  FillChar(FyBuffer, SizeOf(FyBuffer), 0);
  FLastFiltered := 0.0;
end;

function TFilterButterworth.LowPassFilter(NewSample: Extended): Extended;
var
  i: Integer;
  YNew: Extended;
begin
  // Décale les tampons
  for i := High(FxBuffer) downto 1 do
  begin
    FxBuffer[i] := FxBuffer[i - 1];
    FyBuffer[i] := FyBuffer[i - 1];
  end;

  // Ajoute la nouvelle entrée
  FxBuffer[0] := NewSample;

  // Calcul de la sortie du filtre
  YNew := 0.0;
  for i := 0 to High(b) do
  begin
    YNew := YNew + b[i] * FxBuffer[i];
    if i > 0 then
      YNew := YNew - a[i] * FyBuffer[i];
  end;

  // Stocke la nouvelle sortie
  FyBuffer[0] := YNew;

  Result := YNew;
end;

function TFilterButterworth.LowPassFilter4(NewSample: Extended): Extended;
var
  i: Integer;
  YNew: Extended;
begin
  // Décale les tampons
  for i := High(FxBuffer) downto 1 do
  begin
    FxBuffer4[i] := FxBuffer4[i - 1];
    FyBuffer4[i] := FyBuffer4[i - 1];
  end;

  // Ajoute la nouvelle entrée
  FxBuffer4[0] := NewSample;

  // Calcul de la sortie du filtre
  YNew := 0.0;
  for i := 0 to High(b) do
  begin
    YNew := YNew + ButterworthCoefficients.b[i] * FxBuffer4[i];
    if i > 0 then
      YNew := YNew - ButterworthCoefficients.a[i] * FyBuffer4[i];
  end;

  // Stocke la nouvelle sortie
  FyBuffer4[0] := YNew;

  Result := YNew;
end;


procedure TFilterButterworth.ProcessData(dt, NewSample: Extended; out FilteredValue: Extended);
begin
  // Applique le filtre passe-bas
  FilteredValue := LowPassFilter(NewSample);
end;

end.
