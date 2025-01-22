#define AppId "{22061993-FA82-438F-914B-2F5157DBD230}"
#define AppName 'COINES'
#define PublisherName 'Bosch Sensortec, GmbH.'
#define Url 'http://www.bosch-sensortec.com/'
#define AppVersion '2.9.1'

#define NumberOfVersionPoints 2
#define SetupName 'COINES'

[Setup]
AppId= {{#AppID} 
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName}
VersionInfoVersion={#AppVersion}
AppPublisher={#PublisherName} 
AppPublisherURL={#Url}
AppSupportURL={#Url}
AppUpdatesURL={#Url}
DefaultDirName=C:\COINES\v{#AppVersion}
DefaultGroupName=COINES
LicenseFile=COINES_SDK_SoftwareLicenseAgreement.rtf
UninstallDisplayIcon={app}\COINES.ico
OutputBaseFilename={#SetupName}
Compression=lzma2
SolidCompression=yes
OutputDir=.\ 


DisableWelcomePage=yes
DisableDirPage=no
DisableProgramGroupPage=yes
DisableStartupPrompt=yes
DisableFinishedPage=false

UpdateUninstallLogAppName=no
UsePreviousAppDir=yes
CreateUninstallRegKey=no
ArchitecturesInstallIn64BitMode=x64
ChangesEnvironment=true


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Files]
Source: "..\..\..\__temp\COINES\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs;

[Icons]
Name: "{group}\v{#AppVersion}\Examples"; Filename:"{app}\examples"

[Run]
Filename: "{app}\driver\app_board_usb_driver.exe" ; Description: "Install Application Board USB driver (Recommended)"; Flags: postinstall skipifsilent shellexec runascurrentuser

[Run]
Filename: "{app}\ReleaseNotes.txt" ; Description: "Read Release notes(Recommended)"; Flags: postinstall skipifsilent shellexec runascurrentuser

[Code]
var
  BLEPath: string;
  BatchFile1: string;
  BatchFile2: string;
  BatchFile3: string;
  BinFolder: string;

function IsWin64: Boolean;
begin
  Result := Is64BitInstallMode or (GetEnv('ProgramW6432') <> '');
end;

procedure SetBLEPath;
begin
  if IsWin64 then
  begin
    BLEPath := ExpandConstant('{app}\coines-api\pc\ble_com\simpleble-0.6.0\Windows\x64');
  end
  else
  begin
    BLEPath := ExpandConstant('{app}\coines-api\pc\ble_com\simpleble-0.6.0\Windows\x86');
  end;
end;

procedure UpdateEnvironmentPath(const UpdatePath: string);
var
  Params: string;
  ResultCode: Integer;
begin
  Params := '"' + UpdatePath + '"';
  Exec(BatchFile2, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure RemovePathFromEnvironment(const RemovePath: string);
var
  Params: string;
  ResultCode: Integer;
begin
  Params := '"' + RemovePath + '"';
  Exec(BatchFile3, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;


procedure CustomInit;
begin
  // Set variables
  SetBLEPath();
  BinFolder := ExpandConstant('{app}\coines-api\pc\ble_com\simpleble-0.6.0\Windows\bin');
  BatchFile1 := ExpandConstant('{app}\installer_scripts\Windows\ble_dependency_verifier.bat');
  BatchFile2 := ExpandConstant('{app}\installer_scripts\Windows\ble_env_path_setter.bat');
  BatchFile3 := ExpandConstant('{app}\installer_scripts\Windows\ble_env_path_remover.bat');
end;

procedure Initialize;
begin
  CustomInit();
  UpdateEnvironmentPath(BLEPath);
end;

procedure DelFile(const FileName: string);
begin
  if FileExists(FileName) then
    DeleteFile(FileName);
end;

procedure DelFolder(const FolderName: string);
begin
  if DirExists(FolderName) then
    DelTree(FolderName, True, True, True);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  //Check for spaces in install path name
  { if we're on the directory selection page and the value returned by }
  { the WizardDirValue function contains at least one space, then... }
  if (CurPageID = wpSelectDir) and (Pos(' ', WizardDirValue) > 0) then
  begin
    Result := False;
    MsgBox('Target installation directory cannot contain spaces. ' +
      'Choose a different one.', mbError, MB_OK);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    Initialize();
    WizardForm.StatusLabel.Caption := 'Handling BLE dependencies...';
    WizardForm.CancelButton.Enabled := True;
    WizardForm.CancelButton.Default := True;
    WizardForm.ProgressGauge.Min := 0;
    WizardForm.ProgressGauge.Max := 100;
    WizardForm.ProgressGauge.Position := 90;

    // Execute the batch file silently
    if Exec(BatchFile1, '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      // Check the exit code of the batch file
      if ResultCode = 1 then
      begin
        UpdateEnvironmentPath(BinFolder);
      end
      else if ResultCode = 0 then
      begin
        // No missing DLLs, continue with the installation and delete Bin folder
        DelFolder(BinFolder);
      end
      else
      begin
        // Batch file encountered an error, show a message or perform any necessary actions
        MsgBox('An error occurred while checking DLLs.', mbError, MB_OK);
      end;
    end
    else
    begin
      // Failed to execute the batch file, show a message or perform any necessary actions
      MsgBox('Failed to execute the batch file.', mbError, MB_OK);
    end;

    DelFile(BatchFile1);
    DelFile(BatchFile2);

    WizardForm.ProgressGauge.Position := 100;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    // Remove the environment variables set
    CustomInit();
    RemovePathFromEnvironment(BinFolder);
    RemovePathFromEnvironment(BLEPath);
  end;
end;
