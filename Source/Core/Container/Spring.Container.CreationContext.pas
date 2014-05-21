{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2014 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Spring.Container.CreationContext;

{$I Spring.inc}

interface

uses
  Rtti,
  Spring,
  Spring.Collections,
  Spring.Container.Core;

type
  TCreationContext = class(TInterfacedObject, ICreationContext)
  private
    fResolutionStack: IStack<TComponentModel>;
    fModel: TComponentModel;
    fArguments: IList<TValue>;
    fNamedArguments: IList<TNamedValue>;
    fTypedArguments: IList<TTypedValue>;
  public
    constructor Create(const model: TComponentModel;
      const arguments: array of TValue);

    function CanResolve(const context: ICreationContext;
      const dependency: TRttiType; const argument: TValue): Boolean;
    function Resolve(const context: ICreationContext;
      const dependency: TRttiType; const argument: TValue): TValue;

    procedure EnterResolution(const model: TComponentModel);
    procedure LeaveResolution(const model: TComponentModel);
    function IsInResolution(const model: TComponentModel): Boolean;

    procedure AddArgument(const argument: TValue);
    function CheckConstructorCandidate(const injection: IInjection): Boolean;
    function CreateConstructorArguments(const injection: IInjection): TArray<TValue>;
  end;

implementation

uses
  SysUtils,
  Spring.Container.ResourceStrings,
  Spring.Helpers;


{$REGION 'TCreationContext'}

constructor TCreationContext.Create(const model: TComponentModel;
  const arguments: array of TValue);
var
  i: Integer;
begin
  inherited Create;
  fResolutionStack := TCollections.CreateStack<TComponentModel>;
  fModel := model;
  fArguments := TCollections.CreateList<TValue>;
  fNamedArguments := TCollections.CreateList<TNamedValue>;
  fTypedArguments := TCollections.CreateList<TTypedValue>;
  for i := 0 to High(arguments) do
    AddArgument(arguments[i]);
end;

procedure TCreationContext.AddArgument(const argument: TValue);
begin
  if argument.IsType<TTypedValue> then
    fTypedArguments.Add(argument)
  else if argument.IsType<TNamedValue> then
    fNamedArguments.Add(argument)
  else
    fArguments.Add(argument);
end;

function TCreationContext.CanResolve(const context: ICreationContext;
  const dependency: TRttiType; const argument: TValue): Boolean;
var
  i: Integer;
begin
  for i := fTypedArguments.Count - 1 downto 0 do // check most recently added first
    if fTypedArguments[i].TypeInfo = dependency.Handle then
      Exit(True);
  Result := False;
end;

// TODO clean up this mess of an implementation
function TCreationContext.CheckConstructorCandidate(
  const injection: IInjection): Boolean;
var
  i: Integer;
  parameters: TArray<TRttiParameter>;
  value: TNamedValue;
begin
  if not fModel.ConstructorInjections.Contains(injection) then
    Exit(True);

  parameters := injection.Target.AsMethod.GetParameters;
  if Length(parameters) = fArguments.Count then
  begin
    // arguments for ctor are provided and count is correct
    for i := 0 to High(parameters) do // check all parameters
      if not fArguments[i].IsType(parameters[i].ParamType.Handle) then
        Exit(False); // argument and parameter types did not match
  end
  else if not fArguments.IsEmpty then
    Exit(False);
  for value in fNamedArguments do // check all named arguments
  begin
    Result := False;
    for i := 0 to High(parameters) do
    begin // look for parameter that matches the name and type
      if SameText(parameters[i].Name, value.Name)
        and value.Value.IsType(parameters[i].ParamType.Handle) then
      begin
        Result := True;
        Break;
      end;
    end;
    if not Result then // named argument was not found
      Exit;
  end;

  Result := True;
end;

function TCreationContext.CreateConstructorArguments(
  const injection: IInjection): TArray<TValue>;
var
  i: Integer;
  parameters: TArray<TRttiParameter>;
  value: TNamedValue;
  handled: Boolean;
begin
  Result := Copy(injection.Arguments);
  if not fModel.ConstructorInjections.Contains(injection) then
    Exit;

  parameters := injection.Target.AsMethod.GetParameters;
  if Length(parameters) = fArguments.Count then
  begin
    for i := 0 to High(parameters) do
      if fArguments[i].IsType(parameters[i].ParamType.Handle) then
        Result[i] := fArguments[i]
      else
        raise EResolveException.CreateRes(@SUnsatisfiedConstructorParameters);
  end
  else if not fArguments.IsEmpty then
    raise EResolveException.CreateRes(@SUnsatisfiedConstructorParameters);
  for value in fNamedArguments do
  begin
    handled := False;
    for i := 0 to High(parameters) do
    begin
      if SameText(parameters[i].Name, value.Name)
        and value.Value.IsType(parameters[i].ParamType.Handle) then
      begin
        Result[i] := value.Value;
        handled := True;
        Break;
      end;
    end;
    if not handled then
      raise EResolveException.CreateRes(@SUnsatisfiedConstructorParameters);
  end;
end;

procedure TCreationContext.EnterResolution(const model: TComponentModel);
begin
  if not Assigned(fModel) then // set the model if we don't know it yet
    fModel := model;
  fResolutionStack.Push(model);
end;

function TCreationContext.IsInResolution(const model: TComponentModel): Boolean;
begin
  Result := fResolutionStack.Contains(model);
end;

procedure TCreationContext.LeaveResolution(const model: TComponentModel);
begin
  Assert(fResolutionStack.Pop = model);
end;

function TCreationContext.Resolve(const context: ICreationContext;
  const dependency: TRttiType; const argument: TValue): TValue;
var
  i: Integer;
begin
  for i := fTypedArguments.Count - 1 downto 0 do
    if fTypedArguments[i].TypeInfo = dependency.Handle then
      Exit(fTypedArguments[i].Value);
  raise EResolveException.CreateResFmt(@SCannotResolveDependency, [dependency.Name]);
end;

{$ENDREGION}


end.
