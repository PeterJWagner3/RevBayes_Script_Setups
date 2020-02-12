# RevBayes_Script_Setups
R Programs for generating RevBayes scripts &amp; appropriate data files

RevBayes_Setup.r will generate RevBayes scripts and appropriate data files that partition characters by numbers of states and general character evolution models.  However, the generated RevBayes scripts will require some editing and/or verification before they can be used on your computer.  There are two sources of editing that you will need to do.  The first concerns the directories invoked by the scripts.  Open the file “Cincta_FBD_Analysis_Strict_Clock.Rev.”  The first line:
	clear();
This simply clears all information from the RevBayes program.  The second line includes the command:
	Setwd("/Users/user_name/Documents/RevBayes_Projects/");
“user_name” in your file should not be user_name, but instead be the name of your user folder on your computer.  This should have been entered in the Cincta.setup.R in the variable set_wdir.  If not, then change it to your user folder name now.

RevBayes_Projects should contain three folders:
	1) RevBayes_Projects/scripts
	2) RevBayes_Projects/data
	3) RevBayes_Projects/output
“Cincta_FBD_Analysis_Strict_Clock.Rev” will look in the first folder for source files that are additional RevBayes scripts for performing MCMC analyses.  It will look in the 2nd folder for the relevant data files.  It will send output to the third folder.

“Cincta_FBD_Analysis_Strict_Clock.Rev” will call on three types of RevBayes source files.  The type is denoted by the first word of the files, which are named after appropriate Harry Potter spells:
	Imperio_Source_Name.Rev: these scripts instruct RevBayes how to “think” about the data while conducting analyses.
	Accio_Source_Name.Rev: these scripts fetch (summon) data such as taxonomic data with stratigraphic ages and the different partitions of the character data.
	Expecto_Source_Name.Rev: these execute the analyses and thus (hopefully!) summon plausible possible histories of your organism.

The first of these source files that is executed  is “Imperio_Default_Settings.Rev.”  As the name indicates, this provides default values for variables that provide a simple strict clock analysis.  (Scripts for more complex models will require changing one or more of these variables in the script.)  In particular, this sets the clock model (clock_model) to “strict”, the number of rate partitions to 1.

The next set of commands inform RevBayes about the character data.  The first one,
	filenames <- v(…),
informs the analysis there are three nexus files, which were created by the RevBayes_Setup.r program.  The subsequent commands:
	partition_states <- v(2,3,4);
	partition_ordering <- v("unordered","unordered","unordered");
will tell RevBayes the number of states shared by characters in each partition and that there is no “ordering” to the characters.  This information will be used below to establish simple Mk (M2, M3 and M4) models logically equivalent to the Jukes-Cantor model.

The next variable informs RevBayes about ascertainment bias within each matrix.  Here, Smith & Zamora included some characters that are invariant among all of the cinctans.  These are treated as invariant binary characters, so:
	coding_bias[1] = “all”;
If this is changed to either “variable” or “informative”, then the MCMC analyses will ignore the invariant characters.  If there were no invariant binary characters but some autapomorphic binaries (i.e., binary characters with one state shown by only one analyzed taxon), then coding_bias[1] would equal “variable.”  If there are no invariant or autapomorphic characters, then coding_bias[1] would be “informative.”  For either “variable” or “informative” characters, the likelihood component of the MCMC analyses will perform a correction akin to Chao2 inferences of unsampled species to infer some number of “unsampled” characters that could have varied among the observed species, but that simply have not changed among the sampled taxa.

On the other hand, coding_bias[2] and coding_bias[3], are set to “variable.”  This is because 3-state, 4-state, etc., characters logically demand the possibility of autapomorphic character states.  That is, if 10 species have “circular” and 10 species have “squared” to describe the shape of some feature, then a species with a triangular shape demands its own state.  So, if we observe 3+ states, we know that we have to code unique features in order to retain an informative character.  (In contrast, autapomorphic binary characters are not informative in traditional phylogenetic analyses and thus might be deliberately excluded by authors.)

The final variable here is:
	max_age <- 7.3;
