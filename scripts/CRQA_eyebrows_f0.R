### Summerschool Multiscale Dynamics Tilburg 2026
# @author: Moritz Bammel
# @date: July 16, 2026
#
# This analysis uses CRQA to quantify the coupling between eyebrow movement and
# pitch dynamics on an intrapersonal level, depending on whether or not the
# speaker is standing on a wobble board.
#
# Hypothesis: Under increased postural stability demands (the clue-giver is
# standing on the wobble board), the coupling between eyebrow movement and pitch
# dynamics is distorted. 

# Loading packages and setting working directory
library("crqa")
library("tseriesChaos")
library("tidyr")
path = "/Users/moritzbammel/Documents/MultiscaleSummerschool2026/RaisedExpectations"
setwd(path)

# Loading data
ground = read.csv("example/merged/103_203.csv", header = TRUE) # clue-giver standing on the ground
wobble = read.csv("example/merged/108_208.csv", header = TRUE) # clue-giver standing on the wobble board

# remove NAs and standardize pitch data (eyebrow data are standardized already)
ground = drop_na(ground)
ground$pitch_z = (ground$pitch - mean(ground$pitch)) / sd(ground$pitch)
wobble = drop_na(wobble)
wobble$pitch_z = (wobble$pitch - mean(wobble$pitch)) / sd(wobble$pitch)


### Parameter estimation for phase space reconstruction in CRQA ################

## Delay parameter: We use average mutual information to estimate delay parameter
# Eyebrows ground condition
ami_ground_eyebrows = mutual(ground$eyebrows_interp, partitions = 10, lag.max = 100, plot = TRUE)
delay_ground_eyebrows = 1
while(ami_ground_eyebrows[delay_ground_eyebrows + 1] < ami_ground_eyebrows[delay_ground_eyebrows]) {
  delay_ground_eyebrows = delay_ground_eyebrows + 1
} # first local minimum at d = 64

# Pitch ground condition
ami_ground_pitch = mutual(ground$pitch_z, partitions = 10, lag.max = 100, plot = TRUE)
delay_ground_pitch = 1
while(ami_ground_pitch[delay_ground_pitch + 1] < ami_ground_pitch[delay_ground_pitch]) {
  delay_ground_pitch = delay_ground_pitch + 1
} # first local minimum at d = 50

# Eyebrows wobble board condition
ami_wobble_eyebrows = mutual(wobble$eyebrows_interp, partitions = 10, lag.max = 100, plot = TRUE)
delay_wobble_eyebrows = 1
while(ami_wobble_eyebrows[delay_wobble_eyebrows + 1] < ami_wobble_eyebrows[delay_wobble_eyebrows]) {
  delay_wobble_eyebrows = delay_wobble_eyebrows + 1
} # first local minimum at d = 60

# Pitch wobble board condition
ami_wobble_pitch = mutual(wobble$pitch_z, partitions = 10, lag.max = 100, plot = TRUE)
delay_wobble_pitch = 1
while(ami_wobble_pitch[delay_wobble_pitch + 1] < ami_wobble_pitch[delay_wobble_pitch]) {
  delay_wobble_pitch = delay_wobble_pitch + 1
} # first local minimum at d = 49

# choosing the same delay parameter for all four time series
delay = round(mean(c(delay_ground_eyebrows, delay_ground_pitch, delay_wobble_eyebrows,
                     delay_wobble_pitch)), digits = 0)


## Embedding dimension
# Eyebrows ground condition
fnn_ground_eyebrows = false.nearest(ground$eyebrows_interp, m = 20, d = delay, t = 0)
plot(fnn_ground_eyebrows[1, ], type = "o", xlab = "Embedding Dimension" ,
     ylab = "FNN (relative)", main = "Eyebrows, ground condition")
embed_ground_eyebrows = 1
while(fnn_ground_eyebrows[1, embed_ground_eyebrows + 1] < fnn_ground_eyebrows[1, embed_ground_eyebrows]) {
  embed_ground_eyebrows = embed_ground_eyebrows + 1
} # first local minimum at m = 10

# Pitch ground condition
fnn_ground_pitch = false.nearest(ground$pitch_z, m = 20, d = delay, t = 0)
plot(fnn_ground_pitch[1, ], type = "o", xlab = "Embedding Dimension" ,
     ylab = "FNN (relative)", main = "Pitch, ground condition")
embed_ground_pitch = 1
while(fnn_ground_pitch[1, embed_ground_pitch + 1] < fnn_ground_pitch[1, embed_ground_pitch]) {
  embed_ground_pitch = embed_ground_pitch + 1
} # first local minimum at m = 7

