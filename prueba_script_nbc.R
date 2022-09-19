# probando script
setwd("E:\\procesado_CATENA\\1X1")
if(!require("sf")){install.packages("sf")}

library(raster)
library(rgdal)
library(stringr)

# Si le pones el punto ese en el path es como si escribieses el wd

pte_list <- list.files(path= "./3_pte/",pattern='.tif',full.names=TRUE, recursive=FALSE)

num_cell_list <- list.files(path= "./4_watershed_A_num_cell",pattern='.tif',full.names=TRUE, recursive=FALSE)

Sistref <- CRS("+init=epsg:25830")



for (i in (pte_list)) {
  pte_raster <- raster(i)
  crs(pte_raster) <- Sistref
  nombre_pte<- basename(i)
  nombre_pte_ext <- substr(nombre_pte,5,(str_length (nombre_pte)-4))
  print(paste0("pte_",(nombre_pte_ext)))
  
  for (x in (num_cell_list) ){
    num_cell <- raster(x)
    crs(num_cell) <- Sistref
    nombre_num_cell <- basename(x)
    nombre_num_cell_ext <- substr(nombre_num_cell,17,(str_length (nombre_num_cell)-4))
    print(nombre_num_cell_ext)
    print(paste0("Num_cell_",(nombre_num_cell_ext)))
    
    
    if (nombre_num_cell_ext == nombre_pte_ext) {
      
      #### Al rsater num_cell hay que quitarle los 0 y los negativos,porque no tienen sentido. El 0 adem?s, al estar en el denominador
      #hacer petar el c?digo. Lo hacemos en dos pasos: Si haces solo la primera operacion (>0) obteines un raster con 
      
      # valroes 0 y 1 (FALSE/ TRUE) por eso hay que multiplicarlo por el mismo
      
      num_cell_cuenca <- ((num_cell) > 0)* num_cell
      
      #writeRaster(num_cell_cuenca, "E:/procesado_innolivar/num_cell_cuenca.tif")
      
      # Ahora las celdas 0 (antes NEGATIVAS) son NA
      
      num_cell_cuenca_rcl<-reclassify(num_cell_cuenca,cbind(0,NA), rigth = FALSE, include.lowest = TRUE)
      
      #writeRaster(num_cell_cuenca, "E:/procesado_innolivar/num_cell_cuenca.tif")
      
      
      K_usle <- (tan ( pte_raster*(pi/180) )) / ((0.0004*num_cell_cuenca_rcl) ^ (-0.38))
      crs(K_usle)<- Sistref
      print(K_usle)
      #writeRaster(K_usle,paste0("./5_k/xk_", nombre_pte_ext, ".tif")) 
      writeRaster(K_usle, "./5_k/k_torres_nodata.tif") 
      
    }
  }
  
}
#el temporal se peta, habr?a que ponerle 
#files <- list.files(path= "C:\Users\USUARIO\AppData\Local\Temp\Rtmp0oMVRi\raster", full.names = T, pattern = "r_tmp^")
# file.remove(files)

