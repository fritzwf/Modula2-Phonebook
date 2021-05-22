MODULE PBook;

FROM StdInOut IMPORT ReadString, WriteString, ReadCard, GotoXY, CLS, WriteLn;
FROM InOut IMPORT Read;
FROM Utilities IMPORT Beep;
FROM NumberConversion IMPORT StringToCard;
FROM ASCII IMPORT esc, nul;
FROM MyLib IMPORT ReadStr, WriteDecimal, RaisePower, SoundUp, SoundDown, Error,
          ScreenSaver, WriteTime, WriteDate, ReadStrEOLFS, BigBox, ClearScreen,
          Pause, YesNo, YesNo1, More, FindMins, ReadCaps, GetDate, Header, READ,
          LineHeader, ConvertDecimal, ReadPart;
FROM FileSystem IMPORT Lookup, SetPos, WriteChar, Close, Rename,
                       Response, GetPos, Length, ReadChar, File;
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
     GoodModem: BOOLEAN;
     Com_Port : CHAR;

PROCEDURE GetINI(VAR com_port : CHAR) : BOOLEAN;

BEGIN

        Lookup( MyFile, "PHONE_BK.INI", FALSE );
        IF (MyFile.res = done) THEN
            ReadChar( MyFile, com_port );
            Close( MyFile );
            RETURN TRUE;
       ELSE
            RETURN FALSE;
       END (* if *);

END GetINI;

BEGIN  (* Phone Function *)

 IF GetINI( Com_Port ) THEN
    GoodModem := TRUE;
 ELSE
    GoodModem := FALSE;
 END (* if *);

 KeyValid := TRUE;

 SearchName( MyFile );
 CursorOff;

 REPEAT

   IF KeyValid THEN
   CLS;
        ColorFg(10);
        GotoXY(27,4);  WriteString('Quick Phonebook v.3.5');
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
        ColorFg(11);
        GotoXY(25,17); WriteString('<F5> Ä Change COM Port');
        ColorFg(9);
        GotoXY(25,20);WriteString('<ESC> Ä Quit program');
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
 63  (* F5 *)

        :  ColorFg(14);
           CLS;
           Header("COM Port Number");
           GotoXY(5,5); WriteString("1 character is allowed.");
           GotoXY(5,7); WriteString("The modem COM port number should be entered.");
           GotoXY(5,9); WriteString("Example: 2");
           GotoXY(5,11); WriteString("Enter COM port number:  ");
           IF GoodModem THEN
             WriteString(Com_Port);
             GotoXY(28,11);
           END (* if *);
           ReadCaps( Com_Port, (NOT GoodModem) );
     IF YesNo1('Is this information correct? ENTER=[Y]es or [N]o: ',3,21) THEN
           Lookup( MyFile, "PHONE_BK.INI", TRUE );
           WriteChar( MyFile, Com_Port );
           Close( MyFile );
     END (* if *);
         KeyValid := TRUE;
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
WriteString("Fritz Feuerbacher"); WriteLn;
CursorOn;
END PBook.
