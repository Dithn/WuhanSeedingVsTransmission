#' Condition on cases and return accepted sample size by scenario
#'
#' @param condition_date A character string in the following format `"2020-01-01"`. Sets the 
#' date on which to condition the data.
#' @param end_of_seed_date  A character string in the following format `"2020-01-01"`. The assumed
#' end date of the seeding event.
#' @param scenarios_list A character vector listing scenarios evaluated. 
#' @inheritParams condition_on_known 
#' @inheritParams proportion_allowed_by_condition
#' @inheritParams restrict_by_condition
#' @author Sam Abbott
#' @return A list of 3 data.frames as produced by `condition_on_known`, `proportion_allowed_by_condition`, and
#' `restrict_by_condition`.
#' @export
#' @importFrom lubridate as_date
#' @import data.table
#' @examples
#' 
#' ## Example
#' sims <- data.frame(time = rep(1:10, 10),
#'                    size = rep(1:10, 10),
#'                    sample = unlist(lapply(1:10, function(.) {rep(., 10)})),
#'                    scenario = c(rep(1, 5), rep(1, 5)),
#'                    tmp = c(rep(1, 5), rep(1, 5)),
#'                    event_duration = 1
#'                   )
#' 
#' 
#' condition_and_report_on_cases(sims, condition_date = "2020-01-03", lower_bound = 3, upper_bound = 5,
#'                               scenarios_list = c("scenario", "tmp"), samples = 10)
#'
#'## Code
#'condition_and_report_on_cases
condition_and_report_on_cases <- function(sims, condition_date = NULL, lower_bound = NULL,
                                          upper_bound = NULL, samples = NULL,
                                          end_of_seed_date = "2019-12-31",
                                          scenarios_list = c("scenario", "event_duration", "event_size",
                                                             "serial_mean", "serial_type", "upper_R0", "lower_R0")) {
  
  ## Convert simulations to data.table for speed
  sims <- data.table::setDT(sims)
  
  ## Days since the end of the seeding event
  days_since_end_seed <- (lubridate::as_date(condition_date) -
                            lubridate::as_date(end_of_seed_date)) %>%
    as.numeric()
  
  ## Filter to allowed cases
  allowed_scenarios <- WuhanSeedingVsTransmission::condition_on_known(
    sims,
    days_since_end_seed = days_since_end_seed, 
    lower_bound = lower_bound, 
    upper_bound = upper_bound
      )
  
  ##Summarise allowed cases
  prop_allowed <- WuhanSeedingVsTransmission::proportion_allowed_by_condition(allowed_scenarios, 
                                                                              samples = samples,
                                                                              group_var = scenarios_list)
  
  
  ## Restrict sims to allowed scenarios
  restrict_sims <- WuhanSeedingVsTransmission::restrict_by_condition(sims, allowed_scenarios)
  
  
  ## Return output
  out <- list(lubridate::as_date(condition_date),
              prop_allowed,
              restrict_sims)
  names(out) <- c("date_conditioned",
                  "proportion_allowed_sims",
                  "conditioned_sims")
  
  return(out)
  
}
