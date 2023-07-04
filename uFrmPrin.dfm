object uPrincipal: TuPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Corre'#231#227'o de Banco de Dados'
  ClientHeight = 454
  ClientWidth = 664
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  DockSite = True
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PrintScale = poPrintToFit
  Scaled = False
  ScreenSnap = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlCentral: TPanel
    Left = 0
    Top = 0
    Width = 664
    Height = 454
    Align = alClient
    TabOrder = 0
    object pnl1: TPanel
      Left = 1
      Top = 1
      Width = 662
      Height = 414
      Align = alClient
      TabOrder = 0
      DesignSize = (
        662
        414)
      object lblSenha: TLabel
        Left = 512
        Top = 81
        Width = 64
        Height = 13
        Caption = 'lblBancoInicio'
      end
      object lblVersaoBanco: TLabel
        Left = 7
        Top = 81
        Width = 72
        Height = 13
        Anchors = [akLeft]
        Caption = 'lblVersaoBanco'
      end
      object lblCaminhoFDB: TLabel
        Left = 7
        Top = 137
        Width = 58
        Height = 13
        Caption = 'lblBancoFDB'
      end
      object lblCaminhoFBK: TLabel
        Left = 7
        Top = 189
        Width = 57
        Height = 13
        Caption = 'lblBancoFBK'
      end
      object lblNomeBanco: TLabel
        Left = 188
        Top = 81
        Width = 59
        Height = 13
        AutoSize = False
        Caption = 'Nome Banco'
      end
      object pnlRadio: TPanel
        Left = 1
        Top = 1
        Width = 660
        Height = 41
        Align = alTop
        TabOrder = 0
        object rbGbak: TRadioButton
          Left = 134
          Top = 10
          Width = 113
          Height = 19
          Caption = 'Gbak'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          TabStop = True
          OnClick = rbGbakClick
        end
        object rbGfix: TRadioButton
          Left = 399
          Top = 10
          Width = 113
          Height = 20
          Caption = 'Gfix'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = rbGfixClick
        end
      end
      object edtSenha: TEdit
        Left = 512
        Top = 129
        Width = 129
        Height = 21
        Anchors = [akRight]
        AutoSize = False
        TabOrder = 5
        Visible = False
      end
      object cbbSenha: TComboBox
        Left = 512
        Top = 101
        Width = 129
        Height = 22
        Style = csOwnerDrawVariable
        Anchors = [akRight]
        ItemIndex = 0
        TabOrder = 4
        Text = 'Senha Silbeck'
        OnChange = cbbSenhaChange
        Items.Strings = (
          'Senha Silbeck'
          'Senha MasterKey'
          'Outras')
      end
      object btnIniciar: TButton
        Left = 528
        Top = 199
        Width = 113
        Height = 33
        Anchors = [akRight]
        Caption = 'btnIniciar'
        TabOrder = 7
        OnClick = btnIniciarClick
      end
      object edtCaminhoBancoFDB: TEdit
        Left = 4
        Top = 156
        Width = 504
        Height = 21
        Anchors = [akLeft]
        AutoSize = False
        Enabled = False
        TabOrder = 6
      end
      object edtCaminhoBancoFBK: TEdit
        Left = 4
        Top = 208
        Width = 509
        Height = 21
        Anchors = [akLeft]
        AutoSize = False
        Enabled = False
        TabOrder = 8
      end
      object edtVersaoBanco: TEdit
        Left = 7
        Top = 100
        Width = 72
        Height = 21
        Anchors = [akLeft]
        Enabled = False
        TabOrder = 2
      end
      object mmoErro: TMemo
        Left = 1
        Top = 238
        Width = 660
        Height = 175
        Align = alBottom
        BevelKind = bkFlat
        Color = clMenuText
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Lines.Strings = (
          '')
        ParentFont = False
        TabOrder = 9
      end
      object cbbBanco: TComboBox
        Left = 188
        Top = 100
        Width = 201
        Height = 21
        TabOrder = 3
        Text = 'cbbBanco'
        OnChange = cbbBancoChange
      end
      object pnlcheckbox: TPanel
        Left = 1
        Top = 42
        Width = 660
        Height = 33
        Align = alTop
        TabOrder = 1
        object chkparte1: TCheckBox
          Left = 178
          Top = 6
          Width = 97
          Height = 17
          TabOrder = 1
        end
        object chkparte2: TCheckBox
          Left = 388
          Top = 6
          Width = 97
          Height = 17
          TabOrder = 2
        end
        object chkTodos: TCheckBox
          Left = 25
          Top = 6
          Width = 53
          Height = 17
          Caption = 'Todos'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = chkTodosClick
        end
      end
    end
    object pnlBarra: TPanel
      Left = 1
      Top = 415
      Width = 662
      Height = 38
      Align = alBottom
      TabOrder = 1
      object lblMensagem: TLabel
        Left = 1
        Top = 1
        Width = 660
        Height = 13
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 138
        ExplicitTop = 27
        ExplicitWidth = 313
      end
      object pb: TProgressBar
        Left = 1
        Top = 20
        Width = 660
        Height = 17
        Align = alBottom
        TabOrder = 0
      end
    end
  end
  object con: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    Left = 498
    Top = 52
  end
end
