unit LibUtil;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExComCtrls, JvProgressBar, Vcl.WinXCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, JvBaseDlg, JvBrowseFolder, JvDialogs, Vcl.Mask, JvExMask, JvToolEdit, System.Generics.Collections,
  System.StrUtils, System.JSON,REST.Types, System.DateUtils, System.Types, ShellAPI, System.IOUtils, FireDAC.Phys.IB,
  FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Phys.IBDef, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Dapt, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, System.Zip, System.UITypes,
  Winapi.WinSvc, Data.Win.ADODB, System.ImageList, Vcl.ImgList, JclSysUtils, dprocess, System.Diagnostics;


function ExecutarCMD(const mComandline: string; const mWorkDirectory: string; Memo: TMemo): Boolean;


type
  EErro = class(Exception);

type
  TPromptComand = Class

  private

  public

  End;

type
  TProcessThread = class(TThread)
  private
    FCommand: string;
    FWorkDirectory: string;
    FOutput: TStrings;
    FLogFileName: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const ACommand, AWorkDirectory: string; AOutput: TStrings);
    destructor Destroy; override;
  end;

implementation

{ PromptComand }


function ExecutarCMD(const mComandline: string; const mWorkDirectory: string; Memo: TMemo): Boolean;
var
  mComand : TStringList;
  mSaida : TStringList;
  mLinha : string;
  mProcesso : TProcess;
  mLeitura : TStreamReader;
begin
  Result := False;

  mProcesso    := TProcess.Create(nil);
  mSaida       := TStringList.Create;
  mComand      := TStringList.Create;
  mLeitura     := nil;
  try
    mComand.Delimiter := ' ';
    mComand.DelimitedText := mComandline;

    mProcesso.Executable := mComand[0];
    mComand.Delete(0);
    mProcesso.Parameters.Assign(mComand);
    mProcesso.Options := [poUsePipes, poNoConsole, poStderrToOutPut];
    mProcesso.CurrentDirectory := mWorkDirectory;
    mProcesso.Execute;

    mLeitura := TStreamReader.Create(mProcesso.Output);
    while not mLeitura.EndOfStream do
    begin
      mLinha := mLeitura.ReadLine;
      mSaida.Add(mLinha);
    end;

    Memo.Lines.Assign(mSaida);
    Result := True;

    if mProcesso.ExitStatus <> 0 then
    begin
      mSaida.SaveToFile('LogErro.txt');
      raise Exception.Create('Erro ao executar o comando');
    end;

  finally
    mComand.Free;
    mSaida.Free;
    mProcesso.Free;
    mLeitura.Free;
  end;
end;



{ TProcessThread }

constructor TProcessThread.Create(const ACommand, AWorkDirectory: string; AOutput: TStrings);
begin
  inherited Create(True);
  FCommand := ACommand;
  FWorkDirectory := AWorkDirectory;
  FOutput := AOutput;
  FLogFileName := 'LogErro.txt'; // Altere para o nome do arquivo de log desejado, se necessário
end;


destructor TProcessThread.Destroy;
begin

  inherited;
end;

procedure TProcessThread.Execute;
var
  Process: TProcess;
  OutputLines: TStringList;
  Line: string;
begin
  Process := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    Process.Executable := FCommand;
    Process.Parameters.Delimiter := ' ';
    Process.Parameters.DelimitedText := FCommand;
    Process.Options := [poUsePipes, poNoConsole, poStderrToOutPut];
    Process.CurrentDirectory := FWorkDirectory;
    Process.Execute;

    while Process.Running do
    begin
      Sleep(10); // Adicione um pequeno atraso para evitar uso excessivo da CPU no loop
    end;

    Line := Process.Output.ReadLine;
    while Line <> '' do
    begin
      OutputLines.Add(Line);
      Line := Process.Output.ReadLine;
    end;

    FOutput.AddStrings(OutputLines);

    if Process.ExitStatus <> 0 then
    begin
      OutputLines.SaveToFile(FLogFileName);
      // Se você deseja lançar uma exceção aqui, pode usar Synchronize para mostrá-la na thread principal:
      // Synchronize(
      //   procedure
      //   begin
      //     raise Exception.Create('Erro ao executar o comando');
      //   end
      // );
    end;

  finally
    Process.Free;
    OutputLines.Free;
  end;
end;

end.

end.
