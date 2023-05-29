cams_consolidation <- function(file_path = "../../Data/Raw/CAMS_NRT/unzipped"){
  library(raster)
  library(lubridate)
  library(hms)
  
  folders <- list.dirs(path = file_path, 
                      full.names = T,
                      recursive = FALSE)
  
  for (folder in folders){
    # folder = folders[1]
    # creating folder for each month
    folderName_split <- stringr::str_split(folder[1], "/")[[1]]
    year_month <- stringr::str_flatten(
      stringr::str_split(
        folderName_split[length(folderName_split)], '-')[[1]][1:2],
      '-')
    cat("Processing", year_month, '\n')
    filePath <- paste0("../../Data/Raw/CAMS_NRT/", year_month)
    # creating filename
    filename_hourly <- paste0(filePath,"/", year_month, "_hourly.rds")
    cat(filename_hourly, " \n")
    
    #creating folder for consolidates images
    if(!dir.exists(filePath)){
      dir.create(filePath)}
    # Se arquivo ja existe, passa proximo
    if(file.exists(filename_hourly)){
      cat("skipped ", filename_hourly, " \n")
      next
    }
    
    nc_files <- list.files(folder,
                           recursive = FALSE,
                           full.names = TRUE)
    # reading netCDF
    r <- stack()
    for(i in nc_files){
      # i = nc_files[1]
      r_intermediario <- stack(i)
      r <- stack(r, r_intermediario)
    }
    
    # organizing bandname
    bandName <- gsub('X', '', names(r))
    band_dt <- c()
    for (i in 1:length(bandName)){
      # i = 5
      if (length(stringr::str_split(bandName[i], '\\.')[[1]])==3){
        bandName[i] = paste0(bandName[i], ".00.00.00")
      }
      
      images_ymd_hms <- ymd_hms(bandName[i])
      images_ymd_hms <- images_ymd_hms -18000
      # image_ymd <- date(images_ymd_hms)
      # transforming in UTC-5
      # hour(images_ymd_hms) <- hour(images_ymd_hms) - 5
      # saving as bandname with pattern easy to extract later
      # bandName[i] <- paste0('ymd_', image_ymd,'_',as_hms(images_ymd_hms))
      band_dt[i] <- format_ISO8601(images_ymd_hms)
    }
    
    # converting from Km m3 to microgramo m3
    r <- r*1e9
    r_stars <- stars::st_as_stars(r)
    names(r_stars) <- 'pm<2.5'
    # stars::st_get_dimension_values(r_stars, 'band')
    (cube_hourly <- stars::st_set_dimensions(r_stars,
                            which = 'band',
                            values = 
                              as_datetime(band_dt),
                            names = 'DateTime'))
    
  saveRDS(object = cube_hourly,
          file=filename_hourly, 
          compress=TRUE)
  
  # creating filename daily
  filename_daily <- paste0(filePath,"/", year_month, "_daily.rds")
  cat(filename_daily, "\n")
  
  # Se arquivo ja existe, passa proximo
  if(file.exists(filename_daily)){
    cat("skipped ", filename_daily, " \n")
    next
  }
  cube_daily <- cube_hourly %>% aggregate(
    by = "1 days", 
    FUN = mean)
  
  saveRDS(object = cube_daily,
          file=filename_daily, 
          compress=TRUE)
  
  }
  
}

stars_extract <- function(
    rasterPath = "../../Data/Raw/CAMS_NRT", 
    pattern = '_daily.rds',
    sf = mun,
    stat = 'mean', 
    ...){
  library(magrittr)
  library(sf)
  library(stars)
  
  # list of raster files
  rasterFiles <- list.files(
    rasterPath, 
    pattern, 
    recursive = TRUE,
    full.names = TRUE)
  
  star_object <- do.call("c", lapply(rasterFiles, readRDS))
  
  if(is.na(st_crs(star_object))){
    cat("Assuming sf crs")
    star_object <- st_set_crs(star_object, st_crs(sf))
  }
  cat("raster stack done \n")
  
  # extracting values from raster stack
  sf_use_s2(FALSE)
  sf.mean <- aggregate(star_object, 
                       by = st_geometry(mun), 
                       FUN = get(stat), 
                       as_points=FALSE,
                       na.rm=T)
  
  # Converting to tibble
  sf.mean <- st_as_sf(sf.mean) %>% st_drop_geometry() %>% tibble::as_tibble()
  sf.mean$ID <- 1:nrow(sf.mean)
  sf$ID <- 1:nrow(sf)
  
  sf.mean <- sf.mean %>% inner_join(sf) %>% 
    dplyr::select(-geom) %>% dplyr::relocate(
      code_muni,
      name_muni,
      code_state,
      abbrev_state, ID) %>% pivot_longer(
        -c(code_muni,
           name_muni,
           code_state,
           abbrev_state, ID),
        names_to = 'date',
        values_to = 'ppm25')
  
  return(sf.mean)
}
