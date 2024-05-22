# Assembly Game

As registradoras correspondem a

```
#       a0 = depth of map
#       a1 = time for going up in a jump (if it's negative it means he didnt touched the ground)
#       a2 = color of barrier in map
#       a3 = color for success
#       a4 = number of characters in the map times size of word = 4*size of TYPE array
#       a5 = width of screen (320)
#       a6 = height times width (320*240)
#       s0 = frame
```

Por  hora tem-se as estruturas de dados

```
.include "map.s"
.include "char2.s"
.include "char.s"
.include "char3.s"
```

Que são arrays de cores do mapa e do personagens. Os personagens por razões práticas terão de ter tamanho 16x16 sempre. Para converter um arquivo bmp para o array do personagem terá que usar o programa fornecido

### O Jogo

O jogo é feito numa tela de 320x240.  No jogo o caracter só desce na tela do mapa. Na variavel

```
.include "map.s"
```

Contém o que seria o mapa. Caso queira adcionar mais partes para o mapa, basta colocar mais uma linha de 320 bytes ao final.  Os characters do jogo são salvos no array types e a quantidade deles vezes o tamano da word é salvo na registradora a4

``` TYPES:			.word 0x0, 0x1, 0x1, 0x1, 0x1, 0x1 # type of character and the enemies```

Na hora de printar os personagens do jogo ele vai usar esses tipos para saber qual endereço da memória acessar

```
...
        la  t2, TYPE
        add t2, t2, t0
        lw  t2, (t2)
        li  t3, 0
        beq t2, t3, IMG0
        li  t3, 1
        beq t2, t3, IMG1
        li  t3, 2
        beq t2, t3, IMG2
IMG0:       la  t2, CHAR #saves image address in t2
        j   B1
IMG1:       la  t2, CHAR2
        sub t1, t1, a0
        j   B1
IMG2:       la  t2, NULL
        sub t1, t1, a0
        j   B1
...
```

A posição do personagem será carregada nesse trecho

```
L1:     la  t2, POSITIONX
        add t2, t2, t0
        lw  t2, (t2)
        la  t1, POSITIONY
        add t1, t1, t0
        lw  t1, (t1)
        add t1, t1, t2 # position of character is in t1
```

Em que será carregado os elementos dos arrays

```
POSITIONX:		.word 0x37, 0x37, 0x37, 0x37, 0x37, 0x37
POSITIONY:		.word 0x13,0x27,0x3b,0x4f,0x63,0x77
```

É salvo na memória constantes que serão usadas

```
PRINT_CHAR: mv  t0, zero # counter of characters in t0
        li      s1, 0xFF0
            add     s1, s1, s0
            slli    s1, s1, 20 # bitmap address in s1
            li  s2, 0xf #0b11111111 in s2
            li  s3, 308 # 320-16+4 in s3
            li  s4, 256 # 16*16
```

Para que então seja printado esse personagem

```
B1:     bgt zero, t1, NEXT_IMG
        mv  t6, zero # position of pixel in image in t6
        mv  t3, zero # counter for image in t3
L2:     mv  t4, s1
        add t4, t4, t1
        add t4, t4, t6
        mv  t5, t2
        add t5, t5, t3
        lw  t5, (t5)
        sw  t5, (t4)
        addi    t3, t3, 4
        and t4, t3, s2
        beq t4, zero, LINE_JUMP
        addi    t6, t6, 4
        blt t3, s4, L2
        j   NEXT_IMG
LINE_JUMP:  add t6, t6, s3
        blt t3, s4, L2
NEXT_IMG:   addi    t0, t0, 4
        blt t0, a4, L1
```

O movimento do personagem é feito usando o keyboard and display MMIO simulator que nele tem o endereço dele. A tecla fará com que os arrays de posição no eixo x e y sejam alteradas

