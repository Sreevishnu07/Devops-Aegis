# Sentinel masterless Puppet entry point.
# Hiera supplies node-specific parameters based on the sentinel_role external fact.
include sentinel_baseline
