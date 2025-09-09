# IAC 2023/2024 k-means
# 
# Grupo: 24
# Campus: Taguspark
#
# Autores:
# 111139, Afonso Bastos
# 110738, João Teodósio
#
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
n_points:    .word 5
points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters: .zero 16384 #(cobertura de 1024 words de 16 bits, para permitir a coordenada máxima de 32x32)    

seed: .word 0       #serve para guardar a seed de geração pseudo-aleatória


#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0x000000
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecrã
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0, 0 #x
    li t1, 0 #y
    li a2, white #color
    li a3, LED_MATRIX_0_HEIGHT
    
    loop:
        # save variables in stack pointer (ra, x, y and LED_MATRIX_0_HEIGHT)
        addi sp, sp, -16
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw a3 12(sp)
        
        # move t0 and t1 to be used as a point
        mv a0 t0
        mv a1 t1

        jal printPoint

        #restore all stacked variables (ra, x, y and LED_MATRIX_0_HEIGHT)
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw a3 12(sp)
        addi sp, sp, 16
        addi t0, t0, 1 # x += 1
    	blt t0, a3, loop #if x < HEIGHT, jump to loop 
    addi t1, t1, 1 # y +=1
    add t0, x0, x0 # reset t0 to 0
    blt t1, a3, loop #if y < HEIGHT, jump to loop
    jr ra

    

### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    li a3 3
    mul s4, s4, a3 # cada conjunto de dados é composto por 3 entradas
    li s1, 4 #word jump
    la a2, colors
    li s6, 0 #i

    beq s0, s5, singlecase
    multicase:
        mv t4, s6 # t4 é usado como meio de comparação
        mul t4, s6, s1 # converter iterador em offset
        add t0, s9, t4 # clusters[i] = index de cor
        lw t0, 0(t0)
        addi t5, t4, 4 # endereço de clusters[i+1]
        add t1, s9, t5 # clusters[i+1] = x
        lw t1, 0(t1)
        addi t6, t5, 4 # i+2 para tirar a coordenada de y
        add t2, s9, t5 # clusters[i+2] = y
        lw t2, 0(t2)

        addi sp, sp, -24
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw t2, 12(sp)
        sw t4, 16(sp)
        sw a2, 20(sp)

        mv a0, t1
        mv a1, t2
        mul t0, t0, s1 #t0 passa a offset do vetor colors
        add a2, a2, t0
        lw a2, 0(a2)

        jal printPoint
        
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t2, 12(sp)
        lw t4, 16(sp)
        lw a2, 20(sp)
        addi sp, sp, 24

        addi s6, s6, 3
        addi t4, t4, 3
        blt t4, s4, multicase
        j end_pC

    singlecase:
        lw a2, 0(a2) #cluster_color

        add t4, s6, x0 #save i in temporary registry
        mul t4, s6, s1 #convert it to offset
        add t0, s3, t4 # points[i] = x
        lw t0, 0(t0)
        addi t5, t4, 4 # i+1 in other temporary registry
        add t1, s3, t5 # points[i+1] = y
        lw t1, 0(t1)
        # (points[i] (x) in t0 & points[i+1] (y) in t1)

        # save variables in stack pointer (x, y, ra & cluster_color)
        addi sp, sp, -20
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw t4, 12(sp)
        sw a2, 16(sp)
        
        # move t0 and t1 to be used as a pointer
        mv a0 t0
        mv a1 t1
        jal printPoint

        #restore all needed variables (x, y, ra & cluster_color)
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t4, 12(sp)
        lw a2, 16(sp)

        addi sp, sp, 20
        addi t4, t4, 2
    blt t4, s4, singlecase

    end_pC:
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    li a2 black #centroid_color
    li a3 2 
    mul s4, s0, a3 #2n x and y
    li s1, 4 #word jump
    li s6, 0 #i
    beq s0, s5, casek1

    casek_gt_1:
    add t4, s6, x0 #guardar i em temporario
    mul t4, s6, s1 #converter i em offset
    add t0, s2, t4 # centroids[i] = x
    lw t0, 0(t0)
    addi t5, t4, 4 # i+1 noutro registo temporário
    add t1, s2, t5 # centroids[i+1] = y
    lw t1, 0(t1)
    # (points[i] (x) in t0 & points[i+1] (y) in t1)

    addi sp, sp, -20
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t4, 12(sp)
    sw a2, 16(sp)
        
    mv a0 t0
    mv a1 t1
    jal printPoint

    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t4, 12(sp)
    lw a2, 16(sp)

        addi sp, sp, 20
        addi s6, s6, 2
    blt s6, s4, casek_gt_1
    j end_prC
    casek1:
        lw t0, 0(s2) # x_centroid
        lw t1, 4(s2) #y_centroid

        #store relevant variable (black, x and y, and ra)
        addi sp, sp, -16
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw a2, 12(sp)

        mv a0, t0
        mv a1, t1

        jal printPoint

        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw a2, 12(sp)
        addi sp, sp, 16

    end_prC:
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    li a3 2
    mul s4, s4, a3 #2n x and y
    li s6, 0 #iterador

    beq s0, s5, cluster1
    multicluster:
        li a3 2
        li s1, 8 #este word jump permite ir de index a index
        mul s4, s4, a3 #2n x and y
        li s6, 0 #iterador
        
        add t4, s6, x0 #save i in temporary registry
        mul t4, s6, s1 #convert it to offset
        add t0, s9, t4 # centroids[i] = index
        lw t0, 0(t0)
        beq t4, s6, calculate
        addi s6, s6, 1
        j multicluster
        calculate:
            addi t5, t4, 4 # i+1 in other temporary registry
            add t1, s3, t5 # points[i+1] = x
            lw t1, 0(t1)
            addi t2, s3, 4 #points[i+2] = y
            lw t2, 0(t2)
            # (points[i+1] (x) in t1 & points[i+2] (y) in t2)
            # (keep x_res in t3, and y_res in t6)
            add t3, t3, t1
            add t6, t6, t2
            addi t4, t4, 3
            addi s6, s6, 3
            blt t4, s4, multicluster
        
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t3, 12(sp)
        lw t6, 16(sp)
        addi sp, sp, 20

        blt t4, s4, multicluster

        div s4, s4, a3 #get normal n
        div t3, t3, s4 #centroid_x
        div t6, t6, s4 #centroid_y
        
        #store both x and y in their respective positions inside clusters "array"
        sw t3, 0(s2)
        sw t6, 4(s2)
        
        addi s6, s6, 3
        addi t4, t4, 3
        
        
        
            
    cluster1:
        add t4, s6, x0 #save i in temporary registry
        mul t4, s6, s1 #convert it to offset
        add t0, s3, t4 # points[i] = x
        lw t0, 0(t0)
        addi t5, t4, 4 # i+1 in other temporary registry
        add t1, s3, t5 # points[i+1] = y
        lw t1, 0(t1)
        # (points[i] (x) in t0 & points[i+1] (y) in t1)
        # (keep x_res in t3, and y_res in t6)
        add t3, t3, t0
        add t6, t6, t1

        addi sp, sp, -20
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw t3, 12(sp)
        sw t6, 16(sp)

        addi s6, s6, 2 # i+=2
        
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t3, 12(sp)
        lw t6, 16(sp)
        addi sp, sp, 20

        blt s6, s4, cluster1

        div s4, s4, a3 #get normal n
        div t3, t3, s4 #centroid_x
        div t6, t6, s4 #centroid_y

	#store both x and y in their respective positions inside clusters "array"
        sw t3, 0(s2)
        sw t6, 4(s2)
    end_cC:
    jr ra



### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    #load global variables
     la s0, k
     lw s0, 0(s0)
    li s1, 4  #word_jump
    la s2, centroids
    la s3, points
    la s4, n_points
    li s5, 1 #comparação a k
    #2. cleanScreen
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, cleanScreen
    #3. printClusters
    sw ra, 0(sp)
    jal ra, printClusters
    #4. calculateCentroids
    sw ra, 0(sp)
    jal ra, calculateCentroids
    #5. printCentroids
    sw ra, 0(sp)
    jal ra, printCentroids
    #6. Termina
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


