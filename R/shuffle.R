#' Shuffle Variables
#'
#' \code{step_shuffle} creates a \emph{specification} of a recipe step that will
#'   randomly change the order of rows for selected variables.
#'
#' @inheritParams step_center
#' @param ... One or more selector functions to choose which variables will
#'    permuted. See \code{\link{selections}} for  more details.
#' @param role Not used by this step since no new variables are created.
#' @param variables A character string that contains the names of columns that
#'   should be shuffled. These values are not determined until
#'   \code{\link{learn.recipe}} is called.
#' @return \code{step_shuffle}  returns an object of class \code{step_shuffle}.
#' @keywords datagen
#' @concept preprocessing randomization permutation
#' @export
#' @examples
#' integers <- data.frame(A = 1:12, B = 13:24, C = 25:36)
#'
#' library(dplyr)
#' rec <- recipe(~ A + B + C, data = integers) %>%
#'   step_shuffle(A, B)
#'
#' rand_set <- learn(rec, training = integers)
#'
#' set.seed(5377)
#' process(rand_set, integers)

step_shuffle <- function(recipe,
                         ...,
                         role = NA,
                         trained = FALSE,
                         variables = NULL) {
  terms <- quos(...)
  if (is_empty(terms))
    stop("Please supply at least one variable specification.",
         "See ?selections.",
         call. = FALSE)
  add_step(recipe,
           step_shuffle_new(
             terms = terms,
             role = role,
             trained = trained,
             variables = variables
           ))
}

step_shuffle_new <- function(terms = NULL,
                             role = NA,
                             trained = FALSE,
                             variables = NULL) {
  step(
    subclass = "shuffle",
    terms = terms,
    role = role,
    trained = trained,
    variables = variables
  )
}

#' @export
learn.step_shuffle <- function(x, training, info = NULL, ...) {
  col_names <- select_terms(x$terms, info = info)
  step_shuffle_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    variables = col_names
  )
}

#' @export
process.step_shuffle <- function(object, newdata, ...) {
  if (length(object$variables) > 0)
    for (i in seq_along(object$variables))
      newdata[, object$variables[i]] <-
        sample(getElement(newdata, object$variables[i]))
    as_tibble(newdata)
}

print.step_shuffle <-
  function(x, width = max(20, options()$width - 22), ...) {
    if (x$trained) {
      if (length(x$variables) > 0) {
        cat("Variables shuffled ")
        cat(format_ch_vec(x$variables, width = width))
      } else
        cat("No variables were shuffled")
    } else {
      cat("Shuffled terms ", sep = "")
      cat(format_selectors(x$terms, wdth = width))
    }
    if (x$trained)
      cat(" [trained]\n")
    else
      cat("\n")
    invisible(x)
  }