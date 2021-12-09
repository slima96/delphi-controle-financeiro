object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 286
  Width = 335
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\dev\Documents\Projeto mobile\Fontes\DB\banco.d' +
        'b'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 40
  end
end
