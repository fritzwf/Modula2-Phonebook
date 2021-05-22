MODULE PBComm;

IMPORT RTSMain;
IMPORT RS232;
FROM StdInOut IMPORT ReadString, WriteString, ReadCard, GotoXY, CLS, WriteLn;
FROM InOut IMPORT Read;
FROM Utilities IMPORT Beep, CenterStr;
FROM ASCII IMPORT esc, nul, cr;
FROM MyLib IMPORT ReadStr, WriteDecimal, RaisePower, SoundUp, SoundDown, Error,
          ScreenSaver, WriteTime, WriteDate, ReadStrEOLFS, BigBox, ClearScreen,
          Pause, YesNo, YesNo1, More, FindMins, ReadCaps, GetDate, Header, READ,
          LineHeader, ConvertDecimal, ReadPart, StringMatch, ReadEscCaps;
FROM FileSystem IMPORT Lookup, SetPos, WriteChar, Close, Delete, Rename,
                        Reset, Response, GetPos, Length, ReadChar, File;
FROM Strings IMPORT CompareStr, Insert, Assign;
FROM Terminal IMPORT KeyPressed;
FROM Break    IMPORT EnableBreak, DisableBreak;
FROM Video IMPORT Black, Blue, Brown, Cyan, Green,
              Red,       Magenta,    Gray,       High,      Blink,
  (* proc  *) ClrEOL,    ClrLine,    Color,      ColorBg,   ColorFg,
              CursorOff, CursorOn ,  DeleteLine, Down,      GetAttrib,
              GetCursor, InsertLine, Left,       Right,     SetAttrib,
              SetCursor, ScrollDown, ScrollUp ,  SetVideo,  Up,
              WhatPage,  WhereX,     WhereY,     WriteAtXY;


CONST MAXSIZE    = 1000;
      VER        = "v0.05";

TYPE Name        = ARRAY [0..29] OF CHAR;
TYPE Phone       = ARRAY [0..12] OF CHAR;
TYPE PhoneRecord = RECORD
                   Name  : Name;
                   Phone : Phone;
                 END (* record *);

TYPE PhoneArray  = ARRAY [0..MAXSIZE] OF PhoneRecord;

VAR  MyFile     : File;
     ch         : CHAR;
     Com_Port   : CHAR;
     DialType   : CHAR;
     Volume     : CHAR;
     KeyValid   : BOOLEAN;
     GoodModem  : BOOLEAN;
     Com        : CARDINAL;
     StartIdx   : INTEGER;
     EndIdx     : INTEGER;
     Count      : INTEGER;
     ScreenY    : CARDINAL;
     Where_X    : CARDINAL;
     Where_Y    : CARDINAL;
     Blank      : Name;
     SearchName : Name;
     SearchPhone: Phone;
     ManualDial : Phone;
     exist, found,
     Okay       : BOOLEAN;
     Quit       : BOOLEAN;
     GoNum      : INTEGER;
     Cursor     : INTEGER;
     PhoneData  : PhoneArray;

(****************************************************************************)

PROCEDURE HighLight;
BEGIN
  ColorFg(14); ColorBg(1);
END HighLight;

PROCEDURE Normal;
BEGIN
  ColorBg(0); ColorFg(7);
END Normal;

PROCEDURE InitStr( VAR str : ARRAY OF CHAR );

VAR j : CARDINAL;

BEGIN
   FOR j := 0 TO HIGH(str) DO
       str[j] := " ";
   END (* for *);
END InitStr;

PROCEDURE GetINI(VAR com_port, dial_type, volume : CHAR) : BOOLEAN;

VAR file     : File;

BEGIN
   Lookup( file, "PHONE_BK.INI", FALSE );
   IF (file.res = done) THEN
      ReadChar( file, com_port );
      ReadChar( file, dial_type );
      ReadChar( file, volume );
      Close( file );
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END (* if *);

END GetINI;

PROCEDURE WriteModem( Num : ARRAY OF CHAR);

 VAR i : CARDINAL;

   BEGIN
      FOR i := 0 TO HIGH(Num) DO
          RS232.Write(Num[i]);
      END (* for *);
      RS232.Write(cr);

END WriteModem;

PROCEDURE DialNumber( Num : ARRAY OF CHAR);

 VAR i : CARDINAL;

   BEGIN
      RS232.Write('A');
      RS232.Write('T');
      RS232.Write('D');
      IF (DialType = 'T') THEN
          RS232.Write('T');
      ELSE
          RS232.Write('P');
      END (* if *);
      FOR i := 0 TO HIGH(Num) DO
          RS232.Write(Num[i]);
      END (* for *);
      RS232.Write(cr);