# Eyebrows wobble board condition
fnn_wobble_eyebrows = false.nearest(wobble$eyebrows_interp, m = 20, d = delay, t = 0)
plot(fnn_wobble_eyebrows[1, ], type = "o", xlab = "Embedding Dimension" ,
     ylab = "FNN (relative)", main = "Eyebrows, wobble board condition")
embed_wobble_eyebrows = 1
while(fnn_wobble_eyebrows[1, embed_wobble_eyebrows + 1] < fnn_wobble_eyebrows[1, embed_wobble_eyebrows]) {
  embed_wobble_eyebrows = embed_wobble_eyebrows + 1
} # first local minimum at m = 7

# Pitch wobble board condition
fnn_wobble_pitch = false.nearest(wobble$pitch_z, m = 20, d = delay, t = 0)
plot(fnn_ground_pitch[1, ], type = "o", xlab = "Embedding Dimension" ,
     ylab = "FNN (relative)", main = "Pitch, wobble board condition")
embed_wobble_pitch = 1
while(fnn_wobble_pitch[1, embed_wobble_pitch + 1] < fnn_wobble_pitch[1, embed_wobble_pitch]) {
  embed_wobble_pitch = embed_wobble_pitch + 1
} # first local minimum at m = 9

# choosing the same embedding parameter for all four time series
embedding = round(mean(c(embed_ground_eyebrows, embed_ground_pitch, embed_wobble_eyebrows,
                         embed_wobble_pitch)), digits = 0)

# selecting initial radius parameter; needs to be updated iteratively to achieve mean RR between 5 - 10 %
radius = 2

### Running CRQA
crqa_ground = crqa(ts1 = ground$pitch_z, ts2 = ground$eyebrows_interp,
                   delay = delay, embed = embedding, radius = radius, rescale = 0,
                   normalize = 0, tw = 0, side = "both", method = "crqa",
                   metric = "euclidean", datatype = "continuous")
plot_rp(crqa_ground$RP, title = "Clue-giver standing on the ground",
        xlabel = "Time indices pitch (ms)", ylabel = "Time indices eyebrows (ms)")


crqa_wobble = crqa(ts1 = wobble$eyebrows_interp, ts2 = wobble$pitch_z,
                   delay = delay, embed = embedding, radius = radius, rescale = 0,
                   normalize = 0, tw = 0, side = "both", method = "crqa",
                   metric = "euclidean", datatype = "continuous")
plot_rp(crqa_wobble$RP, title = "Clue-giver standing on the wobble board",
        xlabel = "Time indices pitch (ms)", ylabel = "Time indices eyebrows (ms)")

results = data.frame(condition = c("ground", "wobble_board"),
                     RR = c(crqa_ground$RR, crqa_wobble$RR),
                     DET = c(crqa_ground$DET, crqa_wobble$DET),
                     L = c(crqa_ground$L, crqa_wobble$L),
                     rENTR = c(crqa_ground$rENTR, crqa_wobble$rENTR),
                     LAM = c(crqa_ground$LAM, crqa_wobble$LAM),
                     TT = c(crqa_ground$TT, crqa_wobble$TT))

# saving results
write.csv(results, "docs/CRQA_pitch_eyebrows.csv", row.names = FALSE)


### Diagonal cross-recurrence profiles

dcrp_ground = drpfromts(ts1 = ground$pitch_z, ts2 = ground$eyebrows_interp, windowsize = 300 ,
                       delay = delay, embed = embedding, radius = radius, rescale = 0,
                       normalize = 0, tw = 0, side = "both", method = "crqa",
                       metric = "euclidean", datatype = "continuous")
plot(seq((length(dcrp_ground$profile)-1)*-0.5,(length(dcrp_ground$profile)-1)*0.5,1),
     dcrp_ground$profile, type = "l", lwd = 2, xlab = "Time Lag (ms)",
     ylab = "Cross-Recurrence Eyebrows-Pitch",
     main = "Clue-giver standing on the ground", ylim = c(0, 0.23))


dcrp_wobble = drpfromts(ts1 = wobble$pitch_z, ts2 = wobble$eyebrows_interp, windowsize = 300 ,
                       delay = delay, embed = embedding, radius = radius, rescale = 0,
                       normalize = 0, tw = 0, side = "both", method = "crqa",
                       metric = "euclidean", datatype = "continuous")
plot(seq((length(dcrp_wobble$profile)-1)*-0.5,(length(dcrp_wobble$profile)-1)*0.5,1),
     dcrp_wobble$profile, type = "l", lwd = 2, xlab = "Time Lag (ms)",
     ylab = "Cross-Recurrence Eyebrows-Pitch",
     main = "Clue-giver standing on the wobble board", ylim = c(0, 0.23))
