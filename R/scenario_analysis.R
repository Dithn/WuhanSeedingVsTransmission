
#' Run a scenario analyis
#'
#' @param scenarios Dataframe of potential scenarios
#' @param sampled_and_set_parameters Dataframe of sampled and fixed parameter values
#' @param show_progress Logical, defaults to FALSE. Show progress be shown.
#'
#' @return
#' @export
#' @importFrom dplyr rowwise mutate ungroup
#' @importFrom tidyr unnest 
#' @importFrom purrr map_dfr
#' @importFrom furrr future_map
#'
#' @examples
#' 
#' 
scenario_analysis <- function(scenarios = NULL, 
                              sampled_and_set_parameters = NULL,
                              show_progress = FALSE) { 
  
  
  ## Run scenarios and samples against sims
  scenario_sims <- scenarios %>% 
    dplyr::group_by(scenario) %>% 
    tidyr::nest() %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(sims = 
      furrr::future_map(
        data, 
        function(data) {
          
          ## sample R0 from scenario
          sampled_R0 <- runif(nrow(sampled_and_set_parameters), 0, data$upper_R0)
          
          ## Run model for specified number of samples
          purrr::map_dfr(
          1:nrow(sampled_and_set_parameters), 
          ~ tibble::tibble( 
            size = list(WuhanSeedingVsTransmission::run_sim(
              n = data$event_size,
              n_length = data$event_duration,
              mean_si = data$serial_mean, 
              sd_si = sampled_and_set_parameters$serial_sd[.x], 
              R0 = sampled_R0[.x], 
              k = sampled_and_set_parameters$k[.x], 
              tf = sampled_and_set_parameters$outbreak_length[.x] + data$event_duration,
              max_potential_cases = sampled_and_set_parameters$upper_case_bound + 1,
              delay_mean = sampled_and_set_parameters$delay_mean,
              delay_sd = sampled_and_set_parameters$delay_sd)),
            sample = .x,
            R0 = sampled_R0[.x]
          ) %>% 
            tidyr::unnest("size")
        )}, 
        .progress = show_progress
      )) %>% 
    tidyr::unnest("data") %>% 
    tidyr::unnest("sims") 
  }