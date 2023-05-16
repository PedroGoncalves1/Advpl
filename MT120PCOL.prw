 #Include 'TOTVS.ch'
 
 /*/{Protheus.doc} MT120PCOL
Esse P.E é chamado toda vez que o usuário prosseguir para a próxima linha ou tentar incluir um pedido de compra
@type  Function
@author Pedro Carvalho Gonçalves
@since 10/11/2022
@return logical, se verdadeiro (.T.) , prosseguirá para o próximo item e será permitido a inclusão do pedido de compra
@see https://tdn.totvs.com/display/public/PROT/MT120PCOL+-+Valida+Pedido+de+Compra+Item+a+Item
@param nOper , 1 = Valida a linha , 2 = Valida a inclusao
/*/

User Function MT120PCOL()

   Local nX        := 0
   Local nPosProd  := aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="C7_PRODUTO"})
   Local nPosAlias := aScan(aHeader, {|x| Alltrim(Upper(x[2]))=="C7_ALI_WT"}) 
   Local nOper     := ParamIXB[1]
   Local lRet      := .T.
   Local lCopia    := IsInCallStack('A120Copia')
   Local lAcesso   := U_GE002P('MV_ALTPME','G000000',__cUserID) // Retorna true caso o usuário pertença ao parametro
   
        If !IsInCallStack('U_CP028P') .and. !IsBlind() .and. !lAcesso

            If Inclui .and. !lCopia
                For nX := 1 to Len(aCols)
                    If !aCols[nX,Len(aCols[nX])] 
                        lRet := fValidPrd(aCols[nX,nPosProd]) 
                    Endif
                Next
            Endif

            If Altera .or. lCopia
                
                If nOper = 2 
                    For nX := 1 to Len(aCols)
                        If !aCols[nX,Len(aCols[nX])]
                            lRet := fValidPrd(aCols[nX,nPosProd])
                                If !lRet
                                    Exit
                                Endif
                        Endif
                    Next
                Else

                    If Empty(aCols[Len(aCols),nPosAlias]) .and. !aCols[Len(aCols),Len(aCols[Len(aCols)])] 
                        For nX := 1 to Len(aCols)
                            If !aCols[nX,Len(aCols[nX])]
                                lRet := fValidPrd(aCols[nX,nPosProd])
                                If !lRet
                                    Exit
                                Endif
                            Endif
                        Next
                    Endif

                Endif

            Endif

        Endif

Return lRet

/*/{Protheus.doc} fValidPrd
Valida se o tipo do produto é diferente de ME
@type Function
@author Pedro Carvalho Gonçalves
@since 10/11/2022
@version 12.1.33
@return logical, falso(.F.) caso o tipo seja igual a ME
/*/

User Function fValidPrd(p_cProd)
    
    Local lRet  := .T.
    Local aArea := GetArea()

    If Posicione('SB1', 1, xFilial('SB1') + p_cProd, 'B1_TIPO') = "ME"
        MsgAlert("Só é permitida a inclusão manual de itens para consumo próprio!","Atenção - MT120PCOL")
        lRet := .F.
    Endif

    RestArea(aArea)

Return lRet