END DialNumber;

PROCEDURE PageDown;
BEGIN
          Normal;
          IF ((StartIdx+20) < Count) THEN
              StartIdx := StartIdx+20;
              IF ((StartIdx+20) > Count) THEN
                 EndIdx := Count;
              ELSE
                 EndIdx := StartIdx+20;
              END (* if *);
          ELSE
              EndIdx := Count;
          END (* if *);
          GoNum := StartIdx;
          CLS;
          WHILE (GoNum < EndIdx) DO
                WriteString("                ");
                WriteString(PhoneData[GoNum].Name); WriteString("  ");
                WriteString(PhoneData[GoNum].Phone);
                WriteLn;
                INC(GoNum);
             END (* while *);
          Cursor := StartIdx;
          ScreenY := 0;
          GotoXY(0, 0);
          HighLight;
          WriteString("                ");
          WriteString(PhoneData[StartIdx].Name); WriteString("  ");
          WriteString(PhoneData[StartIdx].Phone);
          WriteAtXY(4, 24, "Esc = Quit | <- = Enter Num | -> = Dial Num | Other = Hangup");
END PageDown;

PROCEDURE PageUp;
BEGIN
         Normal;
         IF ((StartIdx-20) > 0) THEN
              EndIdx := StartIdx;
              StartIdx := StartIdx - 20;
         ELSE
             StartIdx := 0;
             IF ((StartIdx+20) > Count) THEN
                EndIdx := Count;
             ELSE
                EndIdx := StartIdx+20;
             END (* if *);
         END (* if *);
         GoNum := StartIdx;
         CLS;
         WHILE (StartIdx < EndIdx) DO
                  WriteString("                ");
                  WriteString(PhoneData[StartIdx].Name); WriteString("  ");
                  WriteString(PhoneData[StartIdx].Phone);
                  WriteLn;
                  INC(StartIdx);
         END (* while *);
         StartIdx := GoNum;
         Cursor := StartIdx;
         ScreenY := 0;
         GotoXY(0, 0);
         HighLight;
         WriteString("                ");
         WriteString(PhoneData[GoNum].Name); WriteString("  ");
         WriteString(PhoneData[GoNum].Phone);
         WriteAtXY(4, 24, "Esc = Quit | <- = Enter Num | -> = Dial Num | Other = Hangup");
END PageUp;

BEGIN  (* Main Procedure *)

  Count := 0;
  Lookup( MyFile, "phonenum.dat", FALSE );
  IF (MyFile.res = done) THEN
     CLS;
     GotoXY(0,8);
     CenterStr('Please wait, initializing and loading data. . . .');
     Okay := FALSE;
     ReadStrEOLFS( MyFile, SearchName, Okay );
     WHILE NOT Okay DO
       ReadStrEOLFS( MyFile, SearchPhone, Okay );
       Assign( SearchName, PhoneData[Count].Name );
       Assign( SearchPhone, PhoneData[Count].Phone );
       INC(Count);
       ReadStrEOLFS( MyFile, SearchName, Okay );
     END (* while *);
     Close ( MyFile );
  ELSE
     WriteString("No phone data found!");
     RTSMain.Terminate(RTSMain.Stopped);
  END (* if *);

  GoodModem := FALSE;

  Com_Port := '1';
  DialType := 'T';
  Volume   := '3';

  IF GetINI( Com_Port, DialType, Volume ) THEN
     GoodModem := TRUE;
  END (* if *);