```v
KEY:        la  t0, MAP
        add t0, t0, a0
        la  t3, POSITIONX
        lw  t1, (t3)
        la  t4, POSITIONY
        lw  t2, (t4)
        add t0, t0, t1
        add t0, t0, t2
        li  t5,0xFF200000       # carrega o endereco de controle do KDMMIO
        lw  t6,(t5)         # Le bit de Controle Teclado
        andi    t6,t6,0x0001        # mascara o bit menos significativo
        beq     t6,zero,JUMP        # Se nao ha tecla pressionada entao vai para FIM
        lw  t6,4(t5)            # le o valor da tecla tecla 
        li  t5,'w'
        beq     t5,t6,CHAR_CIMA     # se tecla pressionada for 'w', chama CHAR_CIMA 
        li  t5,'a'
        beq     t5,t6,CHAR_ESQ      # se tecla pressionada for 'a', chama CHAR_CIMA
        li  t5,'s'
        beq     t5,t6,CHAR_BAIXO        # se tecla pressionada for 's', chama CHAR_CIMA
        li  t5,'d'
        beq     t5,t6,CHAR_DIR      # se tecla pressionada for 'd', chama CHAR_CIMA
CHAR_CIMA:  bne a1, zero, JUMP
        li  a1, 10
        j   JUMP
CHAR_BAIXO: slli    t5, a5, 4
        add t0, t0, t5
        lb  t0, (t0)
        beq t0, a2, JUMP
        beq t0, a3, NEXT_LEVEL
        slli    t5, a5, 2
        add a0, a0, t5
        j   JUMP
CHAR_DIR:   addi    t0, t0, 16
        lb  t0, (t0)
        beq t0, a2, JUMP
        beq t0, a3, NEXT_LEVEL
        addi    t1, t1, 4
        sw  t1, (t3)
        j   JUMP
CHAR_ESQ:   addi    t0, t0, -1
        lb  t0, (t0)
        beq t0, a2, JUMP
        beq t0, a3, NEXT_LEVEL
        addi    t1, t1, -4
        sw  t1, (t3)
        j   JUMP

```

Para o mapa acompanhar o personagem, muda-se a registradora a0 ao invés de mudar a posição do protagonista em CHAR_BAIXO. Ao pular ele verifica se não está no ar ou se ainda está caindo e não tocou no chão, isso é

 ```
 CHAR_CIMA:  bne a1, zero, JUMP
 ```

Se for permitido pular ele adciona o tempo que será permitido na registradora a1

```
        li  a1, 10
```

Toda vez que o protagonista se movimenta é verificado se é permitido fazer esse movimento, isso é checa-se no mapa se não tem uma barreira que é representado pela cor 0x1 que está presente na registradora a2. A regitradora a3 tem uma cor que representa troca de fase ou vitória

```
CHAR_DIR:   addi    t0, t0, 16 # t0 tem a posição no mapa
        lb  t0, (t0)
        beq t0, a2, JUMP
        beq t0, a3, NEXT_LEVEL
```

Depois tem o trecho de código que verificará se ele ainda está pulando e se não estiver e não tiver nehum obstáculo o protagonista será puxado para baixo (GRAVITY). Também verifica se tocou o chão em que nesse caso zera a1 o que permite ele pular novamente

```
JUMP:       la  t0, MAP
        add t0, t0, a0
        la  t3, POSITIONX
        lw  t1, (t3)
        la  t4, POSITIONY
        lw  t2, (t4)
        add t0, t0, t1
        add t0, t0, t2
        ble a1, zero, GRAVITY
        mv  t5, a5
        sub t0, t0, t5
        lb  t0, (t0)
        beq t0, a2, COLLISION
        beq t0, a3, NEXT_LEVEL
        slli    t5, a5, 2
        sub a0, a0, t5
        addi    a1, a1, -1
        j   COLLISION
GRAVITY:    slli    t5, a5, 4
        add t0, t0, t5
        lb  t0, (t0)
        beq t0, a2, GROUND
        beq t0, a3, NEXT_LEVEL
        slli    t5, a5, 2
        add a0, a0, t5
        j   COLLISION
GROUND:     mv  a1, zero # allows character to jump once he touched the ground at least once

```

Tem um mecanismo para checar se houve colisões em que é verificado se há intercessão com as bounding boxes dos outros characters

```
COLLISION:  li  t0, 4 # counter of characters
        li  s1, 16 # 16 in s1
        sub s2, zero, s1 # -16 in s2
        li  s3, 320
        slli    s3, s3, 4 # 320 * 16 in s3
        sub s4, zero, s3 # -320*16 in s4
        la  t1, POSITIONX
        la  t2, POSITIONY
        lw  s5, (t1)
        lw  s6, (t2)
L3:     add t3, t1, t0
        lw  t3, (t3)
        add t4, t2, t0
        lw  t4, (t4)
        sub t4, t4, a0
        sub t3, t3, s5
        sub t4, t4, s6
        bge t3, s1, B2
        bge s2, t3, B2
        bge t4, s3, B2
        bge s4, t4, B2
        j   GAME_OVER
B2:     addi    t0, t0, 4
        blt t0, a4, L3

```

Então tem uma troca de frame

```
FRAME:      li  t0,0xFF200604       # carrega em t0 o endereco de troca de frame
        sw  s0,0(t0)
        xori    s0, s0, 1
        mv  t0, zero
        mv  t1, zero
        mv  t2, zero
        mv  t3, zero
        mv  t4, zero
        mv  t5, zero
        mv  t6, zero
        j   PRINT
