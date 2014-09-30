#' Classify a vector of DNS names
#' 
#' Given one or more DNS names, this will predict whether or not it is generated
#' by an algorithm or if it is a legitamate domain name.
#' 
#' @param dns vector of dns names to classify
#' @param dgaThreshold the threshold at which to split DGA from legit
#' @export
dgaPredict <- function(dns, dgaThreshold=0.5) {
  pdomain <- data.frame(name=dns, domain=tldextract(tolower(dns))$domain, stringsAsFactors = F)
  dgaPredictDomain(pdomain$domain, dgaThreshold)
}

#' Classify a vector of stripped domain names
#' 
#' Given one or more stripped domain names (just the domain portion of the name), 
#' this will predict whether or not it is generated
#' by an algorithm or if it is a legitamate domain name.
#' 
#' @param dns vector of stripped domain names to classify
#' @param dgaThreshold the threshold at which to split DGA from legit
#' @export
#' @import caret
dgaPredictDomain <- function(dns, dgaThreshold=0.5) {
  pdomain <- data.frame(name=dns)
  fields <- c("class", "dict", "gram345", "length")
  pdomain$length <- nchar(dns)
  pdomain$dict <- wmatch(dns, cnum=FALSE)
  pdomain$gram345 <- getngram(gram345, dns)
  outs <- predict(rfFit, newdata=pdomain, type="prob")
  data.frame(name=pdomain$name, class=ifelse(outs$dga>=dgaThreshold, "dga", "legit"),
             prob=ifelse(outs$dga>=dgaThreshold, outs$dga, outs$legit))
}


#' Calculate the proportion of a string that matches dictionary words
#' 
#' Given a word (or vector of character/words), this will do substring
#' matches of the string against a dictionary of known words and 
#' return the percentage of letters in the word that are explained
#' by the dictionary.
#' 
#' @param text character object (or vector) of words to match
#' @param cnum logical whether to count numbers as a match or not, if not counted and the word contains numbers it will never be 100\% match.
#' @import stringr
wmatch <- function(text, cnum = T) {
  matched <- lapply(text, function(txt) rep(F, nchar(txt)))
  if(cnum) {
    outs <- str_locate_all(text, "[0-9]")
    for(i in seq_along(outs)) {
      matched[[i]][outs[[i]][, 1]] <- TRUE
    }
  }
  top <- min(max(nchar(text)), length(dwords))
  for(tlen in seq(top, 3)) {
    ngs <- ngram.name(text, n=tlen)
    for(i in seq_along(ngs)) {
      pos <- which(ngs[[i]] %in% dwords[[tlen]])
      for(x in pos) {
        matched[[i]][x:(x+tlen-1)] <- T
      }
    }
  }
  sapply(matched, mean)
}



#' Tranform a vector of DNS entries to a clean data frame
#' 
#' given a vector of DNS entries, this will call tldextract and do
#' the following clean up tasks:
#' * remove any invalid entries (no top level domain matched)
#' * remove any duplciated entries
#' * strip any domain less than \code{strip.len} characters long.
#' 
#' @param dnames the input vector of names
#' @param strip.len numeric on which to remove variables
#' @export
#' @import tldextract
cleandns <- function(dnames, strip.len=6) {
  tld <- tldextract(dnames)
  # pull invalid names
  tld <- tld[!is.na(tld$tld), ]
  # remove duplicates
  tld <- tld[!duplicated(tld), ]
  # yank domains < 6 characters
  tld <- tld[sapply(tld$domain, nchar) > strip.len, ]
  tld
}

#' Get a sparse matrix of ngrams from a word, given an existing ngram matrix
#' 
#' Given a vector of words and the length of grams to slice, this will
#' return a matrix of counts each ngram appears in the words.
#' 
#' @param fit existing ngram counts (vector) to match
#' @param newtxt the new word to match ngrams and count
#' @export
getngram <- function(fit, newtxt) {
  n <- unique(sapply(colnames(fit), nchar))
  sapply(newtxt, function(domain) {
    cnm.list <- table(unlist(ngram.name(domain, n)))
    matched <- names(cnm.list) %in% colnames(fit)
    colmatch <- colnames(fit) %in% names(cnm.list)
    out <- matrix(0, ncol=ncol(fit), dimnames=list(NULL, colnames(fit)))
    out[1, colmatch] <- cnm.list[matched]
    as.vector(fit %*% t(out))    
  })
}

#' Get a sparse matrix of ngrams from words
#' 
#' Given a vector of words and the length of grams to slice, this will
#' return a matrix of counts each ngram appears in the words.
#' 
#' @param instr vector of words to analyze
#' @param n one or more lengths of n-grams to cut
#' @param minct minimum count (as percent of total) to include in n-grams
#' @export
ngram <- function(instr, n, minct=0.0005) {
  cnm.list <- ngram.name(instr, n)
  # get a count of appearances in words
  cnm.count <- table(unlist(lapply(cnm.list, unique)))
  # get a unique list of names matching at least <minct>*<words> amount
  cnm <- unique(names(cnm.count)[cnm.count>=(minct*length(instr))])
  cnm.counts <- table(unlist(cnm.list))
  outs <- cnm.counts[names(cnm.counts) %in% cnm]
  #matrix(scale(outs, center=F), nrow=1, dimnames=list(NULL, cnm))
  matrix(log10(outs), nrow=1, dimnames=list(NULL, cnm))
  
}

#' Calculate the entropy for a given string
#' 
#' Given a string this will return a numric with the entropy of the 
#' characters in the string.
#' 
#' @param instr character or vector of characters to calculate entropy on
#' @param n one or more lengths of n-grams to cut
ngram.name <- function(instr, n) {
  lapply(instr, function(x) {
    first <- unlist(strsplit(x, NULL))
    lns <- nchar(x)
    unlist(lapply(n[n<=lns], function(i) {
      sapply(seq(i, lns), function(p) paste0(first[(p-(i-1)):p], collapse="") )  
    }))
  })
}

#' Calculate the entropy for a given string
#' 
#' Given a string this will return a numric with the entropy of the 
#' characters in the string.
#' 
#' @param instr character or vector of characters to calculate entropy on
#' @export
entropy <- function(instr) {
  if (mode(instr)!="character")
    stop("Expected character array, got ", mode(instr))
  sapply(instr, function(x) {
    cts <- table(unlist(strsplit(x, NULL)))
    lns <- nchar(x)
    -sum((cts/lns) * log2(cts/lns))    
  })
}

#' frequency count of domain name based n-grams
#' 
#' A dataset containing a transformed frequency count of {3,4,5}-grams extracted 
#' from a dictionary of words. 
#' 
#' @docType data
#' @keywords datasets
#' @format frequency count
#' @name gram345
NULL

#' dictionary of words
#' 
#' A dataset containing a dictionary of words seperated by their length.
#' 
#' @docType data
#' @keywords datasets
#' @format frequency count
#' @name dwords
NULL

#' sampledga: a sample of DGA based values
#' 
#' sample of DGA and legit domains
#' 
#' @docType data
#' @keywords datasets
#' @format frequency count
#' @name sampledga
NULL

#' modelrf: the random forest model for DGA classification
#' 
#' the RF model 
#' 
#' @docType data
#' @keywords datasets
#' @format frequency count
#' @name rfFit
NULL

