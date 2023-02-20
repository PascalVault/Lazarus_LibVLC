unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  PasLibVlcPlayerUnit;

type

  { TForm1 }

  TForm1 = class(TForm)
    bplay: TButton;
    bstop: TButton;
    chbdisableaudio: TCheckBox;
    chbsavevideo: TCheckBox;
    evideo: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    sddvideo: TSelectDirectoryDialog;
    procedure bplayClick(Sender: TObject);
    procedure bstopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    plvplayer: TPasLibVlcPlayer;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.bplayClick(Sender: TObject);
var
  vfl: WideString;
  Options: array[0..2] of WideString;
  na: Integer = 0;
begin
  //stop if playing
  if plvplayer.GetState = plvPlayer_Playing then
    plvplayer.Stop(0);
  //video path - if empty then play "BigBuckBunny"
  if evideo.Text = '' then
    evideo.Text := 'rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4';
  vfl := WideString(evideo.Text);
  //options
  if chbdisableaudio.Checked then  //disable audio
  begin
    Options[0] := ':no-audio';
    na := 1;
  end;
  Options[0 + na] := ':network-caching=1000';
  if chbsavevideo.Checked then
  begin
    if sddvideo.Execute then
      Options[1 + na] := ':sout=#duplicate{dst=display,dst=file{mux=mp4,dst="' +
        WideString(IncludeTrailingPathDelimiter(sddvideo.FileName) + ExtractFileName(evideo.Text)) + '"}}'
    else
    begin
      ShowMessage('Select directory to save video file');
      exit;
    end;
  end
  else
    Options[1 + na] := ':sout=#duplicate{dst=display}';
  chbdisableaudio.Enabled := False;
  chbsavevideo.Enabled := False;
  plvplayer.Play(vfl, Options);
end;

procedure TForm1.bstopClick(Sender: TObject);
begin
  chbdisableaudio.Enabled := True;
  chbsavevideo.Enabled := True;
  plvplayer.Stop();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  plvplayer := TPasLibVlcPlayer.Create(Self);
  plvplayer.Parent := Form1;
  plvplayer.Align := alClient;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  plvplayer.Free;
end;

end.