This is not important only for more complex models considering early-bursts in character change rates.  However, it is included in the generic script simply because RevBayes_Setup.R can provide the information and thus save the user from looking it up separately.  

The next set of variables also are read from the original nexus file.  This sets the outgroup taxon to the genus Ctenocystis.  The ingroup is set to the rest of the clade.  Because four cinctan species were excluded from Smith & Zamora’s original analysis, these are set aside as “unscored_taxa”.  (This will affect the tree priors but not the tree likelihoods.)

The final variable here has to be set by the user.  RevBayes_Setup.r will return:
among_char_var <- "ENTER_THE_AMONG-CHARACTER_RATE_DISTRIBUTION_YOU_WISH_TO_USE_HERE";	# enter "gamma" or "lognormal"

This should be set to either:
	among_char_var <- "lognormal"
or
	among_char_var <- "gamma"
The scripts below will use this to establish models of rate variation among characters.

The next part of Cincta_FBD_Analysis_Strict_Clock.Rev collects basic information about the data set.  The first variable,
	n_data_subsets <- filenames.size();
will be used to tell subsequent scripts how many character data files must be examined.  The next command:
	taxa <- readTaxonData(file="data/cincta_fossil_intervals_FA.tsv");
reads in data about the taxa that will be used in the fossilized birth-death (FBD) analyses.  This file was generated by RevBayes_Setup.R and must be in the folder RevBayes_Projects/data (or whatever the equivalent of that fold is on your computer.). Note that this file uses the first appearances for both the min and max ages; the current versions of RevBayes appear to be using the file incorrectly so that the minimum age (last appearance) is a possible divergence time, so that trees with species diverging after they first appear are possible!  

The variable “taxa.size” provides the number of taxa (n_taxa); this is used in scripts below, and also to establish the maximum number of possible branches (n_branches).

At this point, the script begins to prepare the actual analyses.  The command:
	moves = VectorMoves();
sets up a vector of parameter-alterations that RevBayes will consider in each generation of the MCMC searches.  The next two steps will setup the tree & fossilized birth-death (FBD) models, and then the character evolution models.  

The program first sets up trees & FBD model for tree-priors using “Accio_Cincta_Range_Based_FBD_Parameterization.Rev.”  This file was created from PaleoDB data by RevBayes_Setup.r.  The first variables that are set are:
	speciation_rate ~ dnExponential(1.471);
	extinction_rate ~ dnExponential(1.471);
This sets both speciation (really, cladogenesis) and extinction rates to be sampled from exponential distributions in which the original rate (1.471) represents an estimate of the average per-million-year origination and extinction rates for Cambrian echinoderms given PaleoDB data.  Three moves are set up for both rates, with lambda affecting how “big” of a move is expected and “weight” determining how many times the move will be made in an MCMC generation.  Here, several small moves will be used for every large move.  These moves mean that the final estimates of average origination & extinction could be very different from what we would estimate using paleobiological methods.  On the other hand, using numbers that should be fairly realistic might speed up the runs needed to achieve convergence in the MCMC analyses.

(NOTE: I have occassionally run into origination & extinction seed values that seem to “freeze” RevBayes; I have found that just changing the numbers very slightly usually sets things right.)

Finally, note that two deterministic variables are established: diversification and turnover.  The “:=” assignment means that these will be automatically updated every time either speciation or extinction changes.  These are not used, but are included in the output just in case the user is interested.

The next set of commands defines the sampling parameter, psi.
	psi ~ dnExponential(3.892);
Note that as the number in the exponential increases, the log-decay of the exponential distribution increases and the expected number of samples decreases.  Here, the original number represents a weighted average of median sampling rates given best fit uniform, exponential, Beta and lognormal distributions (with the weight proportional to the likelihood of the best fit distributions given occurrences in different stage-slices in the Cambrian.)  Here, the sampling is based on numbers of collections in which we find Cambrian echinoderm species in each stage slice given the total number of collections in those stage slices.  (Another alternative would have been to use numbers of rock units, e.g., formations & members.)  We again assign moves to the MCMC analysis just as we did for origination & extinction; as before, although we seed the analysis with an empirical estimate, other values will be preferred if they increase the posterior probabilities of trees.  

