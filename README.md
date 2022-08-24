# Kuadrant Labels

Use Kuadrant-style labels on your GitHub issues.

## Requirements

- Ruby (tested with Ruby 2.7.6)
- [GitHub personal access token](https://github.com/settings/tokens), in the target repo where you want to create the labels, with the `repo` scope

## Install

Clone the repo and install required Ruby gems:

```sh
git clone git@github.com:guicassolato/kuadrant-labels.git && cd kuadrant-labels
bundle
```

Store the GitHub personal access token safely in a .env file in your file system:

```sh
echo "GITHUB_TOKEN=<my secret github token>" > .env
```

## Usage

Edit the `renames` file if needed.

Then:

```sh
ruby run.rb \
  --target-org=my-org
  --target-repo=my-repo
```

## Full list of options

| Option                      | Description                                             |
|-----------------------------|---------------------------------------------------------|
| `--source-org VALUE`        | Source GitHub organization (default: 'kuadrant')        |
| `--source-repo VALUE`       | Source GitHub repo (default: 'limitador')               |
| `--target-org VALUE`        | Target GitHub organization (default: 'kuadrant')        |
| `--target-repo VALUE`       | Target GitHub repo                                      |
| `--renames-file-path VALUE` | Path to the key/value renames file (default: 'renames') |
| `--dotenv-file-path VALUE`  | Path to the .env file (default: '.env')                 |
| `--dry-run`                 | Dry run (default: 'false')                              |
| `--help`                    | Displays the instructions to use the script             |
