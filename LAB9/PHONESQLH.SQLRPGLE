000100190313         // **************************************************************************
000200200326        //  CUSTOMER20 READ BY NATIVE LANGUAGE (ILE RPG)
000300200709        //  CONTACTS20 ROW RETRIEVED WITH EMBEDDED SQL
000400200709        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER20 AND CONTACTS20
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000600190314
000700190313           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
000800200326           DCL-F CUSTOMER20 DISK(*EXT) KEYED USAGE(*INPUT)
000900200326                 RENAME(CUSTOMER20:CUSTR);
001000200709                      // data structure for host variables from CONTACTS20
001100210331                       DCL-DS CONTACTS20 EXT END-DS;
001200190314                     // Standalone fields for indicator variables
001300210331                       DCL-S INDLastCDate BINDEC(4:0);
001400210331                       DCL-S INDNextCDate BINDEC(4:0);
001500190314
001600190314           DCL-S Dummy  Zoned(1);
001700190314
001800190314        //**************************************************************************
001900190314        //*                        ***   M A I N   R O U T I N E   ***
002000190314        //**************************************************************************
002100190314
002200070119                EXSR SummaryInfo;
002300200709                WRITE NEWPAGE;
002400200326                READ CUSTOMER20;
002500070119                DOW NOT %EOF;
002600070119                    EXSR SQLSelect;
002700190313                    IF *IN01 = *ON;
002800200709                       Write NEWPAGE;
002900190313                       *IN01 = *OFF;
003000070119                    ENDIF;
003100200709                    Write RPTLINE;
003200200326                   READ CUSTOMER20;
003300070119                ENDDO;
003400190313                Write SUMMARY;
003500070119                *INLR = *ON;
003600070119                RETURN;
003700080923        //**********************************************************************
003800080923        //   S Q L S E L E C T   S U B R O U T I N E
003900080923   //   //********************************************************************
004000080923   //                  BEGSR    SQLSelect ;
004100080923   //    // A row from the contacts table that has the same customer number as t
004200200326   //    // read from the CUSTOMER20 file is retrieved to find out the last date
004300080923   //    // phone number, comments and the salesperson number.
004400080923   //
004500080923   //    //  The call back interval is added to the last date called to determin
004600080923   //    //  next date to call.  Since null values may be stored in the last dat
004700080923   //    // indicator variables are used.
004800190314
004900210331             EXEC SQL
005000190314
005100210401                SELECT  CSTLASTCALLDATE + CSTCALLBACKINT DAYS, CSTLASTCALLDATE,
005101210401                  CSTPHONE, COMMENTS, CSTSALESNUMBER
005103210401                INTO :NEXTCDATE :INDNEXTCDATE,
005105210401                     :PHNLDC :INDLASTCDATE,
005106210401                     :CSTPHN,
005107210401                     :PHNCOM,
005108210401                     :CSTSLN
005109210401
005110210401
005111210331                FROM BCI433LIB/CONTACTS20
005112210331                WHERE CSTNUM = :CSTNUM;
005113210331
005114210331               SELECT;
005115210331
005116210331                WHEN SQLSTATE = '00000';
005117210331                  DUMMY = 0;
005118210331
005119210331                WHEN SQLSTATE = '02000';
005120210401                  CSTPHN = 'NOT FOUND';
005121210331                  NEXTCDATE = D'9999-09-09';
005122210331                  PHNLDC = D'9999-09-09';
005123210331                  PHNCOM    = *ALL'*';
005124210331                  CSTSLN = *ALL'*';
005125210331
005126210331                WHEN %SUBST(SQLSTATE :1 :2) = '01';
005127210401                  CSTPHN = 'WARNING';
005128210331                  NEXTCDATE = D'9999-09-09';
005129210331                  PHNLDC = D'9999-09-09';
005130210331                  PHNCOM    = *ALL'*';
005131210331                  CSTSLN = *ALL'*';
005132210331
005133210331               OTHER;
005134210331                  CSTPHN = 'ERROR';
005135210331                  NEXTCDATE = D'9999-09-09';
005136210331                  PHNLDC = D'9999-09-09';
005137210331                  PHNCOM    = *ALL'*';
005138210331                  CSTSLN = *ALL'*';
005139210331
005200210331                ENDSL;
005300190314
005400190314
005401210331                 IF INDLASTCDATE = -1;
005402210331                    CSTPHN = 'UNKNOWN DATE';
005403210331                    NEXTCDATE = D'9999-09-09';
005404210331                    PHNLDC    = D'9999-09-09';
005405210331                ELSE;
005500190314
005600190314
005700210331                 IF INDLASTCDATE <> 0;
005701210331                   CSTPHN = 'DATE PROBLEM';
005702210331                    NEXTCDATE = D'9999-09-09';
005703210331                    PHNLDC    = D'9999-09-09';
005704210331                 ENDIF;
005900210331                ENDIF;
006000190314
006100190314
006200210331                IF PHNLDC = OLDESTDATE;
006201210331                   HIGHLIGHT = '<------';
006202210331                ELSE;
006203210331                    HIGHLIGHT = '';
006204210331                ENDIF;
006900210331         ENDSR ;
006901210331
007000080923        //**********************************************************************
007100080923        // S U M M A R Y I N F O   S U B R O U T I N E
007200080923        //**********************************************************************
007300080923                         BEGSR  SummaryInfo;
007400200709        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS20 & CUSTOMER20
007500190314
007600210331              EXEC SQL
007700210331              SELECT COUNT(*) INTO :CONTACTT
007701210331                FROM BCI433LIB/CONTACTS20;
007702210331              IF (SQLCODE <> 0) OR (SQLWN0 ='W');
007703210331                  CONTACTT = -99999;
007704210331              ENDIF;
007800190314
007900190314
008000190314
008100190314
008200210331              EXEC SQL
008201210331                 SELECT COUNT(*) INTO :CUSTOMERT
008202210331                   FROM BCI433LIB/CUSTOMER20;
008203210331              IF (SQLCODE <> 0) OR (SQLWN0 ='W');
008204210331                CUSTOMERT = -99999;
008205210331              ENDIF;
008300190314
008400190314
008500190314
008600190314
008700190314
008800190314
008900190314
009000190314        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED
009100190314
009200210331                EXEC SQL
009300190314
009400210331                    SELECT COUNT(*)  INTO :UNKNOWNT
009500210331                    FROM BCI433LIB/CONTACTS20
009600210331                    WHERE CSTLASTCALLDATE IS NULL;
009700190314
009800210331                   IF NOT(SQLCODE = 0) OR (SQLWN0='W');
009801210331                     UNKNOWNT = -99999;
009802210331                   ENDIF;
009900190314
010000190314
010100080923        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
010200210331               EXEC SQL
010201210331                 SELECT MIN(PHNLDC)
010202210331                   INTO:OLDESTDATE
010203210331                   FROM BCI433LIB/CONTACTS20;
010204210331
010205210331               IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');
010500210331                      OLDESTDATE = D'9999-09-09';
010501210331
010600210331               ENDIF;
010700190314
010800190314
010900190314
011000210331               EXEC SQL
011001210331                 SELECT MAX(PHNLDC)
011002210331                   INTO:MOSTRECENT
011003210331                    FROM BCI433LIB/CONTACTS20;
011004210331                SELECT;
011005210331                  WHEN SQLWN2 = 'W';
011006210331                    WHEN NOT(SQLCODE = 0) OR (SQLWN0 ='W');
011007210331                      MOSTRECENT  = D'9999-09-09';
011008210331                ENDSL;
011100190314
011200190314
011300190314
011400190314
011500190314
011600190314
011700190314
011800190314
011900190314
012000190314
012100080923       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
012200080923
012300210331                   EXEC SQL
012400210331                   SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
012500210331                     INTO     :USER,  :TIMESTAMP,      :SERVER
012600210331                      FROM    SYSIBM/SYSDUMMY1;
012700190314
012800080923                         ENDSR;