An additional deterministic variable is established here, completeness.  This reflects the average sampling and extinction rates; as with diversification & turnover, this variable is automatically updated every time sampling or extinction changes.  It is not used in the analyses but reported in case users are interested.

A final sampling parameter is included, rho.  This is the probability of sampling individual taxa in the final interval of the study.  This might seem to be odd for paleontologists, but it is necessary for analyses of fossil & extant taxa in which extant taxa typically have much higher rates of sampling than the fossil taxa.  Here, rho is estimated from the best fit sampling distribution for the latest interval in which an analyzed cinctan species appears.  This is also why the ages of the taxa in cinctan_intervals_FA.tsv are scaled so that 0 represents when that youngest known species appears: RevBayes will apply rho only for age 0.  Here, PaleoDB data suggest rho=0.506.

Finally, we use:
	origin_time ~ dnUnif(7.3, 12.11);
to put limits on plausible origination times for the entire clade.  The upper bound, 7.3 represents the earliest possible appearance time of the oldest known species.  (This represents 7.3 million years before the first appearance of the youngest species.)  The lower bound, 12.11, is based on Bapst’s cal-3 calculation given the average origination, extinction & sampling rates, with 12.11 being the time where the log-probability of divergence is 8 less than the most-probable divergence time.  We establish three move commands to adjust this in each MCMC generation, with smaller adjustments being more common than large adjustments.  

At this point, we begin setting up the actual tree.  The variable
	fbd_dist = dnFBDRP(origin=origin_time, lambda=speciation_rate, mu=extinction_rate, psi=psi, rho=rho, taxa=taxa);
takes all of the information about diversification & sampling to generate a distribution of phylogenies.  This then is used to generate a tree, tau:
	tau ~ dnConstrainedTopology(fbd_dist,constraints=constraints);
in which constraints is defined in the prior line as the ingroup.  

At this point, we add a series of adjustments to the phylogeny that will be considered in each MCMC generation.  Here, the weights reflect the number of taxa: the more taxa we have, the more adjustments to phylogeny we should consider to explore comparable proportions of tree space.  Two of these moves (mvFNPR and mvNNI) adjust the cladistic topology of the tree with nearest-neighbor exchanges, pruning & grafting, etc.  (Note that other tree-changing moves can be used only if they work for time-trees.)  The other moves alter branch durations (called “branch lengths” but not the same as the expected amount of change along each branch), including collapsing some branches into sampled ancestors.  

The script establishes several deterministic variables after this. num_samp_anc gives the number of observed taxa treated as ancestors.  Note that divergence_dates and origin_dates are different.  divergence_dates for observed taxa is the first-appearance date; for hypothesized ancestors, it is the date at which it diverged into 2+ daughter lineages.  For sampled taxa, divergence_dates gives the first-appearance date and origin_dates gives the time when the lineage leading directly to a sampled species diverged from its closest relatives.  For unsampled ancestors, divergence_dates gives the time that the ancestor diverged into 2+ daughter taxa and origin_dates gives the time that it diverged from the rest of the clade.  In both cases, branch_lengths gives the duration between origin_dates & divergence_dates.  Finally, summed_gaps gives the total amount of “unsampled time” over which character change might have occurred.  All of these are included in the output.  

The final important variable assignment here is pruned_tau; this separates out four species for which we have no character coding.  


#Results

| Model | Score | K |
|-------|-------|---|
| Mk + Gamma | -503.524 | NA |
| Mk + partitioned feeding + gamma | -467.0526 | 1.078 |
| Time homogeneous FBD, unpartitioned, strict | -748.5214 |
| Time homogeneous FBD, partitioned, strict | -582.874 |
| Time homogeneous, relaxed clock uncorrelated | -550.3108 |  
| Time homogeneous, relaxed clock, autocorrelated PW | -680.7967 |
| Early burst, relaxed clock PW |-671.7186 |
