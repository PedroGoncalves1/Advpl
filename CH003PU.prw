#Include 'totvs.ch'

 /*/{Protheus.doc} CH003PU
Integra o chamado ao trello
@type  Function
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

User Function CH003PU()

    If !ZA1->ZA1_STATUS $ 'A|U|S|O' .or. !ZA1->ZA1_DEPART $ '3|6|8'
        MsgAlert('Chamado deve estar em aberto e pertencer ao departamento análise/desenvolvimento')
    Else
        fMonta()
    Endif

Return


 /*/{Protheus.doc} fMonta
Monta a tela com o chamado e as listas do trello
@type  Function
@author Pedro Carvalho Gonçalves
@since 27/04/2023
@version 12.1.33
/*/

Static Function fMonta()

    Local oTrello := Nil
    Local aLista  := {}
    Local aItems  := {}
    Local cDesc   := Posicione('ZA2',1,xFilial('ZA2')+ZA1->ZA1_CODCHA+'001','ZA2_DETALH')
    Local cTitulo := 'CH ' + ZA1->ZA1_CODCHA + ' - ' + ZA1->ZA1_ASSUNT
    Local cList   := ''
    Local nI      := 0
    Local nOpc    := 1

    SetPrvt("oFont1,oDlg1,oSay1,oSay2,oSay3,oGet1,oCbBox,oMGet1","oBtn1","oBtn2")

    oTrello := CTTRELLO():New()

    If !Empty(aLista := oTrello:GetLista())

        For nI := 1 to Len(aLista)
            aAdd(aItems, aLista[nI][2])
        Next

        oFont1     := TFont():New( "Calibri",0,-16,,.F.,0,,400,.F.,.F.,,,,,, )
        oDlg1      := MSDialog():New( 163,450,681,1244,"Integra Trello",,,.F.,,,,,,.T.,,,.T. )
        oSay1      := TSay():New( 008,020,{||"Título do cartão"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
        oSay2      := TSay():New( 008,240,{||"Lista"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSay3      := TSay():New( 060,024,{||"Descrição do cartão"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
        oGet1      := TGet():New( 020,020,{|u| If(PCount()>0,cTitulo:=u,cTitulo)},oDlg1,172,014,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
        oCbBox     := TComboBox():New( 020,240,{|u| If(PCount()>0,cList:=u,cList)}, aItems, 084,016,oDlg1,,{|| nOpc := aScan(aLista,{|x| x[2] = cList})},,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cList )
        oMGet1     := TMultiGet():New( 076,024,{|u| If(PCount()>0,cDesc:= u,cDesc)},oDlg1,288,160,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
        oBtn1      := TButton():New( 020,348,"Integrar",oDlg1,{||fCriaCar(aLista[nOpc],cTitulo,cDesc,oTrello)},037,012,,,,.T.,,"",,,,.F. )
        oBtn2      := TButton():New( 040,348,"Cancelar",oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )

        oDlg1:Activate()
        
    Endif

Return


/*/{Protheus.doc} fCriaCar
Cria o cartão no trello
@type  Function
@author Pedro Carvalho Gonçalves
@since 28/04/2023
@version 12.1.33
/*/

Static Function fCriaCar(p_aLista,p_cTitulo,p_cDesc,p_oTrello)
    
    If p_oTrello:CriaCard(p_aLista[1],p_cTitulo,p_cDesc)
        oDlg1:End()
        RecLock('ZA1',.F.)
            ZA1->ZA1_STATUS := 'P'
        ZA1->(MsUnlock())
    Endif

Return
