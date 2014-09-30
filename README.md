*Jay Jacobs, August 8th, 2014*

This is an implement of a classification algorithm trained on 74,954 legitamate domains (taken from the Alexa list of popular web sites and the Open DNS popular domains list), as well as 35,154 algorithmically generated domains from the Cryptolocker and GOZ botnet. 80% was used in the training with 20% left for testing.

Given a domain name the function will classify it as either "dga" or "legit" and include the probability of the classification.

Begin by loading up the DGA library (note: you may get an error on install\_github if you had never ‘git clone’d before, or added the host as a known SSH host).

``` {.r}
install_git(“ssh://git@gitlab.dds.ec:22022/jay.jacobs/dga.git”)
```

``` {.r}
library(dga)
```

Let's test with the easy most popular websites, and classify them as either "legit" or "dga".

``` {.r}
good20 <- c("facebook.com", "google.com", "youtube.com",
           "yahoo.com", "baidu.com", "wikipedia.org",
           "amazon.com", "live.com", "qq.com",
           "taobao.com", "blogspot.com", "google.co.in",
           "twitter.com", "linkedin.com", "yahoo.co.jp",
           "bing.com", "sina.com.cn", "yandex.ru",
           "msn.com", "vk.com")

dgaPredict(good20)
```

    ## Loading required package: randomForest
    ## randomForest 4.6-10
    ## Type rfNews() to see new features/changes/bug fixes.

    ##         name class  prob
    ## 1   facebook legit 1.000
    ## 2     google legit 1.000
    ## 3    youtube legit 1.000
    ## 4      yahoo legit 1.000
    ## 5      baidu legit 1.000
    ## 6  wikipedia legit 0.998
    ## 7     amazon legit 1.000
    ## 8       live legit 1.000
    ## 9         qq   dga 1.000
    ## 10    taobao legit 1.000
    ## 11  blogspot legit 1.000
    ## 12    google legit 1.000
    ## 13   twitter legit 1.000
    ## 14  linkedin legit 1.000
    ## 15     yahoo legit 1.000
    ## 16      bing legit 1.000
    ## 17      sina legit 1.000
    ## 18    yandex legit 1.000
    ## 19       msn legit 1.000
    ## 20        vk   dga 1.000

Now some domain generated algorithms from the cryptolocker botnet:

``` {.r}
bad20 <- c("btpdeqvfmjxbay.ru", "rrpmjoxjsbsw.ru", "wibiqshumvpns.ru", 
           "mhdvnabqmbwehm.ru", "chyfrroprecy.ru", "uyhdbelswnhkmhc.ru",
           "kqcrotywqigo.ru", "rlvukicfjceajm.ru", "ibxaoddvcped.ru", 
           "tntuqxxbvxytpif.ru", "heksblnvanyeug.ru", "keaeodsrfafqpdp.ru",
           "hwenbesxjwrwa.ru", "oovftsaempntpx.ru", "uipgqhfrojbnjo.ru", 
           "igpjponmegrxjtr.ru", "eoitadcdyaeqh.ru", "bqadfgvmxmypkr.ru", 
           "bycoifplnumy.ru", "aeqcwsreocpbm.ru")
dgaPredict(bad20)
```

    ##               name class  prob
    ## 1   btpdeqvfmjxbay   dga 1.000
    ## 2     rrpmjoxjsbsw   dga 1.000
    ## 3    wibiqshumvpns   dga 1.000
    ## 4   mhdvnabqmbwehm   dga 1.000
    ## 5     chyfrroprecy   dga 0.854
    ## 6  uyhdbelswnhkmhc   dga 1.000
    ## 7     kqcrotywqigo   dga 1.000
    ## 8   rlvukicfjceajm   dga 1.000
    ## 9     ibxaoddvcped   dga 1.000
    ## 10 tntuqxxbvxytpif   dga 1.000
    ## 11  heksblnvanyeug   dga 0.980
    ## 12 keaeodsrfafqpdp legit 0.998
    ## 13   hwenbesxjwrwa   dga 1.000
    ## 14  oovftsaempntpx   dga 1.000
    ## 15  uipgqhfrojbnjo   dga 1.000
    ## 16 igpjponmegrxjtr   dga 1.000
    ## 17   eoitadcdyaeqh   dga 1.000
    ## 18  bqadfgvmxmypkr   dga 1.000
    ## 19    bycoifplnumy   dga 1.000
    ## 20   aeqcwsreocpbm   dga 1.000

