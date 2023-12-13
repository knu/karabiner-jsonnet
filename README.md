# Configuring Karabiner-Elements in Jsonnet

This is a template for managing your [Karabiner-Elements](https://karabiner-elements.pqrs.org/) configuration in [Jsonnet](https://jsonnet.org/).

## Getting Started

1. Install the jsonnet command via `brew install jsonnet`.

2. Clone this repository and paste and merge your `karabiner.json` into `karabiner.jsonnet`.
   Note that any pure JSON value is valid as a Jsonnet expression.

3. Run `make` to generate the `karabiner.json` file and compare the diff with your `karabiner.json`.

4. Fix `karabiner.jsonnet` until the output matches your `karabiner.json`.

5. Profit from the power of Jsonnet!

## License

Copyright (c) 2022-2023 Akinori Musha.

Licensed under the 2-clause BSD license.  See `LICENSE.txt` for details.

Visit [GitHub Repository](https://github.com/knu/karabiner-jsonnet) for the latest information.