(*

  IF GoodModem THEN
     IF (Com_Port = '2') THEN
        Com := 0;
     ELSE
        Com := 1;
     END (* if *);
*)

  IF GoodModem THEN
     IF (Com_Port = '1') THEN
        Com := 1;
     ELSIF (Com_Port = '2') THEN
        Com := 2;
     ELSIF (Com_Port = '3') THEN
        Com := 3;
     ELSIF (Com_Port = '4') THEN
        Com := 4;
     END (* if *);

     RS232.Init(Com, 2400, 1, FALSE, FALSE, 8, KeyValid );

  END (* if *);

  IF NOT KeyValid OR NOT GoodModem THEN
     CLS;
     WriteString("Cannot initialize modem!");
     RTSMain.Terminate(RTSMain.Stopped);
  END (* if *);

  RS232.StartReading;

  IF (Volume = '1') THEN
      WriteModem("AT M1 L1 X1");
  ELSIF (Volume = '2') THEN
      WriteModem("AT M1 L2 X1");
  ELSIF (Volume = '3') THEN
      WriteModem("AT M1 L3 X1");
  END (* if *);

  KeyValid := TRUE;
  CursorOff;

 InitStr(Blank);
 InitStr(SearchName);
 Quit := FALSE;

 (****************************************************************************)

 CLS;
 StartIdx := 0;
 WHILE (StartIdx < Count) AND (StartIdx < 20) DO
     WriteString("                ");
     WriteString(PhoneData[StartIdx].Name); WriteString("  ");
     WriteString(PhoneData[StartIdx].Phone);
     WriteLn;
     INC(StartIdx);
 END (* while *);
 HighLight;
 WriteAtXY(4, 24, "Esc = Quit | <- = Enter Num | -> = Dial Num | Other = Hangup");

 StartIdx := 0;
 ScreenY := 0;
 Cursor := StartIdx;
 GotoXY(0, ScreenY);
 HighLight;
 WriteString("                ");
 WriteString(PhoneData[StartIdx].Name); WriteString("  ");
 WriteString(PhoneData[StartIdx].Phone);


 REPEAT

  Read(ch);
  IF (ch = nul) THEN
     Read(ch);
     CASE ORD(ch) OF

       75 : (* Left Arrow *)
             GotoXY(0, ScreenY);
             Normal;
             WriteString("                ");
             WriteString(PhoneData[Cursor].Name); WriteString("  ");
             WriteString(PhoneData[Cursor].Phone);
             GotoXY(4, 22);
             WriteString("Enter phone number -> ");
             ReadStr( ManualDial, TRUE );
             IF NOT StringMatch(ManualDial,"             " ) THEN
                DialNumber(ManualDial);
             END (* if *);
             Normal;
             GotoXY(0, 22);
             ClrLine;
             GotoXY(0, ScreenY);
             HighLight;
             WriteString("                ");
             WriteString(PhoneData[Cursor].Name); WriteString("  ");
             WriteString(PhoneData[Cursor].Phone);
       |
       77 : (* Right Arrow *)
              DialNumber(PhoneData[Cursor].Phone);
       |
       80 : (* Down Arrow *)
          IF (Cursor < Count-1) THEN
             IF (ScreenY = 19) THEN
                PageDown;
             ELSE
               GotoXY(0, ScreenY);
               Normal;
               WriteString("                ");
               WriteString(PhoneData[Cursor].Name); WriteString("  ");
               WriteString(PhoneData[Cursor].Phone);
               INC(ScreenY);
               INC(Cursor);
               GotoXY(0, ScreenY);
               HighLight;
               WriteString("                ");
               WriteString(PhoneData[Cursor].Name); WriteString("  ");
               WriteString(PhoneData[Cursor].Phone);
            END (* if *);
         END (* if *);
       |
       81 : (* Page Down *)
          PageDown;
       |
       73 : (* Page Up *)
         PageUp;
       |

       72 : (* Up Arrow *)
         IF (Cursor > 0) THEN
            IF (ScreenY = 0) THEN
               PageUp;
               GotoXY(0, ScreenY);
               Normal;
               WriteString("                ");
               WriteString(PhoneData[Cursor].Name); WriteString("  ");
               WriteString(PhoneData[Cursor].Phone);
               ScreenY := 19;
               Cursor := StartIdx + 19;
            ELSE
               GotoXY(0, ScreenY);
               Normal;
               WriteString("                ");
               WriteString(PhoneData[Cursor].Name); WriteString("  ");
               WriteString(PhoneData[Cursor].Phone);
               DEC(ScreenY);
               DEC(Cursor);
            END (* if *);
            GotoXY(0, ScreenY);
            HighLight;
            WriteString("                ");
            WriteString(PhoneData[Cursor].Name); WriteString("  ");
            WriteString(PhoneData[Cursor].Phone);
         END (* if *);
       |
     ELSE
       Beep;

     END (* case *);
  ELSE
    RS232.Write(cr);
  END (* if *);

   ColorBg(0);

 UNTIL (ch = esc);

RS232.StopReading;
Normal;
CLS;
WriteString("FeuerSoft QPBC ");
WriteString(VER); WriteLn;
WriteString("Copyright Fritz Feuerbacher 2000"); WriteLn;
CursorOn;
END PBComm.
