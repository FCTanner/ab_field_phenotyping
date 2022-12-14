run_regression_cv <- function(input = prep_dat_out, output, cv_folds = n_folds, cv_repeats = n_repeats, random_seed = seed){
  
  # Sample folds
  set.seed(random_seed)
  folds_for_cv <- vfold_cv(input, v = cv_folds, repeats = cv_repeats, strata = pad)
  
  
  # Pre-processing steps
  ref_recipe <- recipe((pad ~ .), 
                       data = dat_for_cv)  |>
    update_role(plot_id_fe, new_role = "ID")|>
    update_role(treatment, new_role = "ID")|>
    # update_role(id, new_role = "ID")|>
    step_center(all_predictors()) |>
    step_scale(all_predictors()) |>
    step_zv(all_predictors()) 
  
  pls_recipe <- ref_recipe|># No removal of auto-correlated variables for PLSR! Dimensionality reduction is the whole point of the algorithm 
    step_pls(all_predictors(), outcome = "pad", num_comp = 6)
  
  lasso_cor_filter_recipe <- ref_recipe|># Add recipe with removal of autocorrelated variables (play with threshold)
    step_corr(all_predictors(), threshold = 0.7)
  
  # Select model engines
  linreg_spec <- linear_reg()|># For PLSR
    set_engine("lm")
  
  lasso_spec <- linear_reg(penalty = 0.1, mixture = 1)|>
    set_engine("glmnet")
  
  svm_spec <- svm_rbf(cost = 50)|>
    set_engine("kernlab")|>
    set_mode("regression")|>
    translate()
  
  rf_spec <- rand_forest()|>
    set_engine("ranger")|>
    set_mode("regression")|>
    translate()
  
  # Build workflows
  pls_workflow <- workflow() |>
    add_model(linreg_spec) |>
    add_recipe(pls_recipe)
  
  lasso_workflow <- workflow()|>
    add_model(lasso_spec)|>
    add_recipe(ref_recipe)
  
  lasso_cor_filter_wf <- workflow()|>
    add_model(lasso_spec)|>
    add_recipe(lasso_cor_filter_recipe)
  
  svm_wf <- workflow()|>
    add_model(svm_spec)|>
    add_recipe(ref_recipe)
  
  rf_wf <- workflow()|>
    add_model(rf_spec)|>
    add_recipe(ref_recipe)
  
  
  # Fit resamples
  lasso_fits <- lasso_workflow|>fit_resamples(folds_for_cv)
  lasso_cor_filter_fits <- lasso_cor_filter_wf|>fit_resamples(folds_for_cv)
  plsr_fits <- pls_workflow|>fit_resamples(folds_for_cv)
  svm_fits <- svm_wf|>fit_resamples(folds_for_cv)
  rf_fits <- rf_wf|>fit_resamples(folds_for_cv)
  
  lasso_metrics <- lasso_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "LASSO")
  
  lasso_cor_filter_metrics <- lasso_cor_filter_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "LASSO 0.7 cor filter")
  
  plsr_metrics <- plsr_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "PLSR")
  
  svm_metrics <- svm_fits |>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "SVM")
  
  rf_metrics <- rf_fits|>
    collect_metrics(summarize = FALSE) |>
    mutate(model = "RF")
  
  metrics <- lasso_metrics |>
    bind_rows(lasso_cor_filter_metrics) |>
    bind_rows(plsr_metrics) |>
    bind_rows(svm_metrics) |>
    bind_rows(rf_metrics)
  
  
  metrics$response <- dataset_iterator$response_chr[i]
  metrics$VNIR_only <- dataset_iterator$VNIR_only[i]
  metrics$nil_only <- dataset_iterator$nil_only[i]
  metrics$normalization <- dataset_iterator$normalization[i]
  metrics$derivative <- dataset_iterator$derivative[i]
  output <- rbind(output, metrics)
}