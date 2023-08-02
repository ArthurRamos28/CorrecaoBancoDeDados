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
  Winapi.WinSvc, Data.Win.ADODB, System.ImageList, Vcl.ImgList, JclSysUtils, dprocess, LibUtil;

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
    btnDataBaseOnline: TButton;
    btnShutDown: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cbbSenhaChange(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure cbbBancoChange(Sender: TObject);
    procedure rbGbakClick(Sender: TObject);
    procedure rbGfixClick(Sender: TObject);
    procedure chkTodosClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDataBaseOnlineClick(Sender: TObject);
    procedure btnShutDownClick(Sender: TObject);


  private
    fArquivoOrigem : String;
    fArquivoDestino : String;
    fDiretorioTrabalho : String;
    fNomeBancoFDB : String;
    fBancoFBK : String;
    fSenha : String;
    fBancoFDBNovo : String;
    fCaminhoBanco : String;

    procedure Name;
    procedure ExecuteGbakOne;
    procedure ExecuteGbakTwo;
    function Senha: String;
    procedure ExecuteGfixOne;
    procedure ExecuteGfixTwo;
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
    procedure Botoes;
    procedure AtualizaComboBanco;
    function GetFileSize(const FileName: string): Int64;

  end;


var
  uPrincipal: TuPrincipal;

implementation



{$R *.dfm}

procedure TuPrincipal.ExecuteGbakOne;
var
  mCmdLine : string;
begin
  mmoErro.Lines.Add('Iniciando 1ª parte do Gbak...');
  mCmdLine := 'gbak -b -l -user SYSDBA -PASS ' + fSenha + ' ' + fNomeBancoFDB + ' ' + fBancoFBK;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

  mmoErro.Lines.Add('1ª parte do Gbak concluido...');
end;

procedure TuPrincipal.ExecuteGbakTwo;
var
  mBancoFBKDeletar, mCmdLine : string;
  mResposta : Integer;
begin
  mmoErro.Lines.Add('Iniciando 2ª parte do Gbak...');

  mCmdLine := 'gbak -c -r -user SYSDBA -PASS ' + fSenha + ' ' + fBancoFBK + ' 1' + fBancoFDBNovo;

  if chkparte2.Checked then
    begin
      fBancoFBK := cbbBanco.Text;
    end;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

  mmoErro.Lines.Add('Concluído GBAK');

  mResposta := MessageDlg('Deseja excluir o Banco FBK criado?', mtConfirmation, [mbYes, mbNo], 0);
    if mResposta = 6 then
      begin
        mBancoFBKDeletar := DeleteBanco;
        mmoErro.Lines.Add('Excluído o Banco FBK.');
      end
    else
      Exit;
end;

procedure TuPrincipal.ExecuteGfixOne;
var
  mCmdLine : string;
  mOutput : TStringList;
  mPrompt : TPromptComand;
begin
  mmoErro.Lines.Add('Iniciando 1ª parte do Gfix...');

  mCmdLine := 'gfix -v -full ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

  mmoErro.Lines.Add('1ª parte do Gfix concluido...');
end;

procedure TuPrincipal.ExecuteGfixTwo;
var
  mCmdLine : string;
  mOutput : TStringList;
begin
  mmoErro.Lines.Add('Iniciando 2ª parte do Gfix...');

  mCmdLine := 'gfix -m -i ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

  mmoErro.Lines.Add('Concluido');
end;

procedure TuPrincipal.IniciarEscolha;
begin
  if (rbGbak.Checked) then
    begin
      if  chkTodos.Checked then
        begin
          ExecuteGbakOne;
          Sleep(30000);
          ExecuteGbakTwo;
        end

      else if chkparte1.Checked then
        begin
          ExecuteGbakOne;
        end

      else if chkparte2.Checked then
        begin
          ExecuteGbakTwo;
        end;
    end
  else if (rbGfix.Checked) then
    begin
      if chkTodos.Checked then
        begin
          ExecuteGfixOne;
          ExecuteGfixTwo;
        end

      else if chkparte1.Checked then
        begin
          ExecuteGfixOne;
        end

      else if chkparte2.Checked then
        begin
          ExecuteGfixTwo;
        end;
    end;
end;

procedure TuPrincipal.btnDataBaseOnlineClick(Sender: TObject);
begin
  if (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FDB') then
    DateBaseOnline;
end;

procedure TuPrincipal.btnIniciarClick(Sender: TObject);
begin
  mmoErro.Lines.Clear;
  Validacoes;
  CopiarBanco;
  IniciarEscolha;
  Botoes;
end;

procedure TuPrincipal.btnShutDownClick(Sender: TObject);
begin
  if (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FDB') then
    ShutdownBanco;
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
      if ((chkparte1.Checked) or (chkTodos.Checked)) and (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FBK') then
        raise EErro.Create('O banco .FBK não é valido para método marcado');

      if (chkparte2.Checked) and (not chkparte1.Checked) and (UpperCase(ExtractFileExt(cbbBanco.Text)) = '.FDB') then
        raise EErro.Create('O banco FDB não é valido para método marcado');

      if  ((chkparte1.Checked) or (chkTodos.Checked)) and (FileExists(fBancoFBK)) then
        raise EErro.Create('Já possui na pasta o ' + fBancoFBK);

      if (chkparte2.Checked) and (FileExists('1'+ fBancoFDBNovo)) then
        raise EErro.Create('Já possui na pasta o 1' + fBancoFDBNovo);

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

function TuPrincipal.GetFileSize(const FileName: string): Int64;
var
  FileInfo: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FileInfo) then
    RaiseLastOSError;
  Int64Rec(Result).Lo := FileInfo.nFileSizeLow;
  Int64Rec(Result).Hi := FileInfo.nFileSizeHigh;
end;

procedure TuPrincipal.CopiarBanco;
var
  mCaminhoBDOrigem, mCaminhoBDDestino, mArquivoDestino, mExtensao: String;
  ZipFile: TZipFile;
  FileSize: Int64;
const
  MaxFileSizeToZip: Int64 = Int64(2) * Int64(1024) * Int64(1024) * Int64(1024); // 2 GB em bytes
begin
  mArquivoDestino := GetDiretorioExe + 'Backup\' + FormatDateTime('dd-mm-yyyy', Date) + 'Hotel_BKP.ZIP';
  mExtensao := UpperCase(ExtractFileExt(cbbBanco.Text));

  if mExtensao = '.FBK' then
    Exit;

  if FileExists(mArquivoDestino) then
    Exit;

  mmoErro.Lines.Add('Iniciando cópia do banco');
  mCaminhoBDOrigem := GetCaminhoArquivo + cbbBanco.Text;
  mCaminhoBDDestino := CriarBackup;

  // Verificar o tamanho do arquivo
  FileSize := GetFileSize(mCaminhoBDOrigem);
  if FileSize > MaxFileSizeToZip then
  begin
    // O arquivo é maior que 2 GB, não fazer o zipeamento
    if Assigned(mmoErro) then
      CopyFile(PChar(mCaminhoBDOrigem), PChar(GetDiretorioExe + 'Backup\' + FormatDateTime('dd-mm-yyyy', Date) + 'Hotel_BKP.fdb'), False);
      mmoErro.Lines.Add('Arquivo maior que 2 GB. Não será zipeado.');
    Exit;
  end;

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
begin
  edtCaminhoBancoFBK.Text := PostBancoNovoFBK;
  edtCaminhoBancoFDB.Text := GetCaminhoArquivo + cbbBanco.Text;
  fNomeBancoFDB := cbbBanco.Text;
end;

procedure TuPrincipal.cbbSenhaChange(Sender: TObject);
begin
  if (cbbSenha.ItemIndex = 2) then
    edtSenha.Visible       := True
  else edtSenha.Visible    := False;

  fSenha := Senha;
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
  AtualizaComboBanco;
end;

procedure TuPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
var
  ProcessInfo : TProcessInformation;
begin
  TerminateProcess(ProcessInfo.hProcess, 0);
end;

procedure TuPrincipal.FormCreate(Sender: TObject);
begin
  CarregaNomeBancoComboBox(fDiretorioTrabalho, cbbBanco);
  Checkbox;
  Name;
  fSenha             := Senha;
  fDiretorioTrabalho := GetDiretorioExe;
  fCaminhoBanco      := GetCaminhoArquivo + cbbBanco.Text;
  fNomeBancoFDB      := cbbBanco.Text;

  edtCaminhoBancoFDB.Text := fCaminhoBanco;
  edtCaminhoBancoFBK.Text := PostBancoNovoFBK;


  AtualizaComboBanco;
end;

procedure TuPrincipal.FormResize(Sender: TObject);
begin
  Constraints.MinWidth  := 670;
  Constraints.MaxWidth  := 670;
  Constraints.MinHeight := 483;
  Constraints.MaxHeight := 483;
end;

procedure TuPrincipal.Name;
begin
  lblCaminhoFDB.Caption  := 'Caminho do Banco FDB';
  lblCaminhoFBK.Caption  := 'Banco FBK';
  lblSenha.Caption       := 'Senha do banco';
  btnIniciar.Caption     := 'Iniciar';

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
     0 : Result := '123';
     1 : Result := 'masterkey';
     2 : Result := edtSenha.Text;
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
  Result := ChangeFileExt(cbbBanco.Text, '.FBK');;
end;

procedure TuPrincipal.rbGbakClick(Sender: TObject);
begin
  Name;
end;

procedure TuPrincipal.rbGfixClick(Sender: TObject);
begin
  Name;
end;

function TuPrincipal.CriarBackup: String;
begin
  Result := GetDiretorioExe + 'Backup';

  if not (DirectoryExists(Result)) then
    CreateDir(Result);
end;

function TuPrincipal.DeleteBanco: String;
begin
  Result := GetDiretorioExe + fBancoFBK;

  if FileExists(Result) then
    DeleteFile(Result);
end;

procedure TuPrincipal.ShutdownBanco;
var
  mCmdLine : string;
  mOutput : TStringList;
  mPrompt : TPromptComand;
begin
  mCmdLine := 'gfix -shut full -force 0 ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

  mmoErro.Lines.Add('Shutdown realizado!');
end;

procedure TuPrincipal.DateBaseOnline;
 var
  mCmdLine : string;
  mOutput : TStringList;
  mPrompt : TPromptComand;
begin
  mCmdLine := 'gfix -online multi ' + fNomeBancoFDB + ' -user SYSDBA -PASS ' + fSenha;

  ExecutarCMD(mCmdLine, fDiretorioTrabalho, mmoErro);

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
    FindClose(mProcura);
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

Procedure TuPrincipal.Botoes;
begin
  cbbSenha.Enabled   := True;
  cbbBanco.Enabled   := True;
  AtualizaComboBanco;
end;

procedure TuPrincipal.AtualizaComboBanco;
begin
  cbbBanco.OnChange := cbbBancoChange;
end;

end.

