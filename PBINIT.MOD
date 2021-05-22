MODULE PBInit;

FROM StdInOut IMPORT WriteLn, WriteString, ReadCard, GotoXY, CLS, ReadLine,
                                              WriteCard, Write, ReadString;
FROM InOut IMPORT Read;
FROM Utilities IMPORT Beep;
FROM ASCII IMPORT esc, nul, EOL, bs;
FROM MyLib IMPORT  YesNo1,  Header, ReadCaps, ReadStr;
IMPORT FileSystem; (* Lookup, SetPos, WriteChar, Close, Rename,
                       Response, GetPos, Length, ReadChar, File; *)
FROM Video IMPORT CursorOn, CursorOff;

VAR
           Com_Port : CHAR;  (* 1,2,3, or 4   *)
           DialType : CHAR;  (* Tone or Pulse *)
             Volume : CHAR;  (* Modem volume Level *)

                 ch : CHAR;
           ValidKey : BOOLEAN;
              MInit : BOOLEAN;
       ModemChanged : BOOLEAN;
               file : FileSystem.File;


PROCEDURE GetINI(VAR com_port, dial_type, volume : CHAR) : BOOLEAN;

BEGIN

        FileSystem.Lookup( file, "PHONE_BK.INI", FALSE );
        IF (file.res = FileSystem.done) THEN
            FileSystem.ReadChar( file, com_port );
            FileSystem.ReadChar( file, dial_type );
            FileSystem.ReadChar( file, volume );
            FileSystem.Close( file );
            RETURN TRUE;
       ELSE
            RETURN FALSE;
       END (* if *);

END GetINI;


BEGIN

  CursorOff;
  Com_Port := '1';
  DialType := 'T';
  Volume   := '3'; (* Loudest *)

  MInit := TRUE; ModemChanged := FALSE;

  IF GetINI( Com_Port, DialType, Volume ) THEN
    MInit := FALSE;
  END (* if *);

  ValidKey := TRUE;

  REPEAT

   IF ValidKey THEN
        CLS;
        GotoXY(27,4); WriteString('  Phone Book Setup v1.1  ');
        GotoXY(27,5); WriteString('-------------------------');
        GotoXY(22,9);WriteString('F1) Ä Enter modem COM Port number');
        GotoXY(22,12);WriteString('F2) Ä Enter dial type');
        GotoXY(22,15);WriteString('F3) Ä Enter modem volume');

        GotoXY(22,21);WriteString('ESC) Ä QUIT and SAVE setup');
     END (* if *);

   Read(ch);
   IF ch = nul THEN
   Read(ch);
   CASE ORD(ch) OF

 59  (* F1 *)

        : CLS;
           Header("COM Port Number");
           GotoXY(5,5); WriteString("1 character is allowed.");
           GotoXY(5,7); WriteString("The modem COM port number should be entered.");
           GotoXY(5,9); WriteString("Example: 2");
           GotoXY(5,11); WriteString("Enter COM port number:  ");
           IF NOT MInit THEN
             WriteString(Com_Port);
             GotoXY(28,11);
           END (* if *);
           ReadCaps( Com_Port, MInit );
           IF ((Com_Port # '1') AND (Com_Port # '2') AND
                                     (Com_Port # '3') AND (Com_Port # '4')) THEN
               Com_Port := '1';
           END (* if *);
     IF YesNo1('Is this information correct? ENTER=[Y]es or [N]o: ',3,21) THEN
           ModemChanged := TRUE;
        END (* if *);
         ValidKey := TRUE;
         |
 60  (* F2 *)

        : CLS;
           Header("Dial Type");
           GotoXY(5,5); WriteString("1 character is allowed.");
           GotoXY(5,7); WriteString("The modem dial type should be entered.");
           GotoXY(5,9); WriteString("Example: T = tone or P = pulse");
           GotoXY(5,11); WriteString("Enter dial type:  ");
           IF NOT MInit THEN
             WriteString(DialType);
             GotoXY(22,11);
           END (* if *);
           ReadCaps( DialType, MInit );

           IF ((DialType # 'T') AND (DialType # 'P')) THEN
               DialType := 'T';
           END (* if *);

     IF YesNo1('Is this information correct? ENTER=[Y]es or [N]o: ',3,21) THEN
           ModemChanged := TRUE;
        END (* if *);
         ValidKey := TRUE;
         |

 61  (* F3 *)

        : CLS;
           Header("Modem Volume");
           GotoXY(5,5); WriteString("1 character is allowed.");
           GotoXY(5,7); WriteString("The modem volume level.");
           GotoXY(5,9); WriteString("Example: 1 = lowest or 2 = middle or 3 = loudest");
           GotoXY(5,11); WriteString("Enter modem volume:  ");
           IF NOT MInit THEN
             WriteString(Volume);
             GotoXY(25,11);
           END (* if *);
           ReadCaps( Volume, MInit );

           IF ((Volume # '1') AND (Volume # '2') AND (Volume # '3')) THEN
               Volume := '3';
           END (* if *);

     IF YesNo1('Is this information correct? ENTER=[Y]es or [N]o: ',3,21) THEN
           ModemChanged := TRUE;
        END (* if *);
         ValidKey := TRUE;
         |

   ELSE
       ValidKey := FALSE;
       Beep;

 END (* case *);

ELSIF (ORD(ch) # 27) THEN
     ValidKey := FALSE; Beep;

END (* if *);

UNTIL ORD(ch) = 27;

  CLS;

     IF ModemChanged THEN
       FileSystem.Lookup( file, "PHONE_BK.INI", TRUE );
       FileSystem.WriteChar( file, Com_Port );
       FileSystem.WriteChar( file, DialType );
       FileSystem.WriteChar( file, Volume );
       FileSystem.Close( file );
       WriteString("Setup parameters saved!");
       WriteLn; WriteLn;
     END (* if *);

  WriteString("Setup parameters:"); WriteLn;
  WriteString("COM port  = "); Write(Com_Port); WriteLn;
  WriteString("Dial type = "); Write(DialType); WriteLn;
  WriteString("Volume    = "); Write(Volume); WriteLn; WriteLn;

  WriteString('Phone Book Setup v1.1'); WriteLn;
  WriteString('Copyright Fritz Feuerbacher 2000'); WriteLn;

CursorOn;

END PBInit.
