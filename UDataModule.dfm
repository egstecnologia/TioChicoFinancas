object dm: Tdm
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Projetos\Paralelos\TioChicoFinancas\Win32\Debug\DB\t' +
        'iochico.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 64
    Top = 56
  end
end
