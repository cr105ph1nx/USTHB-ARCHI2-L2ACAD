
;********************************************************;
;                                                        * 
; ON COMMENCE AVEC LE DATA SEGEMENT                      * 
; QUI CONTIENT LES VARIABLES X, Y ANCIEN_CS? ANCIEN_IP   *
; ET TOUS LES MESSAGES QUE L'ON VEUT AFFICHER            *
;                                                        *
;********************************************************;

DATA SEGMENT   
  ; cas OF=0 
   ;X          DW 0001h    
   ;Y          DW 0000h       
                 
  
  ; cas OF=1
   X          DW 8000h             
   Y          DW 8001h    
                       
    Ancien_IP  DW  ?       
    
    Ancien_CS  DW  ?
    
    msg_1 DB 10,13,10,13,"LE PROCESSEUR SIGNALE UN ETAT D'OVERFLOW, Appuyez sur une touche pour continuer$"
    
    msg_2 DB 10,13,10,13,"OPERATION EFFECTUEE SANS ETAT D'OVERFLOW, Appuyez sur une touche pour continuer$"
                                                                   
    msg_TP2          DB "TP 2$"
    
    msg_Archi2       DB "ARCHI 2$"
    
    msg_Addition     DB 10,13,"Appuyer sur une touche pour effectuer l'operation d'addition: $"
    
    msg_Deroutement  DB 10,13,"DEROUTEMENT DE L'INTERRUPTION OVERFLOW$"
    
    msg_Restauration DB 10,13,"OPERATION DE RESTAURATION DU VECTEUR 4 EST TERMINEE$"  
    
    msg_Fin          DB "Tapez sur une touche pour quitter: $"
    
    saut             DB 10,13,"$"               ; VARIABLE QUI VA NOUS AIDER A EFFECTUER DES SAUTS DE LIGNE
    

DATA ENDS

;********************************************************;

; PILE SEGMENT POUR NE PAS AVOIR D'ERREUR 
; OU DE WARNING

;********************************************************;

PILE SEGMENT
   
   DW 128 DUP(?)
   
   TOS LABEL WORD
   
PILE ENDS


;********************************************************;

; DEBUT DU CODE SEGMENT

;********************************************************;

CODE SEGMENT
    
    Assume CS:CODE , DS:DATA , SS:PILE
                          
                          
              ;/********************************************************************************************/            
              ;                                                                                             *
              ;                                                                                             *
              ; AVANT DE COMMENCER L'ECRITURE DES PROCEDURES ET LE PROGRAMME PRINCIPAL DEMANDES DANS LE TP  *     
              ; ON VA DEFINIR QUELQUES PROCEDURES QUI VONT NOU AIDER A OPTIMISER NOTRE CODE                 *
              ;                                                                                             *
              ;                                                                                             *
              ;/********************************************************************************************/            
                          
;********************************************************;
;     PROCEDURE QUI PERMET DE SAUTER UNE LIGNE 
;********************************************************;    
 
    Sauter_Ligne PROC NEAR 
        
        lea DX, saut       
        mov AH, 09h        ; APPEL DE LA FONCTION QUI AFFICHE LES CHAINE DE CARACTERS 
        int 21h            ; EXECUTION DE L'INTERRUPTION 21H
        ret
    Sauter_Ligne ENDP
    
 
;******************************************************************;
; PROCEDURE QUI LIT UN CARACTERE SANS ECHO (APPUYEZ POUR CONTINUER)
;******************************************************************;    
 
    Appuyer PROC NEAR 
        
        mov AH,08h       ; NUMERO DE FONCTION QUI LIT UN CARACTERE SANS ECHO AU CLAVIER
        int 21h          ; APPEL DE L'INTERRUPTION 21H
        ret
        
    Appuyer ENDP
    

    

;*******************************************************************************;
; PROCEDURE QUI PERMET DE DEPLACER LE CURSEUR A UNE LIGNE ET UNE COLONNE DONNEES
;*******************************************************************************;    
 
    Curseur Proc NEAR
        
        mov AH, 2h           ; NUMERO DE LA FONCTION
        mov BH, 0            ; NUMERO DE LA PAGE ECRAN 
        int 10h              ; APPEL DE L'INTERRUPTION
        
                             ; LES DH ET DL (NUM DE COLONNE ET DE LIGNE SERONT REMPLIT AVA?T CHAQUE APPEL A CETTE FONCTION)
                             
        ret
        
    Curseur ENDP
    
 ;                                 /*************************************************************/
 
 
    
