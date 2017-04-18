
#' Estimation of the random-effect model for clonality based on mutations.
#'
#' @description The model estimates the proportion of clonal cases in a population, and the distribution of the clonality signal.  
#' @usage mutation.rem(mutmat, proba=FALSE, print.proba=FALSE, xigrid = c(0, seq(0.0005, 0.9995, by=0.001)), init.para = c(0,1,0.5) )
#' @param mutmat Matrix containing the data, with all mutations in rows and the tumor pairs in columns. 
#' The data are coded as 0=mutation not observed, 1=shared mutation (observed in both tumors), 2=private mutation 
#' (observed in one tumor only). The first column contains the probabilities of occurence for each mutation.
#' @param proba Indicates whether to compute the individual probabilities of clonality for each pair. The default is FALSE.
#' @param sd.err Indicates whether to compute the standard errors of the estimated parameters. The default is FALSE.
#' @param print.proba Indicates whether the individual probabilities of clonality should be printed in the output. The default 
#' is TRUE if proba=TRUE and FALSE if proba=FALSE.
#' @param print.sd.err Indicates whether the the standard errors of the estimated parameters should be printed in the output. The default 
#' is TRUE if sd.err=TRUE and FALSE if sd.err=FALSE.
#' @param xigrid Grid of the values of xi used to compute the integration; it corresponds to the domain of 
#' definition of xi. The default is c(0, seq(0.0005, 0.9995, by=0.001)).
#' @param init.para Initial values of the parameters for the optimization. The order of the parameters is 
#' c(mu, sigma, pi), where mu and sigma are the mean and variance of the lognormal distribution 
#' of the random-effect xi, and pi is the proportion of clonal cases. The default is c(0,1,0.5).
#' @details The function estimates a random effects model in which the random effect (the clonality signal, denoted xi_i for the ith case) 
#' reflects the somatic similarity of the tumors on a scale from 0 to 1, where 0 represents independence and higher values represent 
#' clonal tumors that are increasingly similar. The proportion of cases that are clonal is represented by the parameter pi. Thus 
#' the likelihood is a compound of (1-pi) cases that have a clonality signal of exactly 0, and pi cases that have a clonality signal 
#' drawn from a normal random effects distribution with mean mu and variance sigma^2. The program estimates all of the parameters and 
#' their variances using maximum likelihood. The output provides parameter estimates (mu, sigma, pi). The example dataset presented 
#' contains data from a study in which each patient has both a pre-malignant lobular carcinoma in situ (LCIS) and an invasive 
#' breast cancer, and we wish to estimate the proportion of these cases for which the LCIS was a direct precursor to the invasive cancer.
#' The standard errors are computed using the inverse of minus the Hessian matrix.
#' 
#' @return 
#'   \item{mu}{Estimated mean of the random-effect distribution.}
#'   \item{sigma}{Estimated standard-deviation of the random-effect distribution.}
#'   \item{pi}{Estimated proportion of clonal pairs in the population.}
#'   \item{likmat}{Grid of likelihood values for each tumor pair (rows) and each value of xi (columns) needed for the function 
#'  clonal.proba that computes the individual probabilities of clonality.}
#'   \item{likelihood}{Value of the maximized likelihood.}
#'   \item{convergence}{Convergence status (from the function optim).}
#'   \item{conv.message}{Convergence message (from the function optim).}
#'   \item{pr.clonal}{Individual probabilities of clonality.}
#' @author Audrey Mauguen \email{mauguena@mskcc.org} and Venkatraman E. Seshan.
#' @references Mauguen A, Seshan VE, Ostrovnaya I, Begg CB. Estimating the Probability of Clonal Relatedness of 
#' Pairs of Tumors in Cancer Patients. Submitted.
#' @examples
#' #___ Analysis of LCIS data
#' data(lcis)
#' 
#' #__ Parameters estimation
#' mod <- mutation.rem(lcis)
#' mod
#' 
#' #__ Parameters estimation with standard errors
#' mod <- mutation.rem(lcis, sd.err=TRUE)
#' mod
#' 
#' #__ Probability of being clonal
#' mod <- mutation.rem(lcis, proba=TRUE)
#' mod
#' @export



mutation.rem <- function(mutmat, proba=FALSE, sd.err = FALSE, print.proba=proba, print.sd.err=sd.err, xigrid = c(0, seq(0.0005, 0.9995, by=0.001)), init.para = c(0,1,0.5) ){

  # Grid of likelihood values for each cases (rows) and each value of xi (columns)
  likmat <- grid.lik(xigrid, mutmat[,c(-1)], mutmat[,1])
  # Maximum likelihood estimators
  out0 <- -100*abs(sum(log( init.para[3] * likmat[,-1] %*% xidens(init.para[1],init.para[2],xigrid)[-1]  * 0.001 + init.para[3] * likmat[,1] ) ))
  est <- optim(par = init.para, model.lik, likmat=likmat, out0=out0, xigrid=xigrid,
               lower=c(-1000,0.1,0), upper=c(1000,1000,1),
               method="L-BFGS-B", control=list(fnscale=-1), hessian = sd.err  )
  out <- NULL
  out$mu <- est$par[1]
  out$sigma <- est$par[2]
  out$pi <- est$par[3]
  out$likelihood <- est$value
  out$convergence <- est$convergence
  out$conv.message <- est$message
  out$likmat <- likmat
  
  if(proba==TRUE){
    pclon <- est$par[3] * rowSums(likmat[,-1] %*% xidens(est$par[1],est$par[2], xigrid)[-1] ) * 0.001
    pnclon <- (1-est$par[3]) * likmat[,1]
    out$pr.clonal <- pclon / (pclon+pnclon)
  }
  else{
    out$pr.clonal <- NULL
    print.proba <- FALSE
  }
  if(sd.err == TRUE){
    serr <- sqrt(diag(solve(-est$hessian)))
    out$se.mu <- serr[1]
    out$se.sigma <- serr[2]
    out$se.pi <- serr[3]
  }
  else{
    out$se.mu <- out$se.sigma <- out$se.pi <- NULL
    print.sd.err <- FALSE
  }
  out$print.proba <- print.proba
  out$print.sd.err <- print.sd.err
  class(out) <- "mutation.rem"
  out
}

