
#' Print for the mutation.rem function
#'
#' @description Print a summary of results for the random-effect model estimation estimated by the clonal.est function.  
#' @usage ## S3 method for class 'mutation.rem'
#' print(x, ...)
#' @param x a mutation.rem object
#' @param ... Other unused arguments.
#' @return Print results for the model estimates.
#' @seealso mutation.rem
#' @export
#' @method print mutation.rem
#' @S3method print mutation.rem


print.mutation.rem <- function(x, ...) 
{

  if(class(x)!="mutation.rem"){
    stop("The object x must be a class mutation.rem.")
  }else{
    cat("Estimation done on ",dim(x$likmat)[1], "pairs \n")
    cat("\n")
    cat("___ Parameter estimates \n")
    cat("\n")
	cat("Random-effect distribution \n")
	cat(" mean mu =", round(x$mu, 2),"\n", "standard-deviation sigma =", round(x$sigma,2), "\n")
	cat("\n")
	cat("Proportion of clonal pairs \n")
	cat(" pi =", round(x$pi, 3), "\n")
    cat("\n")
    cat("___ Model likelihood and convergence \n")
    cat("\n")
    cat("likelihood ", x$likelihood, "\n")
    cat("convergence status ", x$convergence, "\n")
    cat("number of iterations used", x$n.iter, "\n")
    if(x$print.proba==TRUE){
      cat("\n")
      cat("___ Individual probabilities \n")
      cat("\n")
      outp <- cbind.data.frame(names(x$pr.clonal), round(as.vector(x$pr.clonal),3))
      colnames(outp) <- c("Tumor pairs", "Probability of being clonal")
      print(outp, row.names = F)
    }
  }
}
