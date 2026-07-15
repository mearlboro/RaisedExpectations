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


## Setup

Python packages are listed in `requirements.txt`, install with preferred tool.

### Eyebrows data analysis

See `notebooks/eyebrows.ipynb` for how we subtract the position of the nose to obtain relative
movement of the eyebrows (these are saved in CSV files with the extension `_std.csv`).

On these 'standardised' files we can apply mutual information and obtain comparable values.

### Computing mutual information

Mutual information is computed with `infodynamics.jar`, you need Java 8 Headless SDK to reproduce
computations. Can use the `mishell.nix` Nix shell for a reproducible environment for Java + Python.
This is Python 3.9 and Java 8, both quite old, but they do the job. The precomputed time series
are also in `data/mutualinfo`. [Install Nix](https://nixos.org/download/) then run

```
nix-shell mishell.nix

python -m scripts.mutualinfo
```
Currently jupyter does not work in this shell so everything is computed as a script.

Joseph T. Lizier, "JIDT: An information-theoretic toolkit for studying the dynamics of complex
systems", *Frontiers in Robotics and AI* 1:11, 2014; doi:[10.3389/frobt.2014.00011](http://dx.doi.org/10.3389/frobt.2014.00011) (pre-print: [arXiv:1408.3270](http://arxiv.org/abs/1408.3270))