;***********************************************************************************************;
;PROCEDURE QUI STOCKE LE CS ET IP DE L'ANCIENNE ROUTINE OVERFLOW DANS DES VARIABLES (QUESTION 1)
;***********************************************************************************************;    
    
    Adresse_Routine Proc NEAR
        
        mov AH, 35h              ; NUMERO DE LA FONCTION DE LECTURE D'UN VECTEUR D'INTERRUPTION
        mov AL, 04h              ; NUMERO DE L'INTERRUPTION QU'ON VEUT LIRE (INTERRUPTION OVERFLOW)
        int 21h            
        
       ; LES CS:IP SERONT RETOURNES DANS ES:BX 
        mov AX, ES               ; METTRE LE CS DANS AX
        mov Ancien_CS, AX        ; LE METTRE DANS SA CASE MEMOIRE RESERVEE
        mov Ancien_IP, BX        ; METTRE IP DANS SA CASE MEMOIRE
        ret
        
    Adresse_Routine ENDP
    
    
;********************************************************;
;CODE DE LA NOUVELLE ROUTINE
;********************************************************;    
   
    maNewRoutine:
   
   ; AFFICHAGE DU MESSAGE_1 " LE PROCESSEUR SIGNALE UN ETAT D'OVERFLOW, appuyer sur une touche pour continuer" 
    lea DX, msg_1           ; METTRE L'@ EFFECTIVE DU PREMIER CARACTERE DU MSG_1 DANS DX
    mov AH, 09h             ; NUMERO DE LA FONCTION QUI AFFICHE LES CHAINES DE CARACTERS
    int 21H                 ; APPEL DE L'INTERRUPTION 21H
    
    CALL Sauter_Ligne       ; SAUTER UNE LIGNE
    CALL Appuyer            ; LIRE UN CARACTERE SANS ECHO POUR CONTINUER
    
    IRET
    
    
;********************************************************;

;PROCEDURE QUI DEROUTE L'INTERRUPTION OVERFLOW 
; SUR LA ROUTINE maNewRoutine (QUESTION 2)    

;********************************************************;    
   
    Derouter PROC NEAR
       
      ; AFFICHER UN MESSAGE AVANT LE DEROUTEMENT "DEROUTEMENT DE L'INTERRUPTION OVERFLOW"  
        CALL Sauter_Ligne                    ; SAUTER UNE LIGNE
        CALL Sauter_Ligne                    ; SAUTER UNE LIGNE
        
        mov DX, offset msg_Deroutement       ; METTRE L'@ EFFECTIVE DU PREMIER CARACTERE DU MSG_DEROUTEMENT DANS DX
        mov AH, 09h                          ; NUMERO DE LA FONCTION QUI AFFICHE LES CHAINES DE CARACTERS
        int 21h                              ; APPEL DE L'INTERRUPTION 21H
       
       
      ; PROCEDER AU DEROUTEMENT DE L'INTERRUPTION OVERFLOW  
        mov AX, seg maNewRoutine             ; METTRE '@ SEGMENT DE maNewRoutine DANS DS
        mov DS, AX 
        
        mov DX, offset maNewRoutine          ; METTRE L'@ EFFECTIVE DE maNewRoutine DANS DX
        
        mov AH, 25h                          ; NUMERO DE LA FONCTION DE DEROUTEMENT
        mov AL, 04h                          ; NUMERO DE L'INTERRUPTION QU'ON VEUT DEROUTER (INTERRUPTION OVERFLOW) 
        int 21h                              ; APPEL A L'INTERRUPTION 21H
        
        mov AX, DATA                         ; REMETTRE DATA DANS LE REGISTRE SEGMENT
        mov DS,AX       
        
        RET
        
    Derouter ENDP
    
    
;*******************************************************************;

