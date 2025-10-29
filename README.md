[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors)
![StandardRB](https://github.com/andrewmcodes/dishwasher/workflows/StandardRB/badge.svg)
![Tests](https://github.com/andrewmcodes/dishwasher/workflows/Tests/badge.svg)

# Dishwasher

A CLI tool written in Ruby to help you remove unneeded GitHub forks.

## Features

- **Smart GitHub Integration**: Automatically detects and uses [GitHub CLI (`gh`)](https://cli.github.com/) when installed and authenticated
- **API Fallback**: Falls back to GitHub API (via Personal Access Token) when `gh` CLI is not available
- **Interactive Selection**: Select which forks to delete using an interactive terminal interface
- **Safe Deletion**: Requires explicit confirmation before deleting any repositories

## Installation

```sh
  gem install dishwasher
```

## Usage

[![asciicast](https://asciinema.org/a/311548.svg)](https://asciinema.org/a/311548)

### Using with GitHub CLI (Recommended)

If you have [GitHub CLI](https://cli.github.com/) installed and authenticated, Dishwasher will automatically use it:

```sh
# First, authenticate with GitHub CLI
gh auth login

# Then run dishwasher
dishwasher
```

### Using with Personal Access Token

If GitHub CLI is not available, Dishwasher will prompt for a GitHub Personal Access Token:

```sh
dishwasher
# You'll be prompted to enter your GitHub Personal Access Token
```

You can also set the token as an environment variable:

```sh
export GITHUB_ACCESS_TOKEN=your_token_here
dishwasher
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Requirements

- Ruby 3.0 or higher
- (Optional) [GitHub CLI](https://cli.github.com/) for enhanced GitHub integration
- (Optional) GitHub Personal Access Token if not using GitHub CLI

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andrewmcodes/dishwasher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### Code of Conduct

Everyone interacting in the Dishwasher project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andrewmcodes/dishwasher/blob/master/CODE_OF_CONDUCT.md).

### Coding Standards

This project uses [Standard](https://github.com/testdouble/standard) to minimize bike shedding related to code formatting.

Please run `./bin/standardize` prior submitting pull requests.

### Testing

This project uses RSpec for testing. Run the test suite with:

```sh
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
