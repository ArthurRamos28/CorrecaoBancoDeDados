program CorrecaoBancoDados;

uses
  Vcl.Forms,
  uFrmPrin in 'uFrmPrin.pas' {uPrincipal},
  dprocess in 'dprocess.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TuPrincipal, uPrincipal);
  Application.Run;
end.
