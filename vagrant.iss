; ======================================================================================================================
; Vagrant - Windows Installer
;
; Author: Jihad Sinnaour (Jakiboy) <j.sinnaour.official@gmail.com>
; URL: https://github.com/Jakiboy/vagrant-windows-installer
; Copyright (C) 2023 Jihad Sinnaour. All rights reserved.
; ======================================================================================================================

; Define:

#define InstallerName "Vagrant - Windows Installer"
#define InstallerFile "Vagrant-Windows-Installer-x64"
#define InstallerVersion "1.0.0"
#define InstallerPublisher "Jihad Sinnaour (Jakiboy)"
#define InstallerURL "https://github.com/Jakiboy/vagrant-windows-installer"
#define InstallerRoot "."

; Setup:

[Setup]
AppId={{407C8EF1-43D0-466F-A957-69EECD440C4B}
AppName={#InstallerName}
AppVersion={#InstallerVersion}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerURL}
AppSupportURL={#InstallerURL}
AppUpdatesURL={#InstallerURL}
CreateAppDir=no
LicenseFile={#InstallerRoot}\LICENSE
InfoBeforeFile={#InstallerRoot}\vagrant.txt
OutputDir={#InstallerRoot}\build
OutputBaseFilename={#InstallerFile}
SetupIconFile={#InstallerRoot}\assets\vagrant.ico
WizardImageFile={#InstallerRoot}\assets\large.bmp
WizardSmallImageFile={#InstallerRoot}\assets\small.bmp
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
AlwaysRestart=yes

; Languages:

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Files:

[Files]
Source: "{tmp}/virtualbox.exe"; DestDir: {tmp}; Flags: deleteafterinstall external;
Source: "{tmp}/vagrant.exe"; DestDir: {tmp}; Flags: deleteafterinstall external;

; Run:

[Run]
; Install VirtualBox
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Start-Process {tmp}\\virtualbox.exe"""; Flags: runhidden;

; Install Vagrant
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Start-Process {tmp}\\vagrant.exe"""; Flags: runhidden;

; Code:

[Code]

// Download external files:

var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
    DownloadPage.Clear;
    // Download VirtualBox
    DownloadPage.Add('https://download.virtualbox.org/virtualbox/7.0.6/VirtualBox-7.0.6-155176-Win.exe', 'virtualbox.exe', '');
    // Download Vagrant
    DownloadPage.Add('https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_windows_amd64.msi', 'vagrant.exe', '');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
        Result := True;
      except
        SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end else
    Result := True;
end;
