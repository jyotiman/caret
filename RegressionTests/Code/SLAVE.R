library(caret)
timestamp <- format(Sys.time(), "%Y_%m_%d_%H_%M")

model <- "SLAVE"

#########################################################################

set.seed(2)
training <- twoClassSim(30, linearVars = 2)[, 5:8]
testing <- twoClassSim(30, linearVars = 2)[, 5:8]
trainX <- training[, -ncol(training)]
trainY <- training$Class

seeds <- vector(mode = "list", length = nrow(training) + 1)
seeds <- lapply(seeds, function(x) 1:3)

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all", seed = seeds)
cctrl2 <- trainControl(method = "LOOCV", seed = seeds)
cctrl3 <- trainControl(method = "none", seed = seeds)

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "SLAVE", 
                             trControl = cctrl1,
                             tuneLength = 2,
                             preProc = c("center", "scale"))

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "SLAVE", 
                            trControl = cctrl1,
                            tuneLength = 2,
                            preProc = c("center", "scale"))

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "SLAVE", 
                              trControl = cctrl2,
                              tuneLength = 2)

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "SLAVE", 
                               trControl = cctrl3,
                               tuneGrid = test_class_cv_model$bestTune,
                               preProc = c("center", "scale"))

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

sInfo <- sessionInfo()

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

save(list = c(tests, "sInfo", "timestamp"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")