Algorithm is about 99.5% effective, so some things are misclassified, the "prob" (probability) column can be used to manually inspect some of the output.

``` {.r}
borderline <- c("get-social.info", "nightlife141.com", "dogusyayingrubu.com.tr",
                "lowesracing.com", "whoisbucket.com", "dhonegcndisiewk.ru", 
                "gughtatejiarpb.ru", "dubaipolice.gov.ae", "walkerland.com.tw", 
                "xphsergercoyth.ru", "oceanviewblvd.com", "berndsbumstipps.net", 
                "ebaumsworld.com", "johnbridge.com", "thumbalizr.com", "superbniews.com")

dgaPredict(borderline)
```

    ##               name class  prob
    ## 1       get-social legit 1.000
    ## 2     nightlife141 legit 0.928
    ## 3  dogusyayingrubu legit 1.000
    ## 4      lowesracing legit 1.000
    ## 5      whoisbucket legit 1.000
    ## 6  dhonegcndisiewk legit 1.000
    ## 7   gughtatejiarpb   dga 0.532
    ## 8      dubaipolice legit 1.000
    ## 9       walkerland legit 1.000
    ## 10  xphsergercoyth   dga 0.548
    ## 11   oceanviewblvd legit 1.000
    ## 12 berndsbumstipps legit 1.000
    ## 13     ebaumsworld legit 1.000
    ## 14      johnbridge legit 1.000
    ## 15      thumbalizr legit 1.000
    ## 16     superbniews legit 1.000

So if the application is more sensitive to misclassification, the threshold for classification can be adjusted up or down, notice the probability shown is the confidence in classification, so it will dip beneath 0.5 for legitimate domains if dgaThreshold is raised.

``` {.r}
dgaPredict(borderline, dgaThreshold=0.55)
```

    ##               name class  prob
    ## 1       get-social legit 1.000
    ## 2     nightlife141 legit 0.928
    ## 3  dogusyayingrubu legit 1.000
    ## 4      lowesracing legit 1.000
    ## 5      whoisbucket legit 1.000
    ## 6  dhonegcndisiewk legit 1.000
    ## 7   gughtatejiarpb legit 0.468
    ## 8      dubaipolice legit 1.000
    ## 9       walkerland legit 1.000
    ## 10  xphsergercoyth legit 0.452
    ## 11   oceanviewblvd legit 1.000
    ## 12 berndsbumstipps legit 1.000
    ## 13     ebaumsworld legit 1.000
    ## 14      johnbridge legit 1.000
    ## 15      thumbalizr legit 1.000
    ## 16     superbniews legit 1.000

This uses a Random Forest model:

    ## Random Forest 
    ## 
    ## 85457 samples
    ##     3 predictors
    ##     2 classes: 'legit', 'dga' 
    ## 
    ## No pre-processing
    ## Resampling: Cross-Validated (10 fold, repeated 5 times) 
    ## 
    ## Summary of sample sizes: 76911, 76911, 76911, 76912, 76912, 76911, ... 
    ## 
    ## Resampling results across tuning parameters:
    ## 
    ##   mtry  ROC  Sens  Spec  ROC SD  Sens SD  Spec SD
    ##   2     1    1     1     6e-04   0.002    0.002  
    ##   3     1    1     1     9e-04   0.002    0.002  
    ## 
    ## ROC was used to select the optimal model using  the largest value.
    ## The final value used for the model was mtry = 2.

And the confusion matrix:

    ## Cross-Validated (10 fold, repeated 5 times) Confusion Matrix 
    ## 
    ## (entries are percentages of table totals)
    ##  
    ##           Reference
    ## Prediction legit  dga
    ##      legit  43.7  1.0
    ##      dga     1.0 54.3
