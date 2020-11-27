object HTTPHeadersPropertyEditorForm: THTTPHeadersPropertyEditorForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Edit headers...'
  ClientHeight = 347
  ClientWidth = 465
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    465
    347)
  PixelsPerInch = 96
  TextHeight = 13
  object bvlFooter: TBevel
    Left = 0
    Top = 312
    Width = 465
    Height = 2
    Align = alBottom
    ExplicitLeft = 192
    ExplicitTop = 136
    ExplicitWidth = 50
  end
  object lblValue: TLabel
    Left = 192
    Top = 232
    Width = 32
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&Value:'
    FocusControl = EdtValue
  end
  object lblKey: TLabel
    Left = 8
    Top = 232
    Width = 20
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '&Key:'
    FocusControl = EdtKey
  end
  object lblHeaders: TLabel
    Left = 8
    Top = 8
    Width = 45
    Height = 13
    Caption = '&Headers:'
    FocusControl = lvHeaders
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 314
    Width = 465
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object btnOK: TButton
      AlignWithMargins = True
      Left = 305
      Top = 5
      Width = 75
      Height = 23
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      AlignWithMargins = True
      Left = 385
      Top = 5
      Width = 75
      Height = 23
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object lvHeaders: TListView
    Left = 8
    Top = 24
    Width = 449
    Height = 193
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Key'
        Width = 180
      end
      item
        Caption = 'Value'
        Width = 240
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object BtnClear: TButton
    Left = 384
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'C&lear'
    TabOrder = 2
  end
  object BtnDelete: TButton
    Left = 88
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Delete'
    TabOrder = 3
  end
  object BtnAdd: TButton
    Left = 8
    Top = 280
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Add'
    TabOrder = 4
  end
  object EdtValue: TEdit
    Left = 192
    Top = 248
    Width = 265
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 5
  end
  object EdtKey: TEdit
    Left = 8
    Top = 248
    Width = 177
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 6
  end
end