;PROCEDURE APPELEE EN CAS DE OF=0 AFFICHE LE MESSAGE_2 (QUESTION 3)

;*******************************************************************;    
   
    No_Overflow PROC NEAR 
        
        CALL Sauter_Ligne                    ; SAUTER UNE LIGNE
        CALL Sauter_Ligne                    ; SAUTER UNE LIGNE
     
     ; AFFICHER LE MESSAGE 2 EN CAS DE NON OVERFLOW "OPERATION EFFECTUEE SANS ERREUR D'OVERFLOW, Appuyer sur une touche pour continuer"   
        lea DX, msg_2       ; METTRE L'@ EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE 2 DANS DX                                                                                    
        mov AH, 09h         ; NUMERO DE LA FONCTION D'AFFICHAGE DE CHAINE DE CARACTERS
        int 21h             ; APPEL A L'INTERRUPTION 21H
        
        CALL Sauter_Ligne
        CALL Appuyer      
        
        RET
        
    No_Overflow ENDP
    
    
;********************************************************;
;PROCEDURE QUI EFFECTUE L'ADDITION  (QUESTION 4)
;********************************************************;    
   
    Addition PROC NEAR
        
        lea DX, msg_Addition         ; afficher le message avant d'effectuer l'operation d'addition
        mov AH, 09h
        int 21h

        Call Appuyer                 ; appuyer sur une touche pour effectuer l'operation
        
        mov AX, X                    
        ADD AX, Y
        
        RET
        
    Addition ENDP
    
    
    
;********************************************************;
;PROCEDURE DE RESTAURATION DE L'ANCIENNE ROUTINE OF
;********************************************************;    
   
    Restaurer PROC NEAR
     
     ; POUR RESTAURER L'ANCIENNE ROUTINE OVERFLOW ON VA REFAIRE UN DEROUTEMENT DE LA ROUTINE NUMERO 4
        
        mov AX, Ancien_CS             ; METTRE L'ANCIEN CS DANS DS
        mov DS, AX
        
        mov DX, Ancien_IP             ; METTRE L'ANCIEN IP DANS DX
        mov AH, 25h                   ; NUMERO DE LA FONCTION DE DEROUTEMENT
        mov AL, 04h                   ; NUMERO DE L'INTERRUPTION QU'ON VEUT DEROUTER (OVERFLOW)
        int 21h
                                      ; REMETTRE DATA DANS LE REGISTRE SEGMENT
        mov AX, DATA
        mov DS, AX
        
        mov DX, offset msg_Restauration     ; AFFICHER LE MESSAGE DE RESTAURATION
        mov AH, 09h
        int 21h
        
       CALL Sauter_Ligne
          
        RET
        
    Restaurer ENDP
    
    
;********************************************************;

;DEBUT DU PROGRAMME PRINCIPAL

;********************************************************;   