###pseudoGenerator
# Usa a base do GCL (Gerador de Congruência Linear). Função Auxiliar
# Argumentos: nenhum
# Retorno:
# a0: número entre 0 e 31
pseudoGenerator:
    lw t0, 0(s7) #comparison value
    bnez t0, skip #if t0 != 0, skip na call de sistema 
    li a7, 30 #system call para a time_msec
    ecall     # seed guardada em a0
    add a0, a0, a1
    neg a0, a0
    sw a0, 0(s7) #guardar a0 na seed

    skip:
        lw t1, 0(s7) #mover a1 para temporário
        li t2, 1664520 #valor comum para multiplicador
        li t3, 1013904223 #valor comum de incremento
        li t4, 32 #valor de modulo, para gerar coordenada entre 0 e 31

        mul t5, t2, t1 # t5 = multiplicador * seed

        bltz t5, absolute_mul #se o resultado está em overflow, torná-lo positivo

        add  t5, t5, t3 # t5 = multiplicador * seed + incremento
        bltz t5, absolute_add #se o resultado está em overflow (novamente), torná-lo positivo
        sw t5, 0(s7) # t5 torna-se a nova seed
        rem  t6, t5, t4 # t6 =  t5 % modulo
        j end
        
        absolute_mul:
            neg t5, t5
            add  t5, t5, t3 # t5 = multiplicador * seed + incremento

            bltz t5, absolute_add #se o resultado está em overflow (novamente), torná-lo positivo

            sw t5, 0(s7) # t5 torna-se a nova seed
            remu  t6, t5, t4 # t6 =  t5 % modulo (unsigned)
            j end

            absolute_add:
                neg t5, t5
                sw t5, 0(s7) # t5 torna-se a nova seed
                remu  t6, t5, t4 # t6 =  t5 % modulo (unsigned)
        end:
            mv  a0, t6 # Guardar o número
    jr ra

### initializeCentroids
# Inicializa as 6 coordenadas de centroids, de forma pseudo-aleatória.
# Argumentos: nenhum
# Retorno: nenhum
inicializeCentroids:
    li t0, 0
    li t1 2 # par de coordenadas
    mul t1, t1, s0 # número de coordenadas
    init_loop:
        addi sp, sp, -12 # manter t0 e t1
        sw t0, 0(sp)
        sw t1, 4(sp)
        sw ra, 8(sp)

        jal ra, pseudoGenerator

        lw t0, 0(sp)
        lw t1, 4(sp)
        lw ra, 8(sp)
        addi sp, sp, 12

        mul t3, t0, s1  #converter index para offset
        add s2, s2, t3  #adicionar offset ao endereço do vetor
        sw a0, 0(s2) # guardar a0 no index correspondente
        sub s2, s2, t3 # endereço de "centroids" volta ao estado inicial
    addi t0, t0, 1 # decrementar contador
    blt t0, t1, init_loop # repetir até que todos os 6 números sejam gerados
    jr ra
    



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0, a0, a2  #x0-x1
    sub t1, a1, a3 #y0-y1
    x_positive: #if t0 > 0:
    bgtz, t0, y_positive 
        neg t0, t0 # valor duplamente negativo = positivo
    y_positive: #if t1 > 0:
        bgtz t1, affirm_case
        neg t1, t1 #t1 negado
    affirm_case:
        add a0, t0, t1
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    li t0, 0 #index de resposta
    li t1, 0 #iterador
    li a4, 6 #comparador de número de coordenadas
    li a5, 64 #distancia de referência, maior manhattanDistance possível (diagonal 32x32)
    loopClusters:
    #manter x and y em t3 e t6, respetivamente
        mul t4, t1, s1 #converter iterador para offset
        add t3, s2, t4 # centroids[i] = x
        lw t3, 0(t3)
        addi t5, t4, 4 # i+1 in other temporary registry
        add t6, s2, t5 # centroids[i+1] = y
        lw t6, 0(t6)

        addi sp, sp, -28 # push de ra, t0, t1 ,a4 e a5, a0 e a1
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw a4, 12(sp)
        sw a5, 16(sp)
        sw a0, 20(sp)
        sw a1, 24 (sp)

        mv a2,t3
        mv a3, t6

        jal manhattanDistance

        mv t2, a0 #manter manhattanDistance em t2
        lw ra, 0(sp)  
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw a4, 12(sp)
        lw a5, 16(sp)
        lw a0, 20(sp)
        lw a1, 24(sp)
        addi sp, sp, 28

        blt t2, a5, shorter #caso t2 seja menor ou igual, valor fixo não altera
        addi t1, t1, 2 #passar ao próximo par (x,y)
        addi t0, t0, 1 #passar ao index seguinte
        blt t1, a4, loopClusters
        j end_nC

        shorter:
            mv a5, t2 #o valor novo susbtitui o fixo, por ser menor
            mv a6, t0 #este passa a ser o index da distância mais próxima
            addi t1, t1, 2 #passar ao próximo par (x,y)
            addi t0, t0, 1 #passar ao index seguinte
            blt t1, a4, loopClusters
    end_nC:
    mv a0, a6 #resultado é dado em a0
    jr ra

