-- SELECT * FROM [dbo].[OJDT] T0 

declare @OpenDate as datetime 
declare @OpenDate2 as datetime 
declare @FTaxDate as datetime 
declare @TTaxDate as datetime 
declare @TransID1 as int 

/* WHERE */ 
set @OpenDate = /* T0.[RefDate] */ N'[%0]'
set @OpenDate2 = /* T0.[RefDate] */ N'[%1]'
set @FTaxDate = /* T0.[TaxDate] */ N'[%2]'
set @TTaxDate = /* T0.[TaxDate] */ N'[%3]'
set @TransID1 = /* T0.[TransID] */ '[%4]'

SELECT 
      T0.[TransId] AS 'TransId',
      CASE 
          when T0.TransType =18 then T2.U_Company 
          else '30' 
      END AS 'Company',
      CASE 
          when T0.TransType =18 then T2.U_Dept
          else Right(LEFT (T1.U_Account, 8),4) 
      END AS 'Department',
      CASE 
          when T3.CardType = 'S'          
          then '21005' 
          else T1.[ShortName] 
      END AS 'Account',
      CASE 
        when T0.TransType =18 then T2.U_Product 
        else Right(LEFT (T1.U_Account, 0),3) 
      end AS 'Product', 
      'Future'= '0000',
      T1.[Debit] AS 'Debit', 
      T1.[Credit] AS 'Credit',
      T1.[U_RportNum] AS 'Line Description',
      T2.[U_NPO] AS 'PO number',
      T1.ContraAct AS 'ContraAct',
      T0.TaxDate AS 'Tax Date',
      T0.RefDate AS 'Invoice Date'
FROM OJDT T0  
  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId] 
  LEFT JOIN (
             select distinct TransId  ,u_company ,U_location ,U_Dept, U_Product, [U_NPO] , PCH1.Acctcode
             from OPCH 
                inner join PCH1  on PCH1.DocEntry = OPCH.DocEntry  
            ) T2 ON T0.[TransId] = T2.[TransId] AND T2.Acctcode = T1.ShortName
  LEFT JOIN OCRD T3 ON T1.ShortName = T3.CardCode 
WHERE T0.TransType <> 13
AND T0.TransType <> 24
AND T0.TransType <> 14
AND (T0.RefDate >= @OpenDate or @OpenDate  = N'')
AND  (T0.RefDate <= @OpenDate2 or @OpenDate2 = N'')
AND (T0.TaxDate >= @FTaxDate or @FTaxDate  = N'')
AND  (T0.TaxDate <= @TTaxDate or @TTaxDate = N'')
AND (T1.ShortName in (select CardCode from OCRD where CardType='S') or (T1.ShortName in (select AcctCode from OACT )))
AND (T1.ContraAct in (select CardCode from OCRD where CardType ='S')or (T1.ContraAct in (select AcctCode from OACT )))
AND (T0.TransID >= @TransID1 or @TransID1  = N'')
ORDER BY T0.TransId