000100210422         Ctl-Opt NoMain DatFmt(*USA);
000101210414      /COPY LAB10,DAYPROTO
000102210414
000104210414              Dcl-Proc DayNumName EXPORT;
000105210414
000106210414                 Dcl-Pi *n Char(9);
000107210414                   Number Packed(1:0);
000108210414                 END-PI;
000109210414
000110210414                Dcl-DS DayData;
000111210414                  *n Char(9) Inz('Monday');
000112210414                  *n Char(9) Inz('Tuesday');
000113210414                  *n Char(9) Inz('Wednesday');
000114210414                  *n Char(9) Inz('Thursday');
000115210414                  *n Char(9) Inz('Friday');
000116210414                  *n Char(9) Inz('Saturday');
000117210414                  *n Char(9) Inz('Sunday');
000118210414
000119210414                  DayArray Char(9) Dim(7) Pos(1);
000120210414
000121210414                END-DS;
000122210414
000123210414                Return DayArray(Number);
000125210414              END-PROC;