Start: 

    ; ACCEDER AUX REGISTRES:
    
      mov AX, DATA
      mov DS,AX
      mov AX,PILE
      mov SS,AX
      mov SP,OFFSET TOS
      
    ; POSITIONNER LE CURSEUR A LA COLONNE 70 LIGNE 1   
      mov DH,1                    ; NUMERO DE LIGNE
      mov DL,70                   ; NUMERO DE COLONNE
      CALL Curseur                ; APPELLE DE LA PROCEDURE QUI POSITIONNE LE CURSEUR
     
    ;AFFICHAGE DU MESSAGE "ARCHI 2"  
      mov DX, offset msg_Archi2   ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE   
      mov AH, 09h                 ; NUMERO DE LA FONCTION
      int 21h                     ; APPEL DE L'INTERRUPTION
      
    ; POSITIONNER LE CURSEUR A LA COLONNE 35 LIGNE 3
      mov DH, 3                   ; NUMERO DE LIGNE
      mov DL, 35                  ; NUMERO DE COLONNE
      CALL Curseur                ; APPEL DE LA FONCTION
      
    ; AFFICHAGE DU MESSAGE "TP 2"
      mov DX, offset msg_TP2      ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE
      mov AH, 09h                 ; NUMERO DE LA FONCTIOIN D'AFFICHAGE DE CHAINE DE CARACTERES
      int 21h                     ; APPEL DE L'INTERRUPTION
     
    ; FAIRE DEUX SAUTS DE LIGNE 
      CALL Sauter_Ligne
      CALL Sauter_Ligne
    
    
    ; EFFECTUER L'OPERATION D'ADDITION  
    
      CALL Addition 
    
    
    ; TEST DU FLAG OF: 
      Pushf              ; EMPILER LA VALEUR DU PSW DANS LA PILE
     
      pop AX             ; DEPILER LA VALEUR DU PSW DANS AX
      
      Test AX, 0800h     ; TESTER SI LE FLAG OF=1 OU NON 
                         ; LE TEST FAIT LE TRAVAIL DE AND SANS GARDER LE RESULTAT, SEUL LES FLAGS SONT AFFECTES
                         ; ON VA MULTIPLIER TOUS LES FLAGS PAR 0 SAUF OF ON LE MULTIPLIE PAR 1
                         ; DONC SI ON TROUVE QUE LE PSW=0 ALORS OF=0 SINON OF=1
      
      JNZ OF_NotZERO     ; SI OF=1 ALORS ON SAUTE VERS L'ETIQUETTE OF_NotZERO
      
      CALL No_Overflow   ; SINON (OF=0) ON APPELLE LA PROCEDURE DE LA QUESTION 03
                         ; QUI AFFICHE LE MSG_2 "OPERATION EFFECTUEE SANS ERREUR D'OVERFLOW, Appuyer sur une touche pour continuer" 
      jmp fin            ; PUIS ON SAUTE VERS LA FIN DU PROGRAMME
        
      OF_NotZERO:        ; SI OF=1  
      
      CALL Adresse_Routine ; ON STOCKE LES @ INITIALES DES CS ET IP DANS LA MEMOIRE
   
      CALL Derouter      ;ON APPELLE LA PROCEDURE QUI DEROUTE L'INTERRUPTION OVERFLOW SUR LA NOUVELLE ROUTINE CREE maNewRoutine
      
      int 4              ; ON FAIT APPEL A L'INTERRUPTION OVERFLOW NUMERO 4 (QUI CONTIENT LA NOUVELLE ROUTINE INSTALLEE)
                         ; PAS BESOIN DE FAIRE INTO CAR ON A DEJA TESTE LA VALEUR DU OF AU DESSUS      
                         ; PUISQU'ON EST SURS QUE OF=1 ALORS ON APPELLE DIRECTEMENT L'INTERRUPTION SANS REFAIRE LE TEST UNE NOUVELLE FOIS
                         ; LA NOUVELLE ROUTINE AFFICHE LE MESSAGE_1 "LE PROCESSEUR SIGNALE UN ETAT D'OVERFLOW, Appuyer sur une touche pour continuer" 
      CALL Appuyer
      
      CALL Restaurer     ; ON RESTAURE L'ANCIENNE ROUTINE OVERFLOW 
                         ; EN UTILISANT LES VARIABLES ANCIEN_IP ET ANCIEN_CS
                         

       
      fin:               ; ON APPROCHE A LA FIN DU PROGRAMME...
       
      ; POSITIONNER LE CURSEUR 
      
      mov Dh, 20         ; NUMERO DE LIGNE 
      MOV dl, 40         ; NUMERO DE COLONNE
      CALL Curseur       ; APPPEL DE LA FONCTION QUI POSITIONNE LE CURSEUR
      
     ; AFFICHER LE MESSAGE DE FIN: " TAPEZ SUR UNE TOUCHE POUR QUITTER:" 
      
      mov DX, offset msg_Fin    ; METTRE L'@ EFFECTIVE DU PREMIER CARACTERE DU MESSAGE DE FIN DANS DX
      mov AH, 09h               ; NUMERO DE LA FONCTION D'AFFICHAGE 
      int 21h                   ; APPEL A L'INTERRUPTION 21H
      
      CALL Appuyer              ; APPUYER SUR UNE TOUCHE POUR CONTINUER
           
     
      mov AX, 4C00h             ; SORTIR DU SYSTEM
      int 21h
      
      
CODE ENDS

END START      
            
      
      
      
     
          
        
        