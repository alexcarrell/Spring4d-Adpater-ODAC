(* ORMTests - uModels.pas
* Created: 2012.05.15 15:54:01
* Copyright (c) 2012, Linas Naginionis
* Contacts: lnaginionis@gmail.com or support@soundvibe.net or linas@vikarina.lt
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

unit TestEntities;

interface


uses
  Spring.Persistence.Mapping.Attributes, Generics.Collections
  , Graphics, Spring.Collections, Classes, Spring;


const
  CustomerColumnCount = 10;

type
  TProduct = class;
  TCustomer_Orders = class;

  TCustomerType = (ctOneTime, ctReturning, ctBusinessClass, ctPrimary);

  [Entity]
  [Table('Customers')]
  [Sequence('SEQ_CUST', 1, 1)]
  TCustomer = class
  private
    [UniqueConstraint]
    [Column('CUSTID', [cpRequired, {cpDontInsert,} cpPrimaryKey, cpNotNull], 0, 0, 0, 'Primary Key')]
    [AutoGenerated]
    FId: Integer;

    FProducts: Lazy<IList<TProduct>>;

    //[Column('AVATAR', [], 50, 0, 0, 'Customers avatar')]
   // FAvatar: Lazy<TPicture>;

    [Column('CUSTSTREAM', [], 50, 0, 0, 'Customers stream')]
    FStream: Lazy<TMemoryStream>;

    [Column('AVATAR', [], 50, 0, 0, 'Customers avatar')]
    FAvatarNullable: Lazy<Nullable<TPicture>>;
    FStrings: TStrings;
    procedure SetAvatarLazy(const Value: Nullable<TPicture>);
  public
    FName: string;
    FAge: Integer;
    FHeight: Double;
    FLastEdited: TDateTime;
    FEmail: string;
    FMiddleName: Nullable<string>;

    [OneToMany(False, [ckCascadeAll])]
    FOrders: Lazy<IList<TCustomer_Orders>>;

    FCustomerType: TCustomerType;
    function GetProducts: IList<TProduct>;
    function GetAvatar: TPicture;
    procedure SetAvatar(const Value: TPicture);
    function GetOrders: IList<TCustomer_Orders>;
    function GetOrdersIntf: IList<TCustomer_Orders>;
    function GetAvatarLazy: Nullable<TPicture>;
    function GetCustStream: TMemoryStream;
    procedure SetCustStream(const Value: TMemoryStream);
    procedure SetProducts(const Value: IList<TProduct>);
    procedure SetOrdersIntf(const Value: IList<TCustomer_Orders>);
  public
    constructor Create;
    destructor Destroy; override;
  public
    property ID: Integer read FId;
    [Column('CUSTNAME', [], 50, 0, 0, 'Customers name')]
    property Name: string read FName write FName;
    [Column('CUSTAGE', [], 0, 0, 0, 'Customers age')]
    property Age: Integer read FAge write FAge;
    [Column('CUSTHEIGHT', [], 0, 5, 2, 'Customers height')]
    property Height: Double read FHeight write FHeight;
    //[Column('LastEdited', [], 0, 0, 0, 'Last Edited')]
    [Column]
    property LastEdited: TDateTime read FLastEdited write FLastEdited;
    [Column('EMAIL', [], 50, 0, 0, 'E-mail address')]
    property EMail: string read FEmail write FEmail;
    [Column('MIDDLENAME', [], 50, 0, 0, 'Middle name')]
    property MiddleName: Nullable<string> read FMiddleName write FMiddleName;
    [Column('CUSTTYPE', [cpHidden], 0, 0, 0, 'Customers type')]
    property CustomerType: TCustomerType read FCustomerType write FCustomerType;
    property Products: IList<TProduct> read GetProducts write SetProducts;
    property Avatar: TPicture read GetAvatar write SetAvatar;
    property AvatarLazy: Nullable<TPicture> read GetAvatarLazy write SetAvatarLazy;
    property Orders: IList<TCustomer_Orders> read GetOrders;
    property OrdersIntf: IList<TCustomer_Orders> read GetOrdersIntf write SetOrdersIntf;
    property StreamLazy: Lazy<TMemoryStream> read FStream write FStream;
    property CustStream: TMemoryStream read GetCustStream write SetCustStream;
  end;

  TForeignCustomer = class(TCustomer)
  private
    FCountry: Nullable<string>;
  public
    [Column]
    property Country: Nullable<string> read FCountry write FCountry;
  end;

  [Entity]
  [Table]
  TCustomer_Orders = class
  private
    FOrder_Status_Code: Nullable<Integer>;
    FDate_Order_Placed: Nullable<TDateTime>;
    FTotal_Order_Price: Nullable<Double>;
    FORDER_ID: Integer;
    FCustomer_ID: Integer;
    FCustomer_Payment_Method_Id: Nullable<Integer>;
    FCustomer: TCustomer;
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    [Column]
    property Order_Status_Code: Nullable<Integer> read FOrder_Status_Code write FOrder_Status_Code;
    [Column([], 0, 0, 0, '')]
    property Date_Order_Placed: Nullable<TDateTime> read FDate_Order_Placed write FDate_Order_Placed;
    [Column([], 0, 14, 2, '')]
    property Total_Order_Price: Nullable<Double> read FTotal_Order_Price write FTotal_Order_Price;
    [AutoGenerated]
    [Column('ORDER_ID', [cpPrimaryKey, cpNotNull], 0, 0, 0, '')]
    property ORDER_ID: Integer read FORDER_ID write FORDER_ID;
    [Column('Customer_ID', [], 0, 0, 0, '')]
    [ForeignJoinColumn('Customer_ID', 'Customers', 'CUSTID', [fsOnDeleteCascade, fsOnUpdateCascade])]
    property Customer_ID: Integer read FCustomer_ID write FCustomer_ID;
    [Column('Customer_Payment_Method_Id', [], 0, 0, 0, '')]
    property Customer_Payment_Method_Id: Nullable<Integer> read FCustomer_Payment_Method_Id write FCustomer_Payment_Method_Id;
    [ManyToOne(False, [ckCascadeAll], 'Customer_ID')]
    property Customer: TCustomer read FCustomer write FCustomer;
  end;

 // [Entity]
  [Table('IMONES', 'VIKARINA')]
  TCompany = class
  private
    [UniqueConstraint]
    [Column('IMONE', [cpRequired, cpPrimaryKey], 0, 0, 0, 'Primary Key')]
    FId: Integer;
    FName: string;
    FAddress: string;
    FTelephone: string;
    FLogo: TPicture;
    procedure SetLogo(const Value: TPicture);
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    property ID: Integer read FId write FId;
    [Column('IMPAV', [], 50, 0, 0, 'Company name')]
    property Name: string read FName write FName;
    [Column('IMADR', [], 50, 0, 0, 'Company address')]
    property Address: string read FAddress write FAddress;
    [Column('IMTEL', [], 50, 0, 0, 'Company telephone number')]
    property Telephone: string read FTelephone write FTelephone;
    [Column('IMLOG', [], 0, 0, 0, 'Company logo')]
    property Logo: TPicture read FLogo write SetLogo;
  end;

 // [Entity]
  [Table('DARSDLA', 'VIKARINA')]
  TWorker = class
  private
    [UniqueConstraint]
    [AutoGenerated]
    [ColumnAttribute('DARSNR', [cpRequired, cpDontInsert, cpPrimaryKey], 0, 0, 0, 'Primary Key')]
    FId: Integer;
    FName: string;
    FSurname: string;
    FTabNr: Integer;
    FStartDate: TDateTime;
    FEndDate: Nullable<TDateTime>;
    FLastEditedBy: string;
  public
    property ID: Integer read FId;
    [Column('VARD', [], 50, 0, 0, 'Worker name')]
    property Name: string read FName write FName;
    [Column('PAVARD', [], 50, 0, 0, 'Worker surname')]
    property Surname: string read FSurname write FSurname;
    [Column('TABNR', [], 0, 0, 0, 'Worker tab nr')]
    property TabNr: Integer read FTabNr write FTabNr;
    [Column('DARPRDT', [], 0, 0, 0, 'Worker start date')]
    property StartDate: TDateTime read FStartDate write FStartDate;
    [Column('NUDATA', [], 0, 0, 0, 'Worker end date')]
    property EndDate: Nullable<TDateTime> read FEndDate write FEndDate;
    [Column('DARSKORV', [], 50, 0, 0, 'Last edited username')]
    property LastEditedBy: string read FLastEditedBy write FLastEditedBy;
  end;

  [Entity]
  [Table('Products')]
  TProduct = class
  private
    [Column('PRODID', [cpRequired, cpPrimaryKey, cpNotNull])]
    [AutoGenerated]
    FId: Integer;
  private
    FName: string;
    FPrice: Double;
    [Version('_version', 1)] FVersion: Integer;
  public
    property ID: Integer read FId write FId;
    [Column('PRODNAME', [], 50, 0, 0, 'Product name')]
    property Name: string read FName write FName;
    [Column('PRODPRICE', [], 0, 12, 2, 'Product price')]
    property Price: Double read FPrice write FPrice;
    property Version: Integer read FVersion;
  end;

  //[Entity]
  [Table('IMONES')]
  [Sequence('GNR_IMONESID', 1, 1)]
  TUIBCompany = class
  private
    [Column('IMONESID', [cpRequired, cpPrimaryKey, cpDontInsert], 0, 0, 0, 'Primary Key')]
    [AutoGenerated]
    FId: Integer;
    FName: string;
    FPhone: string;
  public
    property ID: Integer read FId;
    [Column('PAVADINIMAS', [], 50, 0, 0, 'company name')]
    property Name: string read FName write FName;
    [Column('TELEFONAS', [], 50, 0, 0, 'company phone')]
    property Phone: string read FPhone write FPhone;
  end;

  TUserRole = class;
  TRole = class;

  [Entity][Table]
  TUser = class
  private
    [Column('Id', [cpRequired, cpPrimaryKey])]
    fId: Integer;

    [OneToMany(false, [ckCascadeAll])]
    fUserRoles: Lazy<IList<TUserRole>>;
    fName: string;
    function GetUserRoles: IList<TUserRole>;
    function GetRoles: IList<TRole>;
  protected
    property UserRoles: IList<TUserRole> read GetUserRoles;
  public
    constructor Create;

    procedure AddRole(role: TRole);

    property Id: Integer read fId;
    [Column]
    property Name: string read fName write fName;

    property Roles: IList<TRole> read GetRoles;
  end;

  [Entity][Table]
  TRole = class
  private
    [Column('Id', [cpRequired, cpPrimaryKey])]
    fId: Integer;

    [OneToMany(false, [ckCascadeAll])]
    fUserRoles: Lazy<IList<TUserRole>>;

    fDescription: string;

    function GetUserRoles: IList<TUserRole>;
    function GetUsers: IList<TUser>;
  protected
    property UserRoles: IList<TUserRole> read GetUserRoles;
  public
    constructor Create;

    property Id: Integer read fId;
    [Column]
    property Description: string read fDescription write fDescription;

    property Users: IList<TUser> read Getusers;
  end;

  TUserRoleOwnerships = set of (OwnsUser, OwnsRole);

  [Entity][Table]
  TUserRole = class
  private
    [Column('Id', [cpRequired, cpPrimaryKey])]
    fId: Integer;
    fUser: TUser;
    fRole: TRole;
    fRoleId: Integer;
    fUserId: Integer;
    fDateAssigned: TDateTime;
    fOwnerships: TUserRoleOwnerships;
  public
    constructor Create; overload;
    constructor Create(ownerships: TUserRoleOwnerships); overload;
    destructor Destroy; override;


    property Id: Integer read fId;

    [Column][ForeignJoinColumn('RoleId', 'Role', 'Id', [fsOnDeleteCascade, fsOnUpdateCascade])]
    property RoleId: Integer read fRoleId write fRoleId;
    [Column][ForeignJoinColumn('UserId', 'User', 'Id', [fsOnDeleteCascade, fsOnUpdateCascade])]
    property UserId: Integer read fUserId write fUserId;

    [Column]
    property AssignedDate: TDateTime read fDateAssigned write fDateAssigned;

    [ManyToOne(False, [ckCascadeAll], 'UserId')]
    property User: TUser read fUser write fUser;
    [ManyToOne(False, [ckCascadeAll], 'RoleId')]
    property Role: TRole read fRole write fRole;
  end;

var
  PictureFilename, OutputDir: string;

implementation

uses
  SysUtils;

{ TCustomer }

constructor TCustomer.Create;
begin
  inherited Create;
  FId := -1;
  FStrings := TStringList.Create;
  FOrders := TCollections.CreateObjectList<TCustomer_Orders>;
end;

destructor TCustomer.Destroy;
begin
  FStrings.Free;
  if FAvatarNullable.IsValueCreated then
    if FAvatarNullable.Value.HasValue then
      FAvatarNullable.Value.Value.Free;
  inherited Destroy;
end;

function TCustomer.GetAvatar: TPicture;
begin
  Result := FAvatarNullable.Value.Value;
end;

function TCustomer.GetAvatarLazy: Nullable<TPicture>;
begin
  Result := FAvatarNullable.Value;
end;

function TCustomer.GetCustStream: TMemoryStream;
begin
  Result := FStream.Value;
end;

function TCustomer.GetOrders: IList<TCustomer_Orders>;
begin
  Result := FOrders.Value;
end;

function TCustomer.GetOrdersIntf: IList<TCustomer_Orders>;
begin
  Result := FOrders.Value;
end;

function TCustomer.GetProducts: IList<TProduct>;
begin
  Result := FProducts.Value;
end;

procedure TCustomer.SetAvatar(const Value: TPicture);
begin
  if FAvatarNullable.IsAssigned then
    FAvatarNullable.Value.Value.Assign(Value)
  else
    FAvatarNullable.CreateFrom(Value);
end;

procedure TCustomer.SetAvatarLazy(const Value: Nullable<TPicture>);
begin
  FAvatarNullable := Value;
end;

procedure TCustomer.SetCustStream(const Value: TMemoryStream);
begin
  if Value <> nil then
    FStream.Value.LoadFromStream(Value)
  else
    FStream.Value.Clear;
end;

procedure TCustomer.SetOrdersIntf(const Value: IList<TCustomer_Orders>);
begin
  FOrders := Value;
end;

procedure TCustomer.SetProducts(const Value: IList<TProduct>);
begin
  FProducts := Value;
end;

{ TCompany }

constructor TCompany.Create;
begin
  inherited Create;
  FId := -1;
  FLogo := TPicture.Create;
end;

destructor TCompany.Destroy;
begin
  FLogo.Free;
  inherited Destroy;
end;

procedure TCompany.SetLogo(const Value: TPicture);
begin
  FLogo.Assign(Value);
end;

{ TCustomer_Orders }

constructor TCustomer_Orders.Create;
begin
  inherited Create;
  FCustomer := nil;
end;

destructor TCustomer_Orders.Destroy;
begin
  if Assigned(FCustomer) then
    FCustomer.Free;

  inherited Destroy;
end;

 { TUser }

function TUser.GetUserRoles: IList<TUserRole>;
begin
  Result := fUserRoles.Value;
end;


procedure TUser.AddRole(role: TRole);
var
  userRoleForUser, userRoleForRole: TUserRole;
begin
  userRoleForUser := TUserRole.Create([]);
  userRoleForUser.User := Self;
  userRoleForUser.Role := role;
  userRoleForUser.AssignedDate := Now;

  userRoleForRole := TUserRole.Create([]);
  userRoleForRole.User := Self;
  userRoleForRole.Role := role;
  userRoleForRole.AssignedDate := userRoleForUser.AssignedDate;

  UserRoles.Add(userRoleForUser);
  role.UserRoles.Add(userRoleForRole);
end;

constructor TUser.Create;
begin
  fUserRoles := TCollections.CreateObjectList<TUserRole>;
end;

function TUser.GetRoles: IList<TRole>;
var
  userRole: TUserRole;
begin
  Result := TCollections.CreateList<TRole>;
  for userRole in fUserRoles.Value do
  begin
    Result.Add(userRole.Role);
  end;
end;

{ TRole }

constructor TRole.Create;
begin
  fUserRoles := TCollections.CreateObjectList<TUserRole>;
end;

function TRole.GetUserRoles: IList<TUserRole>;
begin
  Result := fUserRoles.Value;
end;

function TRole.GetUsers: IList<TUser>;
var
  userRole: TUserRole;
begin
  Result := TCollections.CreateList<TUser>;
  for userRole in GetUserRoles do
  begin
    Result.Add(userRole.User);
  end;
end;

{ TUserRole }

constructor TUserRole.Create;
begin
  Create([OwnsUser, OwnsRole]);
end;

constructor TUserRole.Create(ownerships: TUserRoleOwnerships);
begin
  inherited Create;
  fOwnerships := ownerships;
end;

destructor TUserRole.Destroy;
begin
  if OwnsUser in fOwnerships then
    fUser.Free;
  if OwnsRole in fOwnerships then
    fRole.Free;
  inherited Destroy;
end;


end.