###pointConverter
# Função auxiliar que associa os pontos do vetor points 
# a um determinado cluster (de index 0, 1 ou 2).
# Argumentos: nenhum
#Retorno: nenhum
pointConverter:
    li a3 2
    mul s4, s4, a3 #2n x and y
    li s1, 4 #word jump
    li s6, 0 #i

    pointCon_loop:
        add t4, s6, x0 #save i in temporary registry
        addi sp, sp, -16  
        sw t4, 12(sp)        
        mul t4, s6, s1 #convert it to offset
        add t0, s3, t4 # points[i] = x
        lw t0, 0(t0)
        addi t5, t4, 4 # i+1 in other temporary registry
        add t1, s3, t5 # points[i+1] = y
        lw t1, 0(t1)
        # (points[i] (x) in t0 & points[i+1] (y) in t1)

        #push de todas as variáveis necessárias antes do nearestCluster
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)

        mv a0, t0
        mv a1, t1

        jal nearestCluster

        mv t3, a0 #guardar o index em temporário

        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw t4, 12(sp)
        addi sp, sp, 16
        #conversão de pontos
        add t2, t4, x0 #manter t4 para as iterações
        bnez t2, scnd_instance #após a primeira iteração, t2 tem de estar configurado para 3 tipos de dados
        add s9, s9, t2 #endereço onde colocar index
        sw t3, 0(s9) #guardar o index
        sub s9, s9, t2

        addi t2, t2, 4
        add s9, s9, t2 #endereço onde colocar index
        sw t0, 0(s9) #guardar x
        sub s9, s9, t2

        addi t2, t2, 4
        add s9, s9, t2
        sw t1, 0(s9) #guardar y
        sub s9, s9, t2
        j end_pointCon
        scnd_instance:
            addi t2, t2, 4
            add s9, s9, t2 #endereço onde colocar index
            sw t3, 0(s9) #guardar o index
            sub s9, s9, t2

            addi t2, t2, 4
            add s9, s9, t2 #endereço onde colocar index
            sw t0, 0(s9) #guardar x
            sub s9, s9, t2

            addi t2, t2, 4
            add s9, s9, t2
            sw t1, 0(s9) #guardar y
            sub s9, s9, t2
        end_pointCon:
        addi s6, s6, 2
        addi t4, t4, 2
        blt t4, s4, pointCon_loop
        jr ra
        
        

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    #load a variáveis globais
    la s0, k
    lw s0, 0(s0)
    li s1, 4  #word_jump
    la s2, centroids
    la s3, points
    la s4, n_points
    lw s4, 0(s4)
    li s5, 1 #comparação a k
    la s7, seed
    la s8, L
    lw s8, 0(s8) #número de iterações do algoritmo principal
    la s9, clusters
    main_loop:
        #2. cleanScreen
        addi sp, sp, -4
        sw ra, 0(sp)
        jal ra, cleanScreen
        #3. Inicialize Centroids
        sw ra, 0(sp)
        jal ra, inicializeCentroids
        #4. printCentroids
        sw ra, 0(sp)
        jal ra, printCentroids
        #5. pointConverter
        sw ra, 0(sp)
        jal ra, pointConverter
        #6. printClusters
        jal ra, printClusters
        #6. Termina + Condições de paragem:
        addi s8, s8, -1
        bgtz s8, main_loop
        lw ra, 0(sp)
        addi sp, sp, 4
    end_main:
        jr ra