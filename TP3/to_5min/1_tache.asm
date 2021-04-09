;********************************************************;
;                                                        * 
; ON COMMENCE AVEC LE DATA SEGEMENT                      * 
; TOUS LES MESSAGES QUE L'ON VEUT AFFICHER               *
; AINSI QUE LE COMPTEUR cpt_exit                         *
;                                                        *
;********************************************************;
data segment
    prompt db "deroutement fait...",10,13,"$"
    message  db 10,13,10,13, "'**** Programme principal en cours ****$"
    ch1 db "oh la 1ch!...... $"
    cpt_exit dw 0
data ends

;********************************************************;

; stack SEGMENT POUR NE PAS AVOIR D'ERREUR 
; OU DE WARNING

;********************************************************;
stack segment stack "stack"
    dw 128 dup(?)
    TOP label word
stack ends

;********************************************************;

; DEBUT DU CODE SEGMENT

;********************************************************;
code segment
    assume cs: code, ds: data, ss: stack
              ;/********************************************************************************************/            
              ;                                                                                             *
              ;                                                                                             *
              ; AVANT DE COMMENCER L'ECRITURE DES PROCEDURES ET LE PROGRAMME PRINCIPAL DEMANDES DANS LE TP  *     
              ; ON VA DEFINIR QUELQUES PROCEDURES QUI VONT NOU AIDER A OPTIMISER NOTRE CODE                 *
              ;                                                                                             *
              ;                                                                                             *
              ;/********************************************************************************************/ 

;********************************************************************************************;
;     PROCEDURE QUI PERMET D'AFFICHER UN MESSAGE (PREND CONTENU DE DX COMME PARAMETRE)
;********************************************************************************************;               
output proc near
        mov ah,09       ; NUMERO DE LA FONCTION QUI AFFICHE LES CHAINES DE CARACTERS
        int 21h         ; EXECUTION DE L'INTERRUPTION 21H
        ret             ; RETOURNER AU MAIN
output endp

;********************************************************;
; CODE DE LA NOUVELLE ROUTINE
;********************************************************;
new_routine proc near
        cmp bl, 3Dh             ; TESTER LA VALEUR DE BL AVEC 3DH
        jl no_output            ; SI BL < 3DH, SAUTER A L'ETIQUETTE no_output (NE PAS AFFICHER MESSAGE "oh la 1ch!......."
        push dx                 ; SINON ( BL = 3DH) QUI VEUT DIRE QU'UNE SECONDE S'EST ECOULE, CONTINUER DANS LA PROCEDURE ET 
                                ; EMPILER LA VALEUR DE DX DANS LA PILE POUR SAUVEGARDER SON CONTENU
        
        ; AFFICHAGE DU MESSAGE "oh la 1ch!......"
        mov dx, offset ch1      ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE ch1
        call output             ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE ch1
        
        mov bl, 0H              ; INTIALIZER LA VALEUR DE BL A ZERO
        inc cpt_exit            ; INCREMENTER LA VALEUR DU COMPTEUR cpt_exit 
        
        pop dx                  ; DEPILER LA VALEUR DE DX DE LA PILE ET RECUPERER SON ETAT A L'ENTREE DE LA PROCEDURE
        
        no_output: iret
new_routine endp

;********************************************************;

; PROCEDURE QUI DEROUTE L'INTERRUPTION 1CH 
; SUR LA ROUTINE new_routine   

;********************************************************;
deroute proc near
        push ds                    ; EMPILER LA VALEUR DE DS DANS LA PILE POUR SAUVEGARDER SON CONTENU
        mov ax, cs                 ; METTRE l'@ SEGMENT DU CODE SEGMENT DANS DS 
        mov ds, ax                 
            
        ; PROCEDER AU DEROUTEMENT DE L'INTERRUPTION 1CH      
        mov dx, offset new_routine ; METTRE L'@ EFFECTIVW DE new_routine DANS DX
        mov ah, 25H                ; NUMERO DE LA FONCTION DE DEROUTEMENT
        mov al, 1CH                ; NUMERO DE L'INTERRUPTION QU'ON VEUT DEROUTER (INTERRUPTION 1CH) 
        int 21H                    ; DEROUTER EN FAISANT APPEL A L'INTERRUPTION 21H
        
        pop ds                     ; DEPILER LA VALEUR DE DS DE LA PILE ET RECUPERER SON ETAT A L'ENTREE DE LA PROCEDURE
        
        ; AFFICHER LE MESSAGE "deroutement fait..." POUR INDIQUER LA FIN DU DEROUTEMENT
        mov dx,offset prompt       ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE prompt
        call output                ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE prompt
        
        ret
deroute endp

;********************************************************;

; DEBUT DU PROGRAMME PRINCIPAL

;********************************************************; 
start:
        ; ACCEDER AUX REGISTRES:
        mov ax, data
        mov ds, ax
        mov ax , stack
        mov ss, ax
        mov sp, TOP
        
        ; CLEAR SCREEN A L'AIDE DE L'INTERRUPTION 10H
        mov ax, 3 ; FONCTION QUI OBTIENT LA POSITION ET LA FORME DU CURSEUR
        int 10H   ; EXECUTER L'INTERRUPTION 10H
        
        ; ON APPELLE LA PROCEDURE QUI DEROUTE L'INTERRUPTION 1CH SUR LA NOUVELLE ROUTINE CREE new_routine
        call deroute
        
        ; INITIALIZER LA VALEUR DE BL A 0 (SERT A COMPTER SI UNE SECONDE S'EST ECOULE) 
        ; ET DE BH A 0 (COMPTEUR 5 MINUTES)
        mov bl, 0
        mov bh, 0   

    new_tache:  
        ; NOUVELLE TACHE, AFFICHER LE MESSAGE "***Programme principal en cours***"
        mov dx, offset message   ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE message
        call output              ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE message
           
        mov cx, 3C0H             ; INITIALIZER LA VALEUR DE CX A 3C0H (CX SERVIRA COMME COMPTEUR)
        
    boucle_externe:    
        inc bl                  ; INCREMENTER BL
        mov ax, 3d09H           ; INITIALIZER LA VALEUR DE AX A 3D09H (AX SERVIVRA COMME COMPTEUR)
        
        cmp cpt_exit, 1f4h      ; COMPARER LA VALEUR DE cpt_exit ET 1f4H
        jnl exit                ; SI cpt_exit = 12CH (5 MINUTES SE SONT ECOULES), SAUTER A L'ETIQUETTE exit POUR SORITR DU PROGRAMME
        
    boucle_interne: 
        dec ax                  ; DECREMENTER AX 
        jnz boucle_interne      ; SI AX > 0 ALORS ON SAUTE VERS L'ETIQUETTE boucle_interne
        loop boucle_externe     ; SINON (AX = 0) ON LOOP SUR L'ETIQUETTE boucle_externe POUR INCREMENTER BL ET REINITIAIZER
                                ; LA VALEUR DU COMPTEUR AX
        jmp new_tache           ; PUIS ON SAUTE VERS L'ETIQUETTE new_tache POUR REAFFICHER LE MESSAGE message ET REINITIALIZER
                                ; LES COMPTEURS

    exit:   
        mov ax, 4c00h           ; SORTIR DU SYSTEM
        int 21h     

code ends
    
        end start       ; SORTIR DU SYSTEME
