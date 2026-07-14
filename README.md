## Raised expectation

Exploring the relationships between eyebrow movement, pitch and effects on
communication and accuracy in the guessing game of the [BALANCE dataset](https://thebalancecorpus.warwick.ac.uk/).

The clue-giver gives clues about English words with words or gestures. The
clue-giver can be on a balance board or on the ground. The guesser is always
on the ground. The two can talk to each-other until the word is guessed in up
to 3 attempts.

Hypotheses:

- raised eyebrows associate with higher pitch in both speakers
- eyebrow movement in the clue-giver is reduced when on board because of cognitive load
- higher synchrony / mutual information in eyebrow movement between two participants
  predicts higher accuracy in guessing


Data (from original dataset):

- `data/audio`: raw audio of speakers (2 channel, both together in the same file)
- `data/eyebrows`: OpenFace eyebrow and tip of nose position time series

Data (to be produced by analysis):

- f0 pitch for each speaker
- mean, variability and entropy of eyebrow motions for each person (total and windowed)
- mutlivariate mutual information between eyebrow positions of the clue-giver and guesser (total and
  windowed)
- RQA

TODO (decide data to include or future steps):

- board gyroscope for the extent of balance board sway to compare with eyebrow movement?
- diarization to know when they speak at once (to exclude from pitch extraction data)
- familiarity between subjects - does it improve or reduce accuracy? does it affect facial
  expression variability or synchrony?
