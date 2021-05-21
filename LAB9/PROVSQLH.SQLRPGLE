000100190313       //**************************************************************************
000200191105       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300191105       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
000400191105       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED FROM THE 3 TABLES
000500190313       //**************************************************************************
000600190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000700190313           DCL-S ProvinceH    Char(10);
000800190313           DCL-S EndOfFile    IND;
000900190313           DCL-S TotalRecords PACKED(5:0) ;
001000190315             // LowLimit is passed to the program
001100190315
001200210405           Dcl-PI Main extPgm('PROVSQLH');
001201210405             LowLimitIn Packed(15:5) ;
001202210405           END-PI;
001300190315
001400190315             // All Host Variables available under a single name
001500190315
001600210405           DCL-DS CustomerRecord;
001700210405           CustId    Char(6);
001800210405           FullName  Char(31);
001900210405           City      Char(20);
002000210405           Purchase  Packed(7:2);
002100210405           PDate     Date;
002101210405           Province  Char(10);
002200190313        End-Ds CustomerRecord;
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002701210405                LowLimit = LowLimitIn;
002800100309                EXSR PrepareFiles;
002900200709                Write ReportHdg;
003000200709                Write RColumns;
003100100309                EXSR GetRow;
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600210401                        Write ReportHdg;
003700210401                        Write RColumns;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
004000190315                    // Province may change
004100210405                      If ProvinceH = Province;
004200210405                           Write Detail;
004300190315
004400210405                      Else;
004500190315
004600210405                          ProvinceH = Province;
004700210405                           Write Totals;
004800210405                           TotalPurch = 0;
004900210405                            Write NewProv;
005000210405                            Write Detail;
005100210405                       ENDIF;
005200190313                    TotalPurch     = TotalPurch     + Purchase;
005300070202                    TotalRecords= TotalRecords + 1;
005400100309                    EXSR GetRow;
005500070119                ENDDO;
005600190313                Write Totals;
005700070202                EXSR   WRAPUP;
005800190313                Write UnderLimit;
005900070119                *INLR = *ON;
006000070119                RETURN;
006100100309        //**********************************************************************
006200100309        // O P E N F I L E S   S U B R O U T I N E
006300100309        //**********************************************************************
006400100309         BEGSR  PrepareFiles;
006500190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006600190315
006700210405            EXEC SQL
006800210405              DECLARE ALLPROVCURSOR CURSOR
006801210405                FOR
006802210405                 SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
006900210405                        City, Purchase, PDate,
007000210405                        'Ontario' as Province
007100210405                 FROM BCI433LIB/ONTARIO
007200210405                 WHERE Purchase > :LowLimit
007300210405                 union all
007400190315
007500210405                 SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
007600210405                        City, Purchase, PDate,
007700210405                        'Quebec' as Province
007800210405                 FROM BCI433LIB/QUEBEC
007801210405                 WHERE Purchase > :LowLimit
007802210405                 union all
007900190315
008000210405                 SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
008001210405                        City, Purchase, PDate,
008100210405                        'Manitoba' as Province
008200190315
008300210405                 FROM BCI433LIB/MANITOBA
008400210405                 WHERE Purchase > :LowLimit
008500190315
008600210405                FOR READ ONLY;
008700190315
008800100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
008900210405               EXEC SQL
009000210405                  OPEN ALLPROVCURSOR;
009100210405                     If (SQLCODE <> 0) OR (SQLWN0 = 'W');
009200210405                        EndOfFile = *ON;
009300210405                     ENDIF;
009400190315
009500190315
009600100309            ENDSR;
009700100309        //**********************************************************************
009800100309        //   G E T     R O W    S U B R O U T I N E
009900100309        //**********************************************************************
010000100309            BEGSR     GETROW;
010100100309
010200210405                  EXEC SQL
010201210405                    FETCH NEXT
010202210405                      FROM ALLPROVCURSOR
010203210405                       INTO :CustomerRecord;
010204210405                  If (SQLCODE <> 0) OR (SQLWN0 = 'W');
010205210405                    EndOfFile = *ON;
010206210405                  ENDIF;
010207210405
011100100309             ENDSR;
011200100309        //**********************************************************************
011300100309        // W R A P U P     S U B R O U T I N E
011400100309        //**********************************************************************
011500100309           BEGSR WRAPUP;
011501210405             EXEC  SQL
011502210405              CLOSE ALLPROVCURSOR;
011503210405
011504210405             If (SQLCODE <> 0) OR (SQLWN0 = 'W');
011505210405                    EndOfFile = *ON;
011506210405             ENDIF;
011507210405
011508210405             EXEC SQL
011509210405               SELECT COUNT(*) INTO :ONTTOTAL
011510210405                  FROM BCI433LIB/ONTARIO
011511210405                    WHERE Purchase <= :LowLimit;
011512210405             EXEC SQL
011513210405               SELECT COUNT(*) INTO :QUETOTAL
011514210405                 FROM BCI433LIB/QUEBEC
011515210405                  WHERE Purchase <= :LowLimit;
011516210405
011517210405
011518210405             EXEC SQL
011519210405               SELECT COUNT(*) INTO :MANTOTAL
011520210405                 FROM BCI433LIB/MANITOBA
011521210405                  WHERE Purchase <= :LowLimit;
011600100309          ENDSR;
011700190315
011800190315
011900190315
012000190315
012100190315
012200190315
012300190315
012400190315
012500190315
012600190315
012700190315
012800190315
012900190315
013000190315
013100190315
