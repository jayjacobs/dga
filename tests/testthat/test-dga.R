context("DGA Classifier")
good20 <- c("facebook.com", "google.com", "youtube.com",
            "yahoo.com", "baidu.com", "wikipedia.org",
            "amazon.com", "live.com", "quickquik.com",
            "taobao.com", "blogspot.com", "google.co.in",
            "twitter.com", "linkedin.com", "yahoo.co.jp",
            "bing.com", "sina.com.cn", "yandex.ru",
            "msn.com", "vikings.com")
bad20 <- c("btpdeqvfmjxbay.ru", "rrpmjoxjsbsw.ru", "wibiqshumvpns.ru", 
           "mhdvnabqmbwehm.ru", "chyfrroprecy.ru", "uyhdbelswnhkmhc.ru",
           "kqcrotywqigo.ru", "rlvukicfjceajm.ru", "ibxaoddvcped.ru", 
           "tntuqxxbvxytpif.ru", "heksblnvanyeug.ru", "kea3eo3dsrfa2fqpdp.ru",
           "hwenbesxjwrwa.ru", "oovftsaempntpx.ru", "uipgqhfrojbnjo.ru", 
           "igpjponmegrxjtr.ru", "eoitadcdyaeqh.ru", "bqadfgvmxmypkr.ru", 
           "bycoifplnumy.ru", "aeqcwsreocpbm.ru")
rez <- dgaPredict(c(good20, bad20))

# test_that("Checks valid hosts", {
#   expect_identical(as.character(rez$class), c(rep("legit", 20), rep("dga", 20)))
# })