prep_hyperspec_dataset <- function(dataset = hyperspec_full, 
                                   scores = scores_2020,
                                   nil_only = TRUE, 
                                   response_chr = "reflectance_raw", 
                                   VNIR_only = TRUE, 
                                   normalization = "Pu", 
                                   derivative = "None",
                                   gapDer_wl = sav_gol_gap_size,
                                   gapDer_seg = sav_gol_segment_size){
  
  
  # Prepare dataset
  
  ## Combine with scores and plot ids
  dat <- dataset |>
    left_join(scores)|>
    filter(!is.na(pad))# Remove buffer plots
  
  try(dat <- dat|>rename(wavelength = wavelength_bin)) # Rename var for the binned datasets
  
  ## Subset treatment
  
  if(nil_only == TRUE){
    dat <- dat |> dplyr::filter(treatment %in% c("No fungicide", "Infected")) 
  }else{
    dat <- dat |> dplyr::filter(treatment %in% c("Infected", "No fungicide", "FN Chlorothalonil", 
                                                 "Salt + Fungicide", "Fungicide"))
  }
  
  ## Subset VNIR only
  
  if(VNIR_only == TRUE){
    dat <- dat|> filter(wavelength < 970)
  }else{
    dat <- dat
  }
  
  # Pre-processing
  
  ## Normalization
  if(normalization == "Pu"){
    plot_id_fes <- unique(dat$plot_id_fe)
    plot_id_fe_summary <- data.frame(plot_id_fe = numeric(),
                                     avg_ref_per_curve = numeric())
    for(p in plot_id_fes){ # Summarizing reflectance per plot_id_fe
      plot_id_fe_subset <- dat[dat$plot_id_fe == p,]
      list_of_response <- plot_id_fe_subset|>pull(response_chr)
      plot_id_fe_mean <- mean(list_of_response, na.rm = TRUE)
      p_summary <- data.frame(plot_id_fe = p, avg_ref_per_curve = as.numeric(plot_id_fe_mean))
      
      plot_id_fe_summary <- rbind(plot_id_fe_summary, p_summary)
    }
    dat <- dat|>
      mutate(plot_id_fe = as.character(plot_id_fe)) |> 
      left_join(plot_id_fe_summary|>
                  mutate(plot_id_fe = as.character(plot_id_fe))) 
    response_num <- dat|>pull(response_chr)
    
    dat$response <- response_num/dat$avg_ref_per_curve
  }else if(normalization == "None"){
    dat <- dat
    dat$response <- dat|>pull(response_chr)
  }else{
    dat <- dat
    dat$response <- dat|>pull(response_chr)
  }
  
  
  ## Calculate derivatives 
  
  ### Cast wide
  dat <- dat|> 
    pivot_wider(id_cols = c(plot_id_fe, pad), values_from = response, 
                names_from = wavelength, values_fn = mean)
  
  ### Calculate lagged Differences (derivatives), adjust lag depending on binning
  if(derivative == "None"){
    dat <- dat
    
  }else if(derivative == "First"){
    hyper_mat <- as.matrix(dat[ , !names(dat) %in% c("plot_id_fe","pad")])
    hyper_id <- as.matrix(dat[ , names(dat) %in% c("plot_id_fe","pad")])
    
    gds1 <- gapDer(X = hyper_mat, m = 1, w = gapDer_wl, s = gapDer_seg)
    
    dat <- data.frame(hyper_id, gds1, check.names = FALSE)
    dat$pad <- as.numeric(dat$pad)
    
  }else if(derivative == "Second"){
    hyper_mat <- as.matrix(dat[ , !names(dat) %in% c("plot_id_fe","pad")])
    hyper_id <- as.matrix(dat[ , names(dat) %in% c("plot_id_fe","pad")])
    
    gds2 <- gapDer(X = hyper_mat, m = 2, w = gapDer_wl, s = gapDer_seg)
    
    dat <- data.frame(hyper_id, gds2, check.names = FALSE)
    dat$pad <- as.numeric(dat$pad)
    
  }else{
    stop('Derivative needs to be "None", "First", or "Second"')
  }
  dat <- dat |> 
    mutate(plot_id_fe = as.character(plot_id_fe)) |> 
    left_join(scores |> select(plot_id_fe, treatment) |> 
                mutate(plot_id_fe = as.character(plot_id_fe)))
  return(dat)
}