# NTBs-and-Textile-Export-Performance

# Introduction 

This document is added to the dofile and the dta file to aid the user to replicate the results in out study. We have 10 dofiles and 1 dta file in the folder called ‘submission.zip’. The dofiles are named, ‘trade_flows.do’, ‘ntm&trade.do’, ‘income_groups.do’, ‘tariffs.do’, ‘rta.do’, ‘gravity covariates.do’, ‘merge_data.do’, ‘frequency_index.do’, ‘model.do’, and ‘descriptive_statistics.do’. The first 8 do files were used for the data cleaning and preparation and the last 2 are used for the main analysis. The dta file is named ‘project.dta’ and it is the final data we used for the analysis.

# Running the dofiles

We have the separate data on trade flows, ntm data, income groups, tariffs, RTA and they are available upon request. We first run trade_flows.do using the data in trade flows and then run ntm&trade.do to merge trade flows to the ntm data so clean it further and make sure the ntm are bilateral. Next, we run income_groups.do using data from the World Bank’s WDI and then run tariffs.do, rta.do, and gravity covariates.do. Finally, we merge data on income groups, tariffs, rta, and gravity covariates to get the complete data. We then use frequency_index.do to calculate the frequency index at the different levels of measurement and also calculate the values for aggregate trade flows and then save the final data as ‘project.dta’.
We expect the user to follow the same steps when replicating the results. However, if the user is not interested in the data cleaning process, then it suffices to use only ‘project.dta’, ‘model.do’, and ‘descriptive_statistics.do’. An important note to make sure that the working directory is always changed before running the dofiles.
