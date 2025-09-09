# IAC 2023/2024 k-means
# 
# Grupo:
# Campus: Taguspark
#
# Autores:
#111139, Afonso Bastos
#110738, João Teodósio
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
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0x000000
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
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
    la, s3, points
    la, s4, n_points
    lw s4, 0(s4) # n points
    li a3 2
    mul s4, s4, a3 #2n x and y
    li s6, 0 #i
    li s1, 4 #word jump

    beq s0, s5, singlecase
    singlecase:
        la a2, colors
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
        addi sp, sp, -16
        sw ra, 0(sp)
        sw t0, 4(sp)
        sw t1, 8(sp)
        sw a2, 12(sp)
        
        # move t0 and t1 to be used as a pointer
        mv a0 t0
        mv a1 t1
        jal printPoint

        #restore all needed variables (x, y, ra & cluster_color)
        lw ra, 0(sp)
        lw t0, 4(sp)
        lw t1, 8(sp)
        lw a2, 12(sp)

        addi sp, sp, 16
        addi s6, s6, 2
    blt s6, s4, singlecase
    #bgt s6, s5, multicase

    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw a2 black #centroid_color
    la s2, centroids

    beq s0, s5, casek1
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

    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    la s2, centroids
    la, s3, points
    la, s4, n_points
    lw s4, 0(s4) # n points
    li a3 2
    mul s4, s4, a3 #2n x and y
    li s6, 0 #i
    li s1, 4 #word jump

    beq s0, s5, cluster1
    #bgt s0, s5, clusterscase
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

    jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    #s0 is a global variable
     la s0, k
     lw s0, 0(s0)
    li s5, 1 # k comparison
    #2. cleanScreen
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, cleanScreen
    #3. printClusters
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, printClusters
    #4. calculateCentroids
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, calculateCentroids
    #5. printCentroids
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, printCentroids
    #6. Termina
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra