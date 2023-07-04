unit uFrmPrin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExComCtrls, JvProgressBar, Vcl.WinXCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, JvBaseDlg, JvBrowseFolder, JvDialogs, Vcl.Mask, JvExMask, JvToolEdit, System.Generics.Collections,
  System.StrUtils, System.JSON,REST.Types, System.DateUtils, System.Types, ShellAPI, System.IOUtils, FireDAC.Phys.IB,
  FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Phys.IBDef, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Dapt, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, System.Zip, System.UITypes,
  Winapi.WinSvc, Data.Win.ADODB, System.ImageList, Vcl.ImgList, JclSysUtils, dprocess;

 const
   cgDirBarra = {$IFDEF linux}'/'{$ELSE}'\'{$ENDIF};

type
  EErro = class(Exception);

type
  TuPrincipal = class(TForm)
    pnlCentral: TPanel;
    rbGbak: TRadioButton;
    rbGfix: TRadioButton;
    cbbSenha: TComboBox;
    edtSenha: TEdit;
    btnIniciar: TButton;
    lblSenha: TLabel;
    pnlRadio: TPanel;
    pnl1: TPanel;
    con: TFDConnection;
    edtVersaoBanco: TEdit;
    lblVersaoBanco: TLabel;
    edtCaminhoBancoFDB: TEdit;
    edtCaminhoBancoFBK: TEdit;
    lblCaminhoFDB: TLabel;
    lblCaminhoFBK: TLabel;
    lblMensagem: TLabel;
    pnlBarra: TPanel;
    lblNomeBanco: TLabel;
    mmoErro: TMemo;
    pb: TProgressBar;
    cbbBanco: TComboBox;
    pnlcheckbox: TPanel;
    chkparte1: TCheckBox;
    chkparte2: TCheckBox;
    chkTodos: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cbbSenhaChange(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure cbbBancoChange(Sender: TObject);
    procedure rbGbakClick(Sender: TObject);
    procedure rbGfixClick(Sender: TObject);
    procedure chkTodosClick(Sender: TObject);
    procedure FormResize(Sender: TObject);


  private
    fArquivoOrigem : String;
    fArquivoDestino : String;
    fDiretorioTrabalho : String;
    fNomeBancoFDB : String;
    fBancoFBK : String;
    fSenha : String;
    fBancoFDBNovo : String;

    procedure Nome;
    procedure ExecutarGbakParte1;
    procedure ExecutarGbakParte2;
    function Senha: String;
    function GetFirebirdVersion(databasePath: string): string;
    procedure ExecutarGfixParte1;
    procedure ExecutarGfixParte2;
    function GetDiretorioExe: String;
    function GetCaminhoArquivo: String;
    function PostBancoNovoFBK: String;
    procedure CopiarBanco;
    function CriarBackup: String;
    function DeleteBanco: String;
    procedure ShutdownBanco;
    procedure DateBaseOnline;
    function GetNomeBancoComExtensao(const cPath: string): TStringList;
    procedure CarregaNomeBancoComboBox(const cPath: string; cComboBox: TComboBox);
    procedure LimparCheckBox;
    procedure IniciarEscolha;
    procedure Validacoes;
    procedure Checkbox;

  end;


var
  uPrincipal: TuPrincipal;

implementation

{$R *.dfm}

procedure TuPrincipal.ExecutarGbakParte1;
var
  mProcess : TProcess;
  mCmdLine : string;
  mResposta, mTotalRead : Integer;
  mOutput : TStringList;
  mBuffer : array[0..255] of AnsiChar;
  mBytesRead : DWORD;
begin
  mmoErro.Lines.Add('Iniciando 1ª parte do Gbak...');
  mCmdLine := 'gbak -b -l -user SYSDBA -PASS ' + fSenha + ' ' + fNomeBancoFDB + ' ' + fBancoFBK +'.FBK';

  mProcess := TProcess.Create(nil);
  try
    mProcess.CommandLine := mCmdLine;
    mProcess.CurrentDirectory := fDiretorioTrabalho;
    mProcess.Options := [poUsePipes, poNoConsole];

    mProcess.Execute;

    mOutput := TStringList.Create;
    try
      mTotalRead := 0;
      repeat
        if mProcess.Running then
          begin
            mBytesRead := mProcess.Output.Read(mBuffer, SizeOf(mBuffer));
            if mBytesRead > 0 then
              begin
                mBuffer[mBytesRead] := #0;
                mOutput.Add(mBuffer);
                mmoErro.Lines.Add(mBuffer);
              end;

            mBytesRead := mProcess.Stderr.Read(mBuffer, SizeOf(mBuffer));
            if mBytesRead > 0 then
              begin
               mBuffer[mBytesRead] := #0;
               mOutput.Add(mBuffer);
               mmoErro.Lines.Add(mBuffer);
              end;
          end;

        mTotalRead  := mTotalRead + mBytesRead;
        Pb.Position := mTotalRead;
      until
        (mBytesRead = 0) and (not mProcess.Running);

      if mProcess.ExitStatus <> 0 then
      begin
        mOutput.SaveToFile('gbak.txt');
        ShowMessage('Erro no Gbak!');
        Exit;
      end;
    finally
     mOutput.Free;
    end;
  finally
    mProcess.Free;
  end;

  mmoErro.Lines.Add('1ª parte do Gbak concluido...');
end;

procedure TuPrincipal.ExecutarGbakParte2;
var
  mProcess : TProcess;
  mCmdLine, mBancoFBKDeletar: string;
  mResposta, mTotalRead : Integer;
  mOutput : TStringList;
  mBuffer : array[0..255] of AnsiChar;
  mBytesRead : DWORD;
begin
  mmoErro.Lines.Add('Iniciando 2ª parte do Gbak...');

  if (chkparte2.Checked) then
    begin
      fBancoFBK := cbbBanco.Text;

      if (ExtractFileName(fBancoFDBNovo) = ('1'+ fBancoFDBNovo)) then
        raise EErro.Create('Já tem o banco 1'+ fBancoFDBNovo);
    end;

  mCmdLine := 'gbak -c -r -user SYSDBA -PASS ' + fSenha + ' ' + fBancoFBK + ' 1' + fBancoFDBNovo;

  mProcess := TProcess.Create(nil);
  try
    mProcess.CommandLine := mCmdLine;
    mProcess.CurrentDirectory := fDiretorioTrabalho;
    mProcess.Options := [poUsePipes, poNoConsole];

    mProcess.Execute;

    mOutput := TStringList.Create;
    try
      mTotalRead := 0;
      repeat
        if mProcess.Running then
          begin
            mBytesRead := mProcess.Output.Read(mBuffer, SizeOf(mBuffer));
            if mBytesRead > 0 then
              begin
                mBuffer[mBytesRead] := #0;
                mOutput.Add(mBuffer);
                mmoErro.Lines.Add(mBuffer);
              end;

            mBytesRead := mProcess.Stderr.Read(mBuffer, SizeOf(mBuffer));
            if mBytesRead > 0 then
              begin
               mBuffer[mBytesRead] := #0;
               mOutput.Add(mBuffer);
               mmoErro.Lines.Add(mBuffer);
              end;
          end;

        mTotalRead  := mTotalRead + mBytesRead;
        Pb.Position := mTotalRead;
      until
        (mBytesRead = 0) and (not mProcess.Running);

      if mProcess.ExitStatus <> 0 then
      begin
        mOutput.SaveToFile('gbak.txt');
        ShowMessage('Erro no Gbak!');
        Exit;
      end;
    finally
     mOutput.Free;
    end;
  finally
    mProcess.Free;
  end;

  mmoErro.Lines.Add('Concluido GBAK');

  mResposta := MessageDlg('Deseja excluir o Banco FBK criado?', mtConfirmation, [mbYes, mbNo], 0);
   if (mResposta = 6) then
     begin
       mBancoFBKDeletar := DeleteBanco;
       mmoErro.Lines.Add('Excluido o Banco FBK.');
     end
   else
     Exit;
end;

procedure TuPrincipal.ExecutarGfixParte1;
var
  mProcess : TProcess;
  mCmdLine : string;
  mResposta : Integer;
  mOutput : TStringList;
  mBuffer : array[0..255] of AnsiChar;
  mBytesRead : DWORD;
begin
  mmoErro.Lines.Add('Iniciando 1ª parte do Gfix...');
  mCmdLine := 'gfix -v -full ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  mProcess := TProcess.Create(nil);
  try
    mProcess.CommandLine      := mCmdLine;
    mProcess.CurrentDirectory := fDiretorioTrabalho;
    mProcess.Options          := [poUsePipes, poNoConsole];

    mProcess.Execute;

    mOutput := TStringList.Create;
    try
      repeat
        mBytesRead := mProcess.Output.Read(mBuffer, SizeOf(mBuffer));
        if mBytesRead > 0 then
        begin
          mBuffer[mBytesRead] := #0;
          mOutput.Add(mBuffer);
          mmoErro.Lines.Add(mBuffer);
        end;

        mBytesRead := mProcess.Stderr.Read(mBuffer, SizeOf(mBuffer));
        if mBytesRead > 0 then
        begin
          mBuffer[mBytesRead] := #0;
          mOutput.Add(mBuffer);
          mmoErro.Lines.Add(mBuffer);
        end;
      until (mBytesRead = 0) and not (mProcess.Running);

      if mProcess.ExitStatus <> 0 then
        begin
          mOutput.SaveToFile('gfix.txt');
          ShowMessage('Erro no Gfix!');
          Exit;
        end;
    finally
      mOutput.Free;
    end;
  finally
    mProcess.Free;
  end;

  mmoErro.Lines.Add('1ª parte do Gfix concluido...');
end;

procedure TuPrincipal.ExecutarGfixParte2;
var
  mProcess : TProcess;
  mCmdLine : string;
  mOutput : TStringList;
  mBuffer : array[0..255] of AnsiChar;
  mBytesRead : DWORD;
begin
  mmoErro.Lines.Add('Iniciando 2ª parte do Gfix...');
  mCmdLine := 'gfix -m -i ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  mProcess := TProcess.Create(nil);
  try
    mProcess.CommandLine := mCmdLine;
    mProcess.CurrentDirectory := fDiretorioTrabalho;
    mProcess.Options := [poUsePipes, poNoConsole];

    mProcess.Execute;

    mOutput := TStringList.Create;
    try
      repeat
        mBytesRead := mProcess.Output.Read(mBuffer, SizeOf(mBuffer));
        if mBytesRead > 0 then
        begin
          mBuffer[mBytesRead] := #0;
          mOutput.Add(mBuffer);
          mmoErro.Lines.Add(mBuffer);
        end;

        mBytesRead := mProcess.Stderr.Read(mBuffer, SizeOf(mBuffer));
        if mBytesRead > 0 then
        begin
          mBuffer[mBytesRead] := #0;
          mOutput.Add(mBuffer);
          mmoErro.Lines.Add(mBuffer);
        end;
      until (mBytesRead = 0) and not (mProcess.Running);

      if mProcess.ExitStatus <> 0 then
        begin
          mOutput.SaveToFile('gfix.txt');
          ShowMessage('Erro no Gfix!');
          Exit;
        end;
    finally
      mOutput.Free;
    end;
  finally
    mProcess.Free;
  end;
  mmoErro.Lines.Add('Concluido');
end;

procedure TuPrincipal.IniciarEscolha;
begin
  if (rbGbak.Checked) then
    begin
      if  chkTodos.Checked then
        begin
          ExecutarGbakParte1;
          ExecutarGbakParte2;
        end

      else if chkparte1.Checked then
        begin
          ExecutarGbakParte1;
        end

      else if chkparte2.Checked then
        begin
           ExecutarGbakParte2;
        end;
    end
  else if (rbGfix.Checked) then
    begin
      if chkTodos.Checked then
        begin
          ExecutarGfixParte1;
          ExecutarGfixParte2;
        end

      else if chkparte1.Checked then
        begin
          ExecutarGfixParte1;
        end

      else if chkparte2.Checked then
        begin
          ExecutarGfixParte2;
        end;
    end;
end;

procedure TuPrincipal.btnIniciarClick(Sender: TObject);
begin
  cbbBanco.Enabled := False;

  try
    Validacoes;
    CopiarBanco;
    IniciarEscolha;
  except
    on E: EErro do
    begin
      ShowMessage(E.Message);
      cbbBanco.Enabled := True;
      Exit;
    end;
  end;
end;

procedure TuPrincipal.Validacoes;
var
  mResposta : Integer;
begin
  fNomeBancoFDB  := cbbBanco.Text;
  fBancoFBK      := PostBancoNovoFBK;
  fBancoFDBNovo  := ChangeFileExt(cbbBanco.Text, '.FDB');

  if cbbBanco.Text = 'Não Encontrado' then
  begin
    raise EErro.Create('Não possui nenhum banco de dados nesta pasta.');
  end;

  if (not chkparte1.Checked) and (not chkparte2.Checked) and (not chkTodos.Checked) then
    begin
      raise EErro.Create('Você precisa escolher um procedimento para iniciar');
    end;

  mResposta := MessageDlg('Você já parou o Server?', mtConfirmation, [mbYes, mbNo], 0);
  if (mResposta = 7) then
    raise EErro.Create('Interrompa o Server');
  {$Region 'Gbak'}
  if (rbGbak.Checked) then
    begin
      if (chkparte1.Checked) and (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FBK') then
        raise EErro.Create('O banco .FBK não é valido para método marcado')

      else if (chkparte2.Checked) and (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FDB') then
        raise EErro.Create('O banco FDB não é valido para método marcado');

      if (FileExists(fBancoFBK)) and (not chkparte2.Checked) then
        raise EErro.Create('Já possui na pasta o ' + fBancoFBK)

      else if (FileExists('1'+ fNomeBancoFDB)) and (not chkparte2.Checked) then
        raise EErro.Create('Já possui na pasta o 1' + fNomeBancoFDB);

      if (chkparte2.Checked) and (FileExists(fBancoFDBNovo)) then
        raise EErro.Create('Já possui na pasta o ' + fBancoFDBNovo);

      if ((chkTodos.Checked) or (chkparte1.Checked)) and (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FBK') then
       begin
         chkparte1.Checked := False;
         chkTodos.Checked  := False;
         chkparte2.Checked := True;
       end;

    end;
  {$EndRegion}
  {$Region 'Gfix'}
  if (rbGfix.Checked) then
    begin
      if UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FBK' then
        begin
          raise EErro.Create('Não é possivel realizar um Gfix em banco .FBK');

        end;

     if (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FBK') then
       raise EErro.Create('O banco .FBK não é valido para método marcado')
    end;
  {$EndRegion}
end;

Procedure TuPrincipal.CopiarBanco;
var
  mCaminhoBDOrigem, mCaminhoBDDestino, mArquivoDestino, mExtensao : String;
  ZipFile : TZipFile;
begin
  mArquivoDestino := GetDiretorioExe + 'Backup\'+ FormatDateTime('dd-mm-yyyy', Date) + 'Hotel_BKP.ZIP';
  mExtensao := UpperCase(ExtractFileExt(cbbBanco.Text));

  if mExtensao = '.FBK' then
    Exit;

  if (FileExists(mArquivoDestino)) then
    Exit;

  if Assigned(mmoErro) then
    mmoErro.Lines.Add('Iniciando cópia do banco de dados');

  mCaminhoBDOrigem  := GetCaminhoArquivo + cbbBanco.Text;
  mCaminhoBDDestino := CriarBackup;

  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(mArquivoDestino, zmWrite);
    ZipFile.Add(mCaminhoBDOrigem);
    if Assigned(mmoErro) then
      mmoErro.Lines.Add('Concluído o Backup do Banco');
  finally
    ZipFile.Free;
  end;
end;

procedure TuPrincipal.cbbBancoChange(Sender: TObject);
var
  mCaminhoBanco : String;
begin
  mCaminhoBanco           := GetCaminhoArquivo + cbbBanco.Text;
  edtCaminhoBancoFBK.Text := PostBancoNovoFBK;
  edtCaminhoBancoFDB.Text := mCaminhoBanco;
end;

procedure TuPrincipal.cbbSenhaChange(Sender: TObject);
begin
  if (cbbSenha.ItemIndex = 2) then
    edtSenha.Visible       := True
  else edtSenha.Visible    := False;
end;

procedure TuPrincipal.Checkbox;
begin
  if (chkTodos.Checked) then
    begin
      chkparte1.Checked := False;
      chkparte1.Enabled := False;
      chkparte2.Checked := False;
      chkparte2.Enabled := False;
    end
  else
    begin
      chkparte1.Enabled := True;
      chkparte2.Enabled := True;
    end
end;

procedure TuPrincipal.chkTodosClick(Sender: TObject);
begin
  Checkbox;
end;

procedure TuPrincipal.FormCreate(Sender: TObject);
var
  mCaminhoBanco, mCaminhobancoFBK, mDiretorioTrabalho : String;
begin
  CarregaNomeBancoComboBox(mDiretorioTrabalho, cbbBanco);
  Checkbox;
  Nome;

  mCaminhoBanco      := GetCaminhoArquivo + cbbBanco.Text;
  mCaminhobancoFBK   := PostBancoNovoFBK;
  mDiretorioTrabalho := GetDiretorioExe;

  edtCaminhoBancoFDB.Text := mCaminhoBanco;
  edtCaminhoBancoFBK.Text := mCaminhoBancoFBK;
  edtVersaoBanco.text     := GetFirebirdVersion(mCaminhoBanco);

  cbbBanco.OnChange := cbbBancoChange;
end;

procedure TuPrincipal.FormResize(Sender: TObject);
begin
  Constraints.MinWidth  := 670;
  Constraints.MaxWidth  := 670;
  Constraints.MinHeight := 483;
  Constraints.MaxHeight := 483;
end;

procedure TuPrincipal.Nome;
begin
  lblCaminhoFDB.Caption  := 'Caminho do Banco FDB';
  lblCaminhoFBK.Caption  := 'Banco FBK';
  lblSenha.Caption       := 'Senha do banco';
  btnIniciar.Caption     := 'Iniciar';
  lblVersaoBanco.Caption := 'Versão FB';

  if rbGbak.Checked then
    begin
      chkparte1.Caption := 'Gbak - B - L';
      chkparte2.Caption := 'Gbak - C - R' ;
    end
  else
    begin
      chkparte1.Caption := 'Gfix - V - F';
      chkparte2.Caption := 'Gfix - M - I';
    end;
end;

function TuPrincipal.GetCaminhoArquivo: String;
begin
  Result := GetDiretorioExe;
  ForceDirectories(ExtractFilePath(Result));
end;

function TuPrincipal.Senha: String;
begin
   case cbbSenha.ItemIndex of
     0 : Result := '1';
     1 : Result := 'masterkey';
     2 : Result := edtSenha.Text;
   end;
end;

function TuPrincipal.GetFirebirdVersion(databasePath: string): string;
var
  mCon : TFDConnection;
  mQuery : TFDQuery;
  mCaminhoBanco : String;
begin
  fDiretorioTrabalho := GetDiretorioExe;
  fNomeBancoFDB      := cbbBanco.Text;
  fSenha             := Senha;
  mCaminhoBanco      := GetCaminhoArquivo;

  if fNomeBancoFDB = 'Não Encontrado' then
    exit;

  //DateBaseOnline;

  mCon := TFDConnection.Create(nil);
  mQuery := TFDQuery.Create(nil);
  try
    mCon.DriverName := 'FB';
    mCon.Params.Add('Database='+ mCaminhoBanco + fNomeBancoFDB);
    mCon.Params.Add('User_Name=SYSDBA');
    mCon.Params.Add('Password='+ fSenha);
    mCon.Open;

    mQuery.Connection := mCon;
    mQuery.SQL.Text := 'SELECT rdb$get_context(''SYSTEM'', ''ENGINE_VERSION'') FROM rdb$database';
    mQuery.Open;

    Result := mQuery.Fields[0].AsString;
  finally
    mQuery.Free;
    mCon.Free;
  end;
end;

function TuPrincipal.GetDiretorioExe: String;
begin
  {$IFDEF linux}
  Result := System.SysUtils.GetCurrentDir;
  {$ELSE}
  Result:= ExtractFilePath(Application.ExeName);
  {$ENDIF}
  if (RightStr(Result, 1) <> cgDirBarra) then
    Result:= Result + cgDirBarra;
end;

function TuPrincipal.PostBancoNovoFBK: String;
begin
  Result := ChangeFileExt(cbbBanco.Text, '');;
end;

procedure TuPrincipal.rbGbakClick(Sender: TObject);
begin
  Nome;
end;

procedure TuPrincipal.rbGfixClick(Sender: TObject);
begin
  Nome;
end;

function TuPrincipal.CriarBackup: String;
begin
  Result := GetDiretorioExe + 'Backup';

  if not (DirectoryExists(Result)) then
    CreateDir(Result);
end;

function TuPrincipal.DeleteBanco: String;
begin
  Result := GetDiretorioExe + 'Hotel.FBK';

  if FileExists(Result) then
    DeleteFile(Result);
end;

procedure TuPrincipal.ShutdownBanco;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  mCmdLine : string;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  mCmdLine := 'gfix -shut full -force 0 ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ChDir(PChar(fDiretorioTrabalho));

  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  if not CreateProcess(nil, PChar(mCmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      RaiseLastOSError;
      mmoErro.Lines.Add('Erro');
      Exit;
    end;

  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  mmoErro.Lines.Add('Shutdown realizado!');
end;

procedure TuPrincipal.DateBaseOnline;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  mCmdLine : string;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  mCmdLine := 'gfix -online multi ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ChDir(PChar(fDiretorioTrabalho));

  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  if not CreateProcess(nil, PChar(mCmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      RaiseLastOSError;
      mmoErro.Lines.Add('Erro');
      Exit;
    end;

  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  mmoErro.Lines.Add('Database Online!');
end;

function TuPrincipal.GetNomeBancoComExtensao(const cPath: string): TStringList;
var
  mProcura : TSearchRec;
  mNomeBanco: string;
begin
  Result := TStringList.Create;
  try
    if FindFirst (cPath + '*.FDB', faAnyFile, mProcura) = 0 then
      begin
        repeat
          mNomeBanco := ExtractFileName (mProcura.Name);
          Result.Add (mNomeBanco);
        until FindNext (mProcura) <> 0;
      end;

    if FindFirst(cPath + '*.FBK', faAnyFile, mProcura) = 0 then
      begin
        repeat
          mNomeBanco := ExtractFileName(mProcura.Name);
          Result.Add(mNomeBanco);
        until FindNext(mProcura) <> 0;
      end;
    FindClose (mProcura);
  except
    Result.Free;
    raise;
  end;
end;

procedure TuPrincipal.CarregaNomeBancoComboBox(const cPath: string; cComboBox: TComboBox);
var
  mNomeBanco : TStringList;
  mI : Integer;
begin
  mNomeBanco := GetNomeBancoComExtensao(cPath);
  try
    cbbBanco.Items.Clear;
    for mI := 0 to mNomeBanco.Count - 1 do
    begin
      cbbBanco.Items.Add (mNomeBanco[mI]);
    end;

    if cbbBanco.Items.Count > 0 then
      cbbBanco.ItemIndex := 0
    else
      cbbBanco.Text := 'Não Encontrado';
  finally
    mNomeBanco.Free;
  end;
end;

Procedure TuPrincipal.LimparCheckBox;
begin
  chkparte1.Checked := False;
  chkparte2.Checked := False;
  chkTodos.Checked  := False;
end;


end.

