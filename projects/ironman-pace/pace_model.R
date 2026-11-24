# ------------------------------------------------------------
# 70.3 run pace model: train on pre-triathlon runs, test on new ones
# Uses strava_runs_clean.csv (the output of strava_filter_1.R)
# ------------------------------------------------------------
library(tidyverse)

runs <- read_csv("strava_runs_clean.csv") %>%
  mutate(
    elev_pm = elev_ft / miles,                                     # feet of climb per mile
    weeks   = as.numeric(day - as_date("2025-04-28")) / 7,         # fitness trend
    trail   = as.integer(str_detect(name, regex("trail|wildwood|ultra", ignore_case = TRUE)))
  )

# 1. Fit the model ----------------------------------------------
fit <- lm(pace ~ miles + avg_hr + treadmill + elev_pm + weeks + trail, data = runs)
summary(fit)
# Per-mile effects, in seconds:
round(coef(fit)[-1] * 60, 1)   # avg_hr x10 = ~23 s faster, weeks x4.35 = ~8 s/month faster

# 2. 5-fold cross-validated error on the training runs ----------
set.seed(1)
folds <- sample(rep(1:5, length.out = nrow(runs)))
cv_err <- map_dbl(1:5, function(k) {
  m <- lm(formula(fit), data = runs[folds != k, ])
  mean(abs(predict(m, runs[folds == k, ]) - runs$pace[folds == k]))
})
mean(cv_err) * 60   # ~41 sec per mile (random fold split, so yours may differ slightly)

# 3. Test on the 12 runs since Oct 13 (from COROS) ---------------
test <- tribble(
  ~day,         ~km,   ~sec,          ~avg_hr, ~treadmill, ~elev_m,
  "2026-10-14", 4.83,  24*60 + 10,    140,     1,          0,
  "2026-10-16", 11.28, 63*60 + 45,    154,     1,          0,
  "2026-10-20", 6.20,  35*60,         158,     1,          0,
  "2026-10-22", 3.28,  17*60 + 20,    141,     1,          0,
  "2026-10-25", 5.41,  30*60 + 6,     152,     1,          0,
  "2026-10-27", 3.50,  20*60 + 6,     141,     1,          0,
  "2026-10-27", 3.56,  20*60,         150,     0,          48,
  "2026-11-01", 9.83,  74*60 + 11,    129,     0,          121,
  "2026-11-10", 3.04,  17*60 + 52,    145,     1,          0,
  "2026-11-11", 5.08,  38*60 + 28,    124,     1,          0,
  "2026-11-15", 3.91,  23*60 + 22,    144,     0,          34,
  "2026-11-17", 3.62,  21*60 + 1,     149,     1,          0
) %>%
  mutate(
    day     = as_date(day),
    miles   = km / 1.609344,
    pace    = (sec / 60) / miles,
    elev_pm = elev_m * 3.28084 / miles,
    weeks   = as.numeric(day - as_date("2025-04-28")) / 7,
    trail   = 0
  ) %>%
  mutate(pred = predict(fit, newdata = .), miss_s = (pace - pred) * 60)

test %>% select(day, miles, avg_hr, pace, pred, miss_s)
mean(abs(test$miss_s))   # ~69 sec: average miss
sum(test$miss_s > 0)     # 10 of 12 guessed too fast

# 4. 70.3 projection: 13.1 mi outside at 150 bpm, "if I raced today" ---
race <- tibble(miles = 13.1, avg_hr = 150, treadmill = 0,
               elev_pm = median(runs$elev_pm[runs$treadmill == 0 & runs$trail == 0 & runs$miles >= 8]),
               weeks = as.numeric(as_date("2026-11-23") - as_date("2025-04-28")) / 7, trail = 0)
predict(fit, race)       # ~8.58 min/mi = 8:35
