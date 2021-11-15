object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 271
  Width = 283
  object RClient: TRESTClient
    Params = <>
    Left = 88
    Top = 16
  end
  object RReqPolilyne: TRESTRequest
    Client = RClient
    Params = <>
    Response = RRespPolilyne
    SynchronizedEvents = False
    Left = 40
    Top = 64
  end
  object RRespPolilyne: TRESTResponse
    Left = 40
    Top = 112
  end
  object RReqMarca: TRESTRequest
    Params = <>
    Response = RRespMarca
    SynchronizedEvents = False
    Left = 144
    Top = 64
  end
  object RRespMarca: TRESTResponse
    ContentType = 'application/json'
    Left = 144
    Top = 112
  end
end
