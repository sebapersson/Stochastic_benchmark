library(tidyverse)
library(ggthemes)
library(rjson)

# General plotting parameters (plot using theme-tufte)
cbPalette <- c(
  "#999999", "#E69F00", "#56B4E9", "#009E73",
  "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
my_theme <- theme_bw(base_size = 16) + theme(plot.title = element_text(hjust = 0.5, size = 14, face="bold"), 
                                             plot.subtitle = element_text(hjust = 0.5)) +
  theme(axis.title=element_text(size=21))
BASE_HEIGHT <- 5
BASE_WIDTH <- 7.0

process_julia_res <- function(model_name, software, multisites=F)
{
  
  if( software == "SBMLImporter" || software == "ReactionNetworkImporters"){
    method_list <- c("Direct", "SortingDirect", "RSSA", "RSSACR")  
  }
  if( software == "RoadRunner"){
    method_list <- c("SSA")
  }
  
  if( model_name == "multistate" ){
    timepoints_ <- 10^seq(from = 1, to = 5, length.out=9)
  }
  if( model_name == "multisite2" ){
    timepoints_ <- 10^seq(from = 1, to = 4, length.out=7)
  }
  if( model_name == "egfr_net" ){
    timepoints_ <- 10^seq(from = 1, to = 3, length.out=7)
  }
  if( model_name == "fceri_gamma2" ){
    timepoints_ <- 10^seq(from = 1, to = 3, length.out=7)
  }
  if( model_name == "BCR" ){
    timepoints_ <- 10^seq(from = 3.398, to = 5.01, length.out=3)
  }
  if( multisites == T ){
    timepoints_ <- 10^seq(from = 1, to = 3, length.out=3)
  }
  
  data_ret <- tibble()
  for( method in method_list){
    path_data <- str_c("../Results/", software, "/", method, "_", model_name, ".json")
    if( !file.exists(path_data) ){
      next
    }
    
    data <- fromJSON(file = path_data)
    data_ret_ <- tibble(median = data$medians / 1000, # in unit S
                        timepoints = timepoints_[1:length(data$medians)], 
                        model_name = model_name, 
                        method = method, 
                        software = software, 
                        method_alt = str_c(software, "_", method))      
    data_ret <- bind_rows(data_ret, data_ret_)
  }
  return(data_ret)
}

process_python_res <- function(model_name, software)
{
  if( software == "PySB"){
    method_list <- c("NFsim", "SortingDirect")
    method_list_short <- c("nf", "ssa")
  }
  
  data_ret <- tibble()
  for( i in 1:length(method_list) ){
    path_res <- str_c("../Results/", software, "/", method_list_short[i], "_", model_name, ".json")
    if( !file.exists(path_res) ){
      next
    }
    data <- fromJSON(file = path_res)
    data_ret_ <- tibble(median = data$medians / 1000, 
                        timepoints = data$lengs, 
                        model_name = model_name, 
                        method = method_list[i], 
                        software = software, 
                        method_alt = str_c(software, "_", method))
    data_ret <- bind_rows(data_ret, data_ret_)
  }
  return(data_ret)
}

get_normtime <- function(data, first)
{
  if( first == T ){
    tfilt <- min(data$timepoints)
  }else{
    tfilt <- max(data$timepoints)
  }
  min_val <- data |> 
    filter(timepoints  == tfilt) |> 
    group_by(timepoints) |> 
    summarise(min_time = min(median))    

  data_ret <- data |> 
    filter(timepoints  == tfilt) |> 
    inner_join(min_val, by = c("timepoints"))
  if( first == T ){
    data_ret <- data_ret |> 
      mutate(norm_time = median / min_time) |> 
      mutate(tag = "First")
  }else{
    data_ret <- data_ret |> 
      mutate(norm_time = median / min_time) |> 
      mutate(tag = "End")
  }

  return(data_ret)
}



coluse <- c("PySB_NFsim" = "#fdae6b", "PySB_SortingDirect" = "#a63603", 
            "SBMLImporter_Direct" = "#41b6c4", "SBMLImporter_SortingDirect" = "#1d91c0", 
            "SBMLImporter_RSSA" = "#253494", "SBMLImporter_RSSACR" = "#081d58", 
            "RoadRunner_SSA" = "#525252")
markuse <- c("PySB_NFsim" = 1, "PySB_SortingDirect" = 2, "SBMLImporter_Direct" = 3, 
             "SBMLImporter_SortingDirect" = 4, "SBMLImporter_RSSA" = 5, "SBMLImporter_RSSACR" = 6, 
             "RoadRunner_SSA" = 7) 
dir_save <- "Plots_svg/"
data_tot <- tibble()
if( !dir.exists(dir_save) ) dir.create(dir_save)

# -----------------------------------------------------------------------------------------------
# Multistate
# -----------------------------------------------------------------------------------------------
model_name <- "multistate"
multistate_SBMLImporter <- process_julia_res(model_name, "SBMLImporter")
multistate_PySB <- process_python_res(model_name, "PySB")
multistate_roadrunner <- process_julia_res(model_name, "RoadRunner")
data_plot <- bind_rows(multistate_SBMLImporter, multistate_PySB, multistate_roadrunner)

p1 <- ggplot(data_plot, aes(timepoints, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_y_log10() + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  scale_fill_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Simulation end point [s]", 
       title = "Multisite 3", 
       subtitle = "X reactions") + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

data_tot <- bind_rows(data_tot, data_plot)

# Get average speed ups at end time 
sorted_direct <- multistate_SBMLImporter |> filter(method == "SortingDirect")
sorted_direct_PySB <- multistate_PySB |> filter(method == "SortingDirect")
print(sprintf("RoardRunner tend : %.2f times faster", multistate_roadrunner$median[9] / sorted_direct$median[9]))
print(sprintf("PySB t=10 : %.2f times faster", sorted_direct_PySB$median[1] / sorted_direct$median[1]))
print(sprintf("PySB tend : %.2f times faster", sorted_direct_PySB$median[9] / sorted_direct$median[9]))

ggsave(str_c(dir_save, "Mulistate.svg"), p1, width = BASE_WIDTH, height = BASE_HEIGHT)

# For summary table
data1 <- get_normtime(data_plot, T) 
data2 <- get_normtime(data_plot, F) 
data_multistate_norm <- bind_rows(data1, data2) |> 
  select(model_name, method_alt, norm_time, tag)

# -----------------------------------------------------------------------------------------------
# Multisite3 
# -----------------------------------------------------------------------------------------------
model_name <- "multisite2"
multistate_SBMLImporter <- process_julia_res(model_name, "SBMLImporter")
multistate_PySB <- process_python_res(model_name, "PySB")
multistate_roadrunner <- process_julia_res(model_name, "RoadRunner")
data_plot <- bind_rows(multistate_SBMLImporter, multistate_PySB, multistate_roadrunner)

p1 <- ggplot(data_plot, aes(timepoints, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_y_log10() + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  scale_fill_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Simulation end point [s]", 
       title = "Multisite 3", 
       subtitle = "X reactions") + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

data_tot <- bind_rows(data_tot, data_plot)

# Get average speed ups at end time 
sorted_direct <- multistate_SBMLImporter |> filter(method == "SortingDirect")
sorted_direct_PySB <- multistate_PySB |> filter(method == "SortingDirect")
print(sprintf("RoardRunner tend : %.2f times faster", multistate_roadrunner$median[7] / sorted_direct$median[7]))
print(sprintf("PySB t=10 : %.2f times faster", sorted_direct_PySB$median[1] / sorted_direct$median[1]))
print(sprintf("PySB tend : %.2f times faster", sorted_direct_PySB$median[7] / sorted_direct$median[7]))

ggsave(str_c(dir_save, "Multisite3.svg"), p1, width = BASE_WIDTH, height = BASE_HEIGHT)

# For summary table
data1 <- get_normtime(data_plot, T) 
data2 <- get_normtime(data_plot, F) 
data_multisite_norm <- bind_rows(data1, data2) |> 
  select(model_name, method_alt, norm_time, tag)

# -----------------------------------------------------------------------------------------------
# EGFR_net 
# -----------------------------------------------------------------------------------------------
model_name <- "egfr_net"
multistate_SBMLImporter <- process_julia_res(model_name, "SBMLImporter")
multistate_PySB <- process_python_res(model_name, "PySB")
multistate_roadrunner <- process_julia_res(model_name, "RoadRunner")
data_plot <- bind_rows(multistate_SBMLImporter, multistate_PySB, multistate_roadrunner) 

p3 <- ggplot(data_plot, aes(timepoints, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_y_log10() + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Simulation end point [s]", 
       title = "EGFR net", 
       subtitle = "X reactions") + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

data_tot <- bind_rows(data_tot, data_plot)

# Get average speed ups at end time 
RSSACR_direct <- multistate_SBMLImporter |> filter(method == "RSSACR")
sorted_direct_PySB <- multistate_PySB |> filter(method == "SortingDirect")
24.8 / 3.20
print(sprintf("PySB tend : %.2f times faster", sorted_direct_PySB$median[4] / sorted_direct$median[4]))

ggsave(str_c(dir_save, "egfr_net.svg"), p3, width = BASE_WIDTH, height = BASE_HEIGHT)

# For summary table
data1 <- get_normtime(data_plot, T) 
data2 <- get_normtime(data_plot, F) 
data_egfr_norm <- bind_rows(data1, data2) |> 
  select(model_name, method_alt, norm_time, tag)

# -----------------------------------------------------------------------------------------------
# fceri_gamma2 
# -----------------------------------------------------------------------------------------------
model_name <- "fceri_gamma2"
multistate_SBMLImporter <- process_julia_res(model_name, "SBMLImporter")
multistate_PySB <- process_python_res(model_name, "PySB")
multistate_roadrunner <- process_julia_res(model_name, "RoadRunner")
data_plot <- bind_rows(multistate_SBMLImporter, multistate_PySB, multistate_roadrunner) 

p4 <- ggplot(data_plot, aes(timepoints, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_y_log10() + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Simulation end point [s]", 
       title = "fceri gamma2", 
       subtitle = "X reactions") + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

data_tot <- bind_rows(data_tot, data_plot)

# Get average speed ups at end time 
RSSACR_direct <- multistate_SBMLImporter |> filter(method == "RSSACR")
sorted_direct_PySB <- multistate_PySB |> filter(method == "NFsim")
print(sprintf("PySB tend : %.2f times faster", sorted_direct_PySB$median[4] / sorted_direct$median[7]))

ggsave(str_c(dir_save, "fceri_gamma2.svg"), p4, width = BASE_WIDTH, height = BASE_HEIGHT)

# For summary table
data1 <- get_normtime(data_plot, T) 
data2 <- get_normtime(data_plot, F) 
data_fceri_norm <- bind_rows(data1, data2) |> 
  select(model_name, method_alt, norm_time, tag)

# -----------------------------------------------------------------------------------------------
# BCR model 
# -----------------------------------------------------------------------------------------------
model_name <- "BCR"
multistate_SBMLImporter <- process_julia_res(model_name, "SBMLImporter")
multistate_PySB <- process_python_res(model_name, "PySB")
multistate_roadrunner <- process_julia_res(model_name, "RoadRunner")
data_plot <- bind_rows(multistate_SBMLImporter, multistate_PySB, multistate_roadrunner) 

p5 <- ggplot(data_plot, aes(timepoints, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_y_log10() + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Simulation end point [s]", 
       title = "BCR", 
       subtitle = "X reactions") + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

data_tot <- bind_rows(data_tot, data_plot)

ggsave(str_c(dir_save, "BCR.svg"), p5, width = BASE_WIDTH, height = BASE_HEIGHT)

# For summary table
data1 <- get_normtime(data_plot, T) 
data2 <- get_normtime(data_plot, F) 
data_bcr_norm <- bind_rows(data1, data2) |> 
  select(model_name, method_alt, norm_time, tag)


# -----------------------------------------------------------------------------------------------
# Normalized runtime in heat map
# -----------------------------------------------------------------------------------------------
data_norm <- bind_rows(data_multistate_norm, data_multisite_norm, data_egfr_norm, data_bcr_norm, 
                       data_fceri_norm) |> 
  mutate(time_norm_cap = ifelse(norm_time < 10, norm_time, 10)) |> 
  mutate(tag = factor(tag, levels = c("First", "End"))) |> 
  mutate(model_name = factor(model_name, levels = c("multistate", "multisite2", "egfr_net", "BCR", "fceri_gamma2"))) |> 
  mutate(time_text = sprintf("%.1e", norm_time))

p <- ggplot(data_norm, aes(tag, method_alt, fill = time_norm_cap)) + 
  geom_tile(color = "white") + 
  geom_text(aes(label=time_text), color="grey10", size=7) +
  scale_x_discrete(expand=c(0, 0)) + 
  scale_y_discrete(expand = c(0, 0), limits = rev(c("SBMLImporter_Direct", "SBMLImporter_SortingDirect", 
                                                    "SBMLImporter_RSSA", "SBMLImporter_RSSACR", 
                                                    "RoadRunner_SSA", "PySB_SortingDirect", 
                                                    "PySB_NFsim"))) + 
  facet_wrap(~model_name, ncol=5) + 
  scale_fill_gradient(high = "#bcbddc", low = "#54278f") +
  theme_base(base_size = 15) + 
  theme(panel.background = element_blank(), 
        panel.grid = element_blank())

ggsave(str_c(dir_save, "Time_norm.svg"), p, width = BASE_WIDTH*4.0, height = BASE_HEIGHT*2.0)

# -----------------------------------------------------------------------------------------------
# Multisites models
# -----------------------------------------------------------------------------------------------
res_tot <- tibble()
for(i in 1:6){
  if(i == 2){
    next
  }
  model_name <- str_c("multisite", as.character(i))
  res <- process_julia_res(model_name, "SBMLImporter", multisites=T)
  res_tot <- bind_rows(res_tot, res)
  res <- process_python_res(model_name, "PySB")
  res_tot <- bind_rows(res_tot, res)
  res <- process_julia_res(model_name, "RoadRunner", multisites=T)
  res_tot <- bind_rows(res_tot, res)
}

res_tot <- res_tot |> 
  mutate(nreactions = case_when(model_name == "multisite1" ~ 6,
                                model_name == "multisite3" ~ 288, 
                                model_name == "multisite4" ~ 1536, 
                                model_name == "multisite5" ~ 7680, 
                                model_name == "multisite6" ~ 36864))
data_plot <- res_tot |> 
  filter(timepoints == 1000)

p_multisite <- ggplot(data_plot, aes(nreactions, median, color = method_alt)) + 
  geom_point(aes(shape = method_alt), size=3.0) + 
  geom_line(linewidth=1.5, alpha=0.7) + 
  scale_x_log10() + 
  scale_color_manual(values = coluse) + 
  labs(y = "Median runtime [s]", x = "Number of model reactions", 
       title = "fceri gamma2", 
       subtitle = "X reactions") + 
  scale_y_log10() + 
  scale_shape_manual(values=markuse) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

ggsave(str_c(dir_save, "Multiste_bench.svg"), p_multisite, width = BASE_WIDTH, height = BASE_HEIGHT)

# -----------------------------------------------------------------------------------------------
# End processing ReactionNetworkImporters vs SBMLImporter
# -----------------------------------------------------------------------------------------------
get_comparison_data <- function(model_name, filter_t=NULL)
{
  
  res_SBML <- process_julia_res(model_name, "SBMLImporter")
  res_rni <-  process_julia_res(model_name, "ReactionNetworkImporters")
  data_rni_time <- res_rni |> 
    select(timepoints, method, median) |> 
    rename("median_ref" = "median")
  data_plot <- bind_rows(res_SBML, res_rni) |> 
    inner_join(data_rni_time, by = c("method", "timepoints")) |> 
    filter(software == "SBMLImporter")
  
  if( !is.null(filter_t) ){
    data_plot <- data_plot |> 
      filter(abs(timepoints - filter_t) > 1e-3)
  }
  return(data_plot)
}

data1 <- get_comparison_data("multistate")
data2 <- get_comparison_data("multisite2", filter_t=3162.27766)
data3 <- get_comparison_data("egfr_net")
data4 <- get_comparison_data("fceri_gamma2")
data5 <- get_comparison_data("BCR")

data_plot <- bind_rows(data1, data2, data3, data4, data5) |> 
  mutate(model_name = factor(model_name, 
                             levels = c("multistate", "multisite2", "egfr_net", "BCR", "fceri_gamma2")))
data_sum <- data_plot |> 
  group_by(model_name, method) |> 
  summarise(median_val = median(median / median_ref)) |> 
  mutate(model_name = factor(model_name, 
                             levels = c("multistate", "multisite2", "egfr_net", "BCR", "fceri_gamma2")))

pcomp <- ggplot(filter(data_plot, software== "SBMLImporter"), aes(method)) + 
  geom_jitter(aes(y = median / median_ref), width=0.1)  +
  geom_crossbar(data=data_sum, mapping=aes(ymin=median_val, ymax=median_val, y=median_val, x=method)) + 
  geom_hline(yintercept = 1.0) + 
  facet_wrap(~model_name, scale="free_y", nrow=2, ncol=3) +
  theme_bw(base_size = 14) + 
  theme(legend.position = "bottom", 
        axis.title = element_text(color="grey10"),
        plot.title = element_text(color="grey10", face ="bold", size=12), 
        plot.subtitle = element_text(color="grey30"), 
        panel.grid.minor = element_blank())

ggsave(str_c(dir_save, "RNI_res.svg"), pcomp, width = BASE_WIDTH*3.0, height = BASE_HEIGHT*2.5)
