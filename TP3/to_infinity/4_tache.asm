;********************************************************;
;                                                        * 
; ON COMMENCE AVEC LE DATA SEGEMENT                      * 
; TOUS LES MESSAGES QUE L'ON VEUT AFFICHER               *
;                                                        *
;********************************************************;
data segment
    tache1 db "tache1 en cours d'execution...",10,13,"$"
    tache2 db "tache2 en cours d'execution...",10,13,"$"
    tache3 db "tache3 en cours d'execution...",10,13,"$"
    tache4 db "tache4 en cours d'execution...",10,13,10,13,"$"
    prompt db "deroutement fait...",10,13,10,13,"$"
data ends

;********************************************************;

; DEBUT DU CODE SEGMENT

;********************************************************;
code segment
    assume cs: code, ds: data
    
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
        mov ah, 09      ; NUMERO DE LA FONCTION QUI AFFICHE LES CHAINES DE CARACTERS
        int 21h         ; EXECUTION DE L'INTERRUPTION 21H
        ret             ; RETOURNER AU MAIN
output endp

;********************************************************;

; PROCEDURE QUI DEROUTE L'INTERRUPTION 1CH 
; SUR LA ROUTINE new_routine   

;********************************************************;     
deroute proc near
        push ds                       ; EMPILER LA VALEUR DE DS DANS LA PILE POUR SAUVEGARDER SON CONTENU
        mov ax, cs                    ; METTRE l'@ SEGMENT DU CODE SEGMENT DANS DS 
        mov ds, ax
        
        ; PROCEDER AU DEROUTEMENT DE L'INTERRUPTION 1CH    
        mov dx, offset new_routine    ; METTRE L'@ EFFECTIVW DE new_routine DANS DX
        mov ah, 25H                   ; NUMERO DE LA FONCTION DE DEROUTEMENT
        mov al, 1CH                   ; NUMERO DE L'INTERRUPTION QU'ON VEUT DEROUTER (INTERRUPTION 1CH) 
        int 21H                       ; DEROUTER EN FAISANT APPEL A L'INTERRUPTION 21H
        
        pop ds                        ; DEPILER LA VALEUR DE DS DE LA PILE ET RECUPERER SON ETAT A L'ENTREE DE LA PROCEDURE
        
        ; AFFICHER LE MESSAGE "deroutement fait..." POUR INDIQUER LA FIN DU DEROUTEMENT
        mov dx, offset prompt         ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE prompt
        call output                   ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE prompt 
        
        ret  ; RETOURNER AU MAIN
deroute endp

;********************************************************;
; CODE DE LA NOUVELLE ROUTINE
;********************************************************;
new_routine proc near
one:    cmp bl, 0H                          ; COMPARER LA VALEUR DE BL AVEC 0H
        jne two                             ; SI BL > 0, SAUTER VERS L'ETIQUETTE two
            cmp bh, 1                       ; COMPARER LA VALEUR DE BH AVEC 1
            jnge zero                       ; SI BH <= 1, SAUTER VERS L'ETIQUETTE zero
                inc bl                      ; INCREMENTER BL
                ; AFFICHER LE MESSAGE "tache1 en cours d'execution..."
                mov dx, offset tache1       ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE tache1
                call output                 ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE tache1
                
two:   cmp bl, 1H                           ; COMPARER LA VALEUR DE BL AVEC 1H
       jne three                            ; SI BL > 1, SAUTER VERS L'ETIQUETTE three
            cmp bh, 2                       ; COMPARER LA VALEUR DE BH AVEC 2
            jnge zero                       ; SI BH <= 2, SAUTER VERS L'ETIQUETTE zero
                inc bl                          ; INCREMENTER BL
                ; AFFICHER LE MESSAGE "tache2 en cours d'execution..."
                mov dx, offset tache2       ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE tache2
                call output                 ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE tache2
                
three:  cmp bl, 2H                          ; COMPARER LA VALEUR DE BL AVEC 2H
        jne four                            ; SI BL > 2, SAUTER VERS L'ETIQUETTE four
            cmp bh, 3H                      ; COMPARER LA VALEUR DE BH AVEC 3H
            jnge zero                       ; SI BH <= 3, SAUTER VERS L'ETIQUETTE zero
                inc bl                          ; INCREMENT BL
                ; AFFICHER LE MESSAGE "tache3 en cours d'execution..."
                mov dx, offset tache3       ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE tache3
                call output                 ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE tache3
                
four: cmp bl, 3H                            ; COMPARER LA VALEUR DE BL AVEC 3H
        jne zero                            ; SI BL > 3, SAUTER VERS L'ETIQUETTE zero
            cmp bh, 4H                      ; COMPARER LA VALEUR DE BH AVEC 4H
            jnge zero                       ; SI BH <= 4, SAUTER VERS L'ETIQUETTE zero
                mov bl, 0                   ; INITIALIZER LA VALEUR DE BL
                mov bh, 0                   ; INITIALIZER LA VALEUR DE BH
                ; AFFICHER LE MESSAGE "tache4 en cours d'execution..."
                mov dx, offset tache4       ; ADRESSE EFFECTIVE DU PREMIER CARACTERE DE LA CHAINE tache4
                call output                 ; APPELLE DE LA PROCEDURE QUI AFFICHE LE MESSAGE tache4
zero:   iret
new_routine endp

;********************************************************;

; DEBUT DU PROGRAMME PRINCIPAL

;********************************************************; 
start:
    ; ACCEDER AUX REGISTRES:
    mov ax, data
    mov ds, ax

    ; INITIALIZER LA VALEUR DE BL A ZERO ET DE BH A 1 (ILS VONT SERVIR COMME COMPTEURS)
    mov bl, 0H
    mov bh, 1h

    ; CLEAR SCREEN A L'AIDE DE L'INTERRUPTION 10H
    mov ax, 3       ; FONCTION QUI OBTIENT LA POSITION ET LA FORME DU CURSEUR
    int 10H         ; EXECUTER L'INTERRUPTION 10H

    ; ON APPELLE LA PROCEDURE QUI DEROUTE L'INTERRUPTION 1CH SUR LA NOUVELLE ROUTINE CREE new_routine
    call deroute

    to_infinity:
            mov ax, 7a12H        ; INITIALIZER LA VALEUR DE AX A 7A12H (AX SERVIRA COMME COMPTEUR)
    
    count:     mov cx , 140H     ; INITIALIZER LA VALEUR DE CX A 140H (CX SERVIRA COMME COMPTEUR)
    
    encore:    loop encore      ; FAIRE UNE LOOP SUR L'ETIQUETTE encore
            dec ax              ; DECREMENTER AX
            jnz count           ; SI AX > 0 (5 SECONDES SONT ECOULES), SAUTER VERS L'ETIQUETTE count
            inc bh              ; INCREMENTER BH  
            jmp to_infinity     ; PUIS ON SAUTE VERS L'ETIQUETTE to_infinity POUR REINITIALIZER LES COMPTEURS
            
code ends
        
    end start ; SORTIR DU SYSTEME
