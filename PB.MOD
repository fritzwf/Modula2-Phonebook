MODULE Phone;

FROM StdInOut IMPORT ReadString, WriteString, ReadCard, GotoXY, CLS, WriteLn;
FROM InOut IMPORT Read;
FROM Utilities IMPORT Beep;
FROM NumberConversion IMPORT StringToCard;
FROM ASCII IMPORT esc, nul;
FROM MyLib IMPORT ReadStr, WriteDecimal, RaisePower, SoundUp, SoundDown, Error,
          ScreenSaver, WriteTime, WriteDate, ReadStrEOLFS, BigBox, ClearScreen,
          Pause, YesNo, YesNo1, More, FindMins, ReadCaps, GetDate, Header, READ,
          LineHeader, ConvertDecimal, ReadPart;
FROM FileSystem IMPORT File;
FROM Strings IMPORT CompareStr, Insert;
FROM Terminal IMPORT KeyPressed;
FROM PhoneImp IMPORT PrintPhoneBook, AddName, DisplayNames, DeleteName, SearchName;
FROM Windows IMPORT T1,T2,titlet, titleb, shadow, titlebd,explode,
             Title, CloseWindow, OpenWindow, DataWindow, TColor, SColor;
FROM Video IMPORT Black, Blue, Brown, Cyan, Green,
              Red,       Magenta,    Gray,       High,      Blink,
  (* proc  *) ClrEOL,    ClrLine,    Color,      ColorBg,   ColorFg,
              CursorOff, CursorOn ,  DeleteLine, Down,      GetAttrib,
              GetCursor, InsertLine, Left,       Right,     SetAttrib,
              SetCursor, ScrollDown, ScrollUp ,  SetVideo,  Up,
              WhatPage,  WhereX,    WhereY,     WriteAtXY;

VAR    MyFile : File;
           ch : CHAR;
     KeyValid : BOOLEAN;

BEGIN  (* Phone Function *)

KeyValid := TRUE;

 SearchName( MyFile );
  CursorOff;

  REPEAT

   IF KeyValid THEN
   CLS;
        ColorFg(10);
        GotoXY(27,4);  WriteString('Quick Phonebook v.3.6');
        ColorFg(9);
        GotoXY(27,5);  WriteString('---------------------');
        GotoXY(27,6);  WriteString('     By FeuerSoft');
        ColorFg(11);
        GotoXY(25,9);  WriteString('<F1> Ä Search and Display');
        ColorFg(12);
        GotoXY(25,11); WriteString('<F2> Ä Add a phone entry');
        ColorFg(13);
        GotoXY(25,13); WriteString('<F3> Ä Delete a phone entry');
        ColorFg(14);
        GotoXY(25,15); WriteString('<F4> Ä Print phone entries');
        ColorFg(9);
        GotoXY(25,18);WriteString('<ESC> Ä Quit program');
   END (* if *);

   Read(ch);
 IF ch = nul THEN
   Read(ch);
   CASE ORD(ch) OF
     
 59 : (* F1 *)
         SearchName( MyFile );
         KeyValid := TRUE
         |
 60 : (* F2 *)
         AddName( MyFile );
         KeyValid := TRUE
         |
 61 : (* F3 *)
         DeleteName( MyFile );
         KeyValid := TRUE
         |
 62 : (* F4 *)
         PrintPhoneBook( MyFile );
         KeyValid := TRUE
         |
   ELSE 
     KeyValid := FALSE; Beep;

 END (* case *);

ELSIF (ch # esc) THEN
       KeyValid := FALSE; Beep;

END (* if *);

UNTIL ch = esc;

ColorFg(7);
CLS;
WriteString("Copyright Fritz Feuerbacher 2000"); WriteLn;
CursorOn;
END Phone.
