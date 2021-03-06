\name{SNVtest}
\alias{SNVtest}

\title{
Testing relatedness (clonality) of two tumors from the same patient using profiles of somatic mutations
}
\description{
Function to test clonality of two tumors from the same patient based on their mutational profiles. This function calculates conditional likelihood ratio relying only on loci where at least one of the tumors has a mutation, and p-value is calculated under the reference distribution under the hypothesis of independence.
}
\usage{
SNVtest(tumor1, tumor2, pfreq, nrep = 1000)
}
\arguments{
  \item{tumor1}{
Vector of the binary mutation calls from tumor 1, where 0 denotes no mutation, 1 denotes a mutation. Mutations should be in the same order as frequencies in  pfreq.
}
  \item{tumor2}{
Vector of the binary mutation calls from tumor 2, where 0 denotes no mutation, 1 denotes a mutation. Mutations should be in the same order as frequencies in  pfreq.
}
  \item{pfreq}{
Marginal frequencies of mutations known a priori. These can be obtained from TCGA or similar databases. We recommend setting these frequencies to (x+y)(nx+ny), where x is the number of patients with the mutations in the TCGA( or other databases), and nx is the total number of the patients in TCGA; y and ny is number of patients with mutations and total number of patients in this study.
}
  \item{nrep}{
Number of simulations used for generating the reference distribution under the hypothesis of independence.
}
}
\details{
Only loci where at least one tumor has a mutation contribute to the model. The null distribution is patient specific since it is generated assuming the same total number of mutations in two tumors.
}
\value{
The output is a vector with 5 values:
"n1","n2","n_match", "LRstat","maxKsi","LRpvalue"

 \item{n1 }{Number of mutations in the first tumor.}
 \item{n2 }{Number of mutations in the second tumor}
 \item{n_match}{Number of matches. i.e. loci where both tumors have an identical mutation} 
 \item{LRstat }{Likelihood ratio statistic} 
 \item{maxKsi }{Maximum likelhood estimate of Ksi, parameter of the likelihood representing clonality strength. Value close to 0 indicates independence, value close to 1 indicates perfect concordance in mutational profiles.} 
 \item{LRpvalue }{p-value calculated using the null distribution generated using prespecified mutational frequencies  pfreq.}
 
}
\references{

Ostrovnaya I, Seshan VE, Begg CB. "USING SOMATIC MUTATION DATA TO TEST TUMORS FOR CLONAL RELATEDNESS.", Ann Appl Stat. 2015 Sep;9(3):1533-1548}
\author{
Irina Ostrovnaya \email{ostrovni@mskcc.org}
}

\seealso{
clonality.analysis() for test using genomewide copy number profiles; mutation.proba() for bayseian inference of clonality probability.
}
\examples{
#___ Analysis of LCIS data from the following paper: 
#Begg CB, Ostrovnaya I, Carniello JV, Sakr RA, Giri D, Towers R, Schizas M, De Brot M, Andrade VP, Mauguen A, Seshan VE, King TA. "Clonal relationships between lobular carcinoma in situ and other breast malignancies.", Breast Cancer Res. 2016 Jun 23;18(1):66. doi: 10.1186/s13058-016-0727-z.

data(lcis)
data(freqdata)
n<-nrow(lcis)

#Example of artificially generated independent tumor pair with marginal mutation frequencies p
n<-100
p<-runif(n)/10
x1<-as.numeric(runif(n)<=p)
x2<-as.numeric(runif(n)<=p)
SNVtest(x1,x2,p)


#Analysis of data from patient 53
mut.matrix<-create.mutation.matrix(lcis )
table(mut.matrix$TK53IDC2,mut.matrix$TK53LCIS2)

freq<-get.mutation.frequencies(rownames(mut.matrix),"BRCA") 

SNVtest(mut.matrix$TK53IDC2,mut.matrix$TK53LCIS2,freq)


}

