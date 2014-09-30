This is an implement of a classification algorithm trained on legitamate domains (taken from the Alexa list of popular web sites and the Open DNS popular domains list), as well as algorithmically generated domains from the Cryptolocker and GOZ botnet.

Given a domain name the function will classify it as either "dga" or "legit" and include the probability of the classification.

Begin by loading up the DGA library (note: you may get an error on install\_github if you had never ‘git clone’d before, or added the host as a known SSH host).

``` {.r}
devtools::install_github("jayjacobs/dga")
```

``` {.r}
library(dga)
```

Let's test with the easy most popular websites, and classify them as either "legit" or "dga".

``` {.r}
good20 <- c("facebook.com", "google.com", "youtube.com",
           "yahoo.com", "baidu.com", "wikipedia.org",
           "amazon.com", "live.com", "quicken.com",
           "taobao.com", "blogspot.com", "google.co.in",
           "twitter.com", "linkedin.com", "yahoo.co.jp",
           "bing.com", "sina.com.cn", "yandex.ru",
           "msn.com", "vikings.com")

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
    ## 9    quicken legit 1.000
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
    ## 20   vikings legit 1.000

Now some domain generated algorithms from the cryptolocker botnet:

``` {.r}
bad20 <- c("btpdeqvfmjxbay.ru", "rrpmjoxjsbsw.ru", "wibiqshumvpns.ru", 
           "mhdvnabqmbwehm.ru", "chyfrroprecy.ru", "uyhdbelswnhkmhc.ru",
           "kqcrotywqigo.ru", "rlvukicfjceajm.ru", "ibxaoddvcped.ru", 
           "tntuqxxbvxytpif.ru", "heksblnvanyeug.ru", "kexngyjudoptjv.ru",
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
    ## 12  kexngyjudoptjv   dga 1.000
    ## 13   hwenbesxjwrwa   dga 1.000
    ## 14  oovftsaempntpx   dga 1.000
    ## 15  uipgqhfrojbnjo   dga 1.000
    ## 16 igpjponmegrxjtr   dga 1.000
    ## 17   eoitadcdyaeqh   dga 1.000
    ## 18  bqadfgvmxmypkr   dga 1.000
    ## 19    bycoifplnumy   dga 1.000
    ## 20   aeqcwsreocpbm   dga 1.000

Algorithm is about 98% effective, so some things are misclassified, the "prob" (probability) column can be used to manually inspect some of the output.

``` {.r}
borderline <- c("20minutes.fr", "siriusxm.com", "fileblckr.com", "haus-am-brunnen.de", 
                "left21.com", "rw3ramr.info", "letter861cod.info", "mintadelpyjychw.ru", 
                "zsdm7erb.us", "surceskmgf.net")

dgaPredict(borderline)
```

    ##               name class  prob
    ## 1        20minutes   dga 0.588
    ## 2         siriusxm   dga 0.550
    ## 3        fileblckr   dga 0.576
    ## 4  haus-am-brunnen   dga 0.520
    ## 5           left21   dga 0.540
    ## 6          rw3ramr legit 0.546
    ## 7     letter861cod legit 0.536
    ## 8  mintadelpyjychw legit 0.522
    ## 9         zsdm7erb legit 0.524
    ## 10      surceskmgf legit 0.582

So if the application is more sensitive to misclassification, the threshold for classification can be adjusted up or down, notice the probability shown is the confidence in classification, so it will dip beneath 0.5 for legitimate domains if dgaThreshold is raised.

``` {.r}
dgaPredict(borderline, dgaThreshold=0.55)
```

    ##               name class  prob
    ## 1        20minutes   dga 0.588
    ## 2         siriusxm   dga 0.550
    ## 3        fileblckr   dga 0.576
    ## 4  haus-am-brunnen legit 0.480
    ## 5           left21 legit 0.460
    ## 6          rw3ramr legit 0.546
    ## 7     letter861cod legit 0.536
    ## 8  mintadelpyjychw legit 0.522
    ## 9         zsdm7erb legit 0.524
    ## 10      surceskmgf legit 0.582

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
