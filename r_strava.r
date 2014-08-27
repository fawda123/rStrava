######
# testing for rStrava

source('funcs.r')

# what is max val of athlete number?
# check if athletes exist
athl_chks <- 999999:2000000
athl_chks <- sample(athl_chks, 30)
system.time({
  for(val in 1:length(athl_chks)){
    cat(val, '\t')
    athl_num <- athl_chks[val]
    try_athl <- try(athl_fun(athl_num))
    if('try-error' %in% class(try_athl)) athl_chks[val] <- NA_real_
    }
  }
)

# me
athl_num <- 2837007

athl_xml <- athl_fun(athl_num)
athl_xml

# some debugging w/ random athletes

rand <- sample(1:2e6, 1)
athl_xml <- athl_fun(rand)
athl_xml
