## ----global_options, eval = TRUE, include=TRUE---------------------------
name = "NoRogue"


## ---- include=TRUE, eval = TRUE------------------------------------------
    morpho_f <- readDiscreteCharacterData("data/f_namesNoRogue")
    morpho_nf <- readDiscreteCharacterData("data/nf_block_namesNoRogue")
    moves = VectorMoves()
    monitors = VectorMonitors()

## ---- include=TRUE, eval = TRUE------------------------------------------
    taxa <- morpho_f.names()
    num_taxa <- morpho_f.size()
    num_branches <- 2 * num_taxa - 2

    source("scripts/Uncorr_FBD.R")

    alpha_morpho ~ dnUniform( 0, 1E6 )
    rates_morpho := fnDiscretizeGamma( alpha_morpho, alpha_morpho, 4 )
    #Moves on the parameters to the Gamma distribution.
    moves.append(mvScale(alpha_morpho, lambda=1, weight=2.0))

## ---- include=TRUE, eval = TRUE------------------------------------------
n_max_states <- 3
idx = 1
morpho_f_bystate <- morpho_f.setNumStatesVector()
for (i in 1:n_max_states) {
    nc = morpho_f_bystate[i].nchar()
    # for non-empty character blocks
    if (nc > 0) {
        # make i-by-i rate matrix
        q[idx] <- fnJC(i)
# create model of evolution for the character block
        m_morph[idx] ~ dnPhyloCTMC( tree=fbd_tree,
                                    Q=q[idx],
                                    nSites=nc,
                                    siteRates=rates_morpho,
                                    branchRates=ucln_geomean,
                                    type="Standard")

        # attach the data
	    m_morph[idx].clamp(morpho_f_bystate[i])

        # increment counter
        idx = idx + 1
idx
}
}

n_max_states <- 4
morpho_nf_bystate <- morpho_nf.setNumStatesVector()
for (i in 1:n_max_states) {
    nc = morpho_nf_bystate[i].nchar()
    # for non-empty character blocks
    if (nc > 0) {
        # make i-by-i rate matrix
        q[idx] <- fnJC(i)
# create model of evolution for the character block
        m_morph[idx] ~ dnPhyloCTMC( tree=fbd_tree,
                                    Q=q[idx],
                                    nSites=nc,
                                    siteRates=rates_morpho,
                                    branchRates=ucln_geomean,
                                    type="Standard")

        # attach the data
	    m_morph[idx].clamp(morpho_nf_bystate[i])

        # increment counter
        idx = idx + 1
idx
}
}




## ---- include=TRUE, eval = TRUE------------------------------------------
    mymodel = model(fbd_tree)


## ---- include=TRUE, eval = TRUE------------------------------------------
    monitors.append(mnModel(filename="output/" + name + ".log", printgen=10))


## ---- include=TRUE, eval = TRUE------------------------------------------
    monitors.append(mnFile(filename="output/" + name + ".trees", printgen=10, fbd_tree))


## ---- include=TRUE, eval = TRUE------------------------------------------
    monitors.append(mnScreen(printgen=100))


## ---- include=TRUE, eval = TRUE------------------------------------------
#   mymcmc = mcmc(mymodel, monitors, moves, nruns=2, combine="mixed")
#    mymcmc.run(generations=100000, tuningInterval=200)

ss_analysis = powerPosterior(mymodel, monitors, moves, "output/" + name + "/ss", cats=20, alpha=0.3)
ss_analysis.burnin(generations=10000,tuningInterval=200)
ss_analysis.run(generations=500000)

ss = steppingStoneSampler("output/" + name + "/ss", "power", "likelihood", TAB)
ss.marginal()
### ---- include=TRUE, eval = TRUE------------------------------------------


## ---- include=TRUE, eval = TRUE------------------------------------------
#    q()


## ------------------------------------------------------------------------
