"""Evaluate paired probability columns with the original weighted metric functions."""

import argparse
import itertools
from pathlib import Path

import numpy as np
import pandas as pd

from frozen_metrics import interval, weighted_metrics


def calculate(rows, model_columns, draws, seed):
    outcome = rows["outcome"].to_numpy(int)
    groups = sorted(rows["cluster"].unique())
    code = {value: index for index, value in enumerate(groups)}
    columns = [code[value] for value in rows["cluster"]]
    rng = np.random.Generator(np.random.PCG64(seed))
    samples = rng.integers(0, len(groups), size=(draws, len(groups)))
    counts = np.zeros_like(samples, dtype=np.int32)
    np.add.at(counts, (np.repeat(np.arange(draws), len(groups)), samples.ravel()), 1)
    weights = np.vstack([np.ones(len(rows)), counts[:, columns]])
    predictions = {c: weighted_metrics(outcome, rows[c].to_numpy(float), weights) for c in model_columns}
    result = []
    for metric in ("AUROC", "AP", "Brier", "CITL", "Slope"):
        for left in model_columns:
            values = predictions[left][metric]
            result.append({"metric": metric, "left": left, "right": "", "estimate": values[0],
                           **interval(values[1:])})
        for left, right in itertools.combinations(model_columns, 2):
            values = predictions[left][metric] - predictions[right][metric]
            result.append({"metric": metric, "left": left, "right": right, "estimate": values[0],
                           **interval(values[1:])})
    return pd.DataFrame(result).assign(records=len(rows), clusters=len(groups),
                                       events=int(outcome.sum()), requested_draws=draws)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--models", nargs="+", required=True)
    parser.add_argument("--draws", type=int, default=5000)
    parser.add_argument("--seed", type=int, required=True)
    parser.add_argument("--first-index", action="store_true",
                        help="Select the supplied outcome-independent first_eligible membership flags")
    args = parser.parse_args()
    rows = pd.read_csv(args.input, dtype={"record": "string", "cluster": "string"})
    required = {"record", "cluster", "outcome", *args.models}
    if args.first_index:
        required.add("first_eligible")
    if not required.issubset(rows.columns) or len(args.models) != len(set(args.models)):
        parser.error("Required columns are record, cluster, outcome, each named model, and first_eligible if selected.")
    if (rows["record"].duplicated().any() or rows[["record", "cluster", "outcome"]].isna().any().any()
            or set(rows["outcome"]) != {0, 1}
            or not rows[args.models].apply(lambda c: c.between(0, 1).all()).all() or args.draws < 1):
        parser.error("Use one row per unique record, cluster labels, 0/1 outcomes, finite probabilities, and positive draw count.")
    if args.first_index:
        if not rows["first_eligible"].isin([0, 1]).all() or not (rows.groupby("cluster")["first_eligible"].sum() == 1).all():
            parser.error("Supply exactly one verified earliest eligible record per cluster.")
        rows = rows.loc[rows["first_eligible"] == 1]
        if set(rows["outcome"]) != {0, 1}:
            parser.error("The first-eligible subset must contain both outcomes.")
    calculate(rows, args.models, args.draws, args.seed).to_csv(args.output, index=False)


if __name__ == "__main__":
    main()
