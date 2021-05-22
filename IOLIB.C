
#define TRUE      1
#define FALSE     0


extern void readstr( char &str, int *init )  {


PROCEDURE ReadStr( VAR Str: ARRAY OF CHAR; init : BOOLEAN );

  VAR ch : CHAR;
      xbegin, i, j, k, x, y, Index, MaxIndex : CARDINAL;

  BEGIN
    GetCursor( j, k );
    SetCursor(2,5);
    xbegin := WhereX(); y := WhereY();
    GotoXY( xbegin, y ); Write('(');
    GotoXY( xbegin+1, y );
    xbegin := WhereX();
    (* Get Max Index of Str *)
    MaxIndex := HIGH(Str);
    (* Initialize string to blanks *)
    IF init THEN
    FOR Index := 0 TO MaxIndex DO
      Str[Index] := ' ';
      Write('Û');
    END (* for *);
    END (* if *);
    (* Read string *)
    Index := 0;
    GotoXY( xbegin+MaxIndex+1, y ); Write(')');
    GotoXY( xbegin, y );
    Read(ch);
     IF (ch # EOL) AND init THEN
          ClrEOL;
          GotoXY( xbegin+MaxIndex+1, y ); Write(')');
          GotoXY( xbegin, y );
        END (* if *);
 WHILE (ch # EOL) AND (ch # esc) DO
      x := WhereX();
   IF ch # nul THEN
    IF Index < MaxIndex THEN
      IF ch = bs THEN
          IF Index > 0 THEN  (* cursor position is not at beginning *)
              Write(' ');
              Str[Index] := ' ';
              GotoXY(x-1,y);
              DEC(Index);
           END (* if *);
        ELSE
            Write(ch);
            Str[Index] := ch;
            INC(Index);
       END (* if *);
   ELSE                      (* index equals maxindex *)
       IF ch = bs THEN
            Write(' ');
            GotoXY(x-1,y);
            Str[Index] := ' ';
            DEC(Index);
          ELSE
              Write(ch);
              GotoXY(x,y);
              Str[Index] := ch;
          END (* if *);
     END (* if *);
 ELSE  (* function key was typed *)
       Read(ch);
       CASE ORD(ch) OF
     
        71 : (* Home Key *)
             GotoXY(xbegin, y);
             Index := 0
           |
        75 : (* Left Arrow *)
             IF x > xbegin THEN
             GotoXY(x-1, y);
             DEC(Index);
             END (* if *)
           |
        77 : (* Right Arrow *)
             IF Index < MaxIndex THEN
             GotoXY(x+1, y);
             INC(Index);
             END (* if *)
           |
        79 : (* End Key *)
             GotoXY(xbegin+MaxIndex, y);
             Index := MaxIndex
           |
        83 : (* Delete Key *)
             IF Index < MaxIndex THEN
             Write(' ');
             Str[Index] := ' ';
             INC(Index);
             ELSE
             Write(' ');
             Str[Index] := ' ';
             GotoXY(x, y);
             END (* if *);
           |
       ELSE (* case *)
            Beep;
     END (* case *);
  END (* if *);
   Read(ch);
  END (* while *);
  SetCursor(j,k);
  END ReadStr;

