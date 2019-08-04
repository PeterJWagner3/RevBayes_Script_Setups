# These code used here rely on functions in the following packages.
#	If you do not have them installed on your computer, simply highlight the "install.packages("I_need_this",dependencies=T)
#	and hit return; this should install the package on your computer.
library(combinat);		#install.packages("combinat", dependencies=TRUE);
library(dplyr);			  #install.packages("dplyr", dependencies=TRUE);
library(gdata);			  #install.packages("gdata", dependencies=TRUE);
library(gtools)			  #install.packages("gtools", dependencies=TRUE);
library(lettercase);	#install.packages("lettercase", dependencies=TRUE);
library(paleobioDB);	#install.packages("paleobioDB", dependencies=TRUE);
library(prodlim);		  #install.packages("prodlim", dependencies=TRUE);
library(rvest);			  #install.packages("rvest", dependencies=TRUE);
library(sads);			  #install.packages("sads", dependencies=TRUE);
library(stringr);		  #install.packages("stringr", dependencies=TRUE);
library(subplex);		  #install.packages("subplex", dependencies=TRUE);

# CHANGE DIRECTORIES TO WHERE YOU KEEP COMMON SOURCE FILES!!!!
common_source_folder <- "~/Documents/R_Projects/Common_R_Source_Files/";	# directory to folder where you keep common source
data_for_R_folder <- "~/Documents/R_Projects/Data_for_R/";					# directory to folder where you keep R-Data files
local_directory <- "~/Documents/R_Projects/Rev_Bayes_Setup/";				# this is the directory from which you are running this R-program

# load the source code needed for the analyses
source(paste(common_source_folder,"RevBayes_Setup.r",sep=""));

# these are the external databases that the program uses to fine-tune PaleoDB data
load(paste(data_for_R_folder,"Rock_Unit_Database.RData",sep=""));  		# data for rock-units including biozanation & superposition
load(paste(data_for_R_folder,"Gradstein_2012_Augmented.RData",sep="")); # refined Gradstein 2012 timescale & biozonations
load(paste(data_for_R_folder,"PaleoDB_Edits.RData",sep=""));			# edits to collections I cannot edit. # refined Gradstein 2012 timescale & biozonations

analysis_name <- "Cincta"						# This will be used to label files
use_rock_database <- T;							# if T, then an external database with information about rock units is required
taxon_level <- "species";						# taxonomic level at which analysis is conducted.
lump_subgenera <- F;							  # if this is a genus level analysis, then T will lump Loxoplocus (Lophospira) into Loxoplocus. (Don't do that....)
species_only <- T;								  # if TRUE, then only specimens identified to the species level will be used REGARDLESS of the taxon-level of the study
control_taxon <- "Echinodermata";		# control group for getting basic sampling and diversification parameters to seed FBD analyses
onset <- "Atdabanian";							# oldest control taxa to consider: make them a bit older than your oldest ingroup taxa
end <- "Furongian";								  # youngest taxa to consider: make them a bit younger than your youngest ingroup taxa
end_FBD <- ""									      # youngest taxa to consider in FBD model
exclude_uncertain_taxa <- T					# exclude "?", "aff.", "cf.", etc. taxa
basic_environments <- c("marine","unknown");	# use "terr" for terrestrial; "marine" and "unknown" are other options
zone_taxa <- c("Trilobita");				# we will get occurrences from these groups for added stratigraphic exactness
sampling_unit <- "collection";			# "collection" for sampling by locality; "rock" for sampling by rock-unit
time_scale_stratigraphic_scale <- "Stage Slice";	# Use "International" or "Stage Slice"
temporal_precision <- 0.05					# the finest unit of time you wish to consider; time scale will be rounded accordingly
bogarted <- T;									    # occurrences not in the PaleoDB. Include directory here if it is not in the current one.
taxon_subset_file <- F;							# list of taxa to analyze within the entire matrix; leave blank if all to be analyzed
rate_partition <- "";							  # name of character partition set that separate out character groups to get different rates.
trend_partition <- "";							# name of character partition set that separate out characters suspected of showing driven trends (i.e., biased change).

write_data_directory <- "~/Documents/RevBayes_Projects/data/";			  # The output RevBayes scripts will direct rearranged data to this folde
write_scripts_directory <- "~/Documents/RevBayes_Projects/scripts/";	# Insert directory with RevBayes scripts here!
set_wdir <- "/Users/peterjwagner/Documents/RevBayes_Projects/";			  # The working directory for RevBayes analyses.

# load up the relevant databases!
rock_unit_databases <- rock_unit_data;						        # information about rock ages, biozonations and sequence stratigraphy
chronostratigraphic_databases <- gradstein_2012_emended;	# information about time scales, zone ages, etc.
paleodb_fixes <- paleodb_fixes;								            # edits to PaleoDB data that cannot be entered currrently

# now begins the magic.....
scribio_RevBayes_scripts_from_nexus_file_and_PaleoDB_download(analysis_name,taxon_subset_file,rate_partition,trend_partition,taxon_level,lump_subgenera,species_only,bogarted,rock_unit_databases,chronostratigraphic_databases,paleodb_fixes,control_taxon,zone_taxa,onset,end,end_FBD,exclude_uncertain_taxa,basic_environments,sampling_unit,time_scale_stratigraphic_scale,temporal_precision,write_data_directory,write_scripts_directory,local_directory,set_wdir);
strat_data_file <- "~/Documents/R_Projects/Rev_Bayes_Setup/Cincta_Collection_Finds_per_Bin.csv";
revelio_possible_driven_trends(analysis_name,nexus_file_name,time_scale,strat_data_file);

# now, let's write scripts for partitioned analyses.
fbd_parameterization_script <- "Accio_Cincta_Range_Based_FBD_Parameterization.Rev";
fossil_interval_file <- "cincta_fossil_intervals_FA.tsv";
rate_partition <- "Functional_Partitions";					# name of character partition set that separate out character groups to get different rates.
scribio_RevBayes_scripts_from_nexus_file_and_existing_FBD_script_and_data(analysis_name,fbd_parameterization_script,fossil_interval_file,taxon_subset_file,rate_partition,trend_partition,write_data_directory,write_scripts_directory,local_directory,set_wdir);
