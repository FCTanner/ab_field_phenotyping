run_classification_cv <- function(input = prep_dat_out, output, cv_folds = n_folds, cv_repeats = n_repeats, random_seed = seed){
  
  # Sample folds
  set.seed(random_seed)
  folds_for_cv <- vfold_cv(input, v = cv_folds, repeats = cv_repeats, strata = treatment)
  
  
  # Pre-processing steps
  detect_recipe <- recipe((treatment ~ .), 
                          data = dat_for_cv)  |>
    update_role(pad, new_role = "ID") |> 
    update_role(plot_id_fe, new_role = "ID") |> 
    step_center(all_predictors()) |>
    step_scale(all_predictors()) |>
    step_zv(all_predictors()) 
  
  pls_detect_recipe <- detect_recipe |> 
    step_pls(all_predictors(), outcome= "treatment", num_comp = 6)
  
  
  svm_spec <- svm_rbf(cost = 50) |>
    set_engine("kernlab") |>
    set_mode("classification") |>
    translate()
  
  rf_spec <- rand_forest() |>
    set_engine("ranger") |>
    set_mode("classification") |>
    translate()
  
  logreg_spec <-  multinom_reg(mode = "classification",
                               engine = "glmnet",
                               penalty = 0.01,
                               mixture = NULL)

  # Build workflows
  
  svm_wf <- workflow() |>
    add_model(svm_spec) |>
    add_recipe(detect_recipe)
  
  rf_wf <- workflow() |>
    add_model(rf_spec) |>
    add_recipe(detect_recipe)
  
  plsda_wf <- workflow() |> 
    add_model(logreg_spec) |> 
    add_recipe(pls_detect_recipe)
  
  # Fit resamples
  svm_fits <- svm_wf |> fit_resamples(folds_for_cv)
  rf_fits <- rf_wf |> fit_resamples(folds_for_cv)
  plsda_fits <- plsda_wf |> fit_resamples(folds_for_cv)
  
  svm_metrics <- svm_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "SVM")
  
  rf_metrics <- rf_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "RF")
  
  plsda_metrics <- plsda_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "PLSDA")

  
  metrics <- svm_metrics |> 
    bind_rows(rf_metrics) |> 
    bind_rows(plsda_metrics)
  
  
  metrics$response <- dataset_iterator$response_chr[i]
  metrics$VNIR_only <- dataset_iterator$VNIR_only[i]
  metrics$normalization <- dataset_iterator$normalization[i]
  metrics$derivative <- dataset_iterator$derivative[i]
  output <- rbind(output, metrics)
  return(output)
}