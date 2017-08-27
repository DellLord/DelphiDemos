unit MainDataModuleUnit;

interface

uses System.SysUtils,
  System.Classes,
  Data.DBXFirebird,
  Data.DB,
  Data.SqlExpr,
{$IF CompilerVersion <= 27}
  Data.DBXJSON,
{$ELSE}
  System.JSON,
{$ENDIF}
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  WinesBO, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait;

type
  TWineCellarDataModule = class(TDataModule)
    Connection: TFDConnection;
    qryWines: TFDQuery;
    updWines: TFDUpdateSQL;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure ConnectionBeforeConnect(Sender: TObject);

  public
    function GetWineById(id: Integer): TJSONObject;
    function FindWines(Search: string): TJSONArray;
    procedure AddWine(AWine: TWine);
    procedure UpdateWine(AWine: TWine);
    procedure DeleteWine(id: Integer);
  end;

implementation

{$R *.dfm}

uses System.StrUtils,
  Data.DBXCommon,
  ObjectsMappers;

{ TCellarSM }

procedure TWineCellarDataModule.AddWine(AWine: TWine);
begin
  Mapper.ObjectToFDParameters(updWines.Commands[arInsert].Params, AWine, 'NEW_');
  updWines.Commands[arInsert].Execute;
end;

procedure TWineCellarDataModule.DeleteWine(id: Integer);
begin
  updWines.Commands[arDelete].ParamByName('OLD_ID').AsInteger := id;
  updWines.Commands[arDelete].Execute;
end;

procedure TWineCellarDataModule.ConnectionBeforeConnect(Sender: TObject);
begin
  Connection.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + '..\..\WINES.FDB';
end;

function TWineCellarDataModule.FindWines(Search: string): TJSONArray;
begin
  if Search.IsEmpty then
    qryWines.Open('SELECT * FROM wine')
  else
    qryWines.Open('SELECT * FROM wine where NAME CONTAINING ?', [Search]);
  Result := qryWines.AsJSONArray;
end;

function TWineCellarDataModule.GetWineById(id: Integer): TJSONObject;
begin
  qryWines.Open('SELECT * FROM wine where id = ?', [id]);
  Result := qryWines.AsJSONObject;
end;

procedure TWineCellarDataModule.UpdateWine(AWine: TWine);
begin
  Mapper.ObjectToFDParameters(updWines.Commands[arUpdate].Params, AWine, 'NEW_');
  updWines.Commands[arUpdate].Params.ParamByName('OLD_ID').AsInteger := AWine.id;
  updWines.Commands[arUpdate].Execute;
end;

end.
