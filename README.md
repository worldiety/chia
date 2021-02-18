# 🌱 chia - Check It All

`chia` is a command line tool that lets you run some checks.
It can be easily integrated into your CI process.

## ✅ Checks

The following checks will be run by chia:
- Readme/License Check: Test if the `README.md` and `LICENSE` files could be found in the project directory
- SpellCheck (macOS only): spellcheck you project files - no more `fixed typo` commits 🤓
- [SwiftLint](https://github.com/realm/SwiftLint): Runs `swiftlint` for your `swift` projects

## 🕹 Usage

You can run `chia` in your terminal, but keep in mind to also install all **required dependencies**.
Otherwise, the check might fail!
```bash
# detect language and run all available tests
chia

# specify a config for chia (local/remote)
chia --config /PATH/TO/.chia.yml
chia --config https://PATH/TO/.chia.yml

# only detect and return the language of the project
chia --language-detection
```

Instead of keeping track of your dependencies, you can use our [Docker Image](https://hub.docker.com/r/worldiety/chia).
It contains all the required binaries and is ready to use:
```bash
# run docker container with all dependencies and mount the current folder for analysis
docker run -it -v ${PWD}:/project worldiety/chia:latest
```

You can also add this to your [GitLab CI config](https://docs.gitlab.com/ce/ci/yaml/) ...
```yml
...

stages:
  - lint
  - build
  - deploy

chia:
  stage: lint
  image: worldiety/chia:latest
  allow_failure: false
  script:
    - chia

...
```

... or use our [:octocat: GitHub Action](https://github.com/marketplace/actions/github-action-for-chia).


## ⌨️🖱Installation

There are 2 ways to install `chia`. Choose the one that fits your needs.

Using [Mint](https://github.com/yonaskolb/mint):
```bash
mint install worldiety/chia
```

Compiling from source:
```bash
git clone https://github.com/worldiety/chia && cd chia
swift build --configuration release
mv `swift build --configuration release --show-bin-path`/chia /usr/local/bin
```


## :octocat: Contributions

All contributions are welcome!
Feel free to contribute to this project.
Submit pull requests or contribute tutorials - whatever you have to offer, it would be appreciated!

If a check is missing, the [`CheckProvider`](https://github.com/worldiety/chia/blob/main/Sources/chiaLib/Internal/CheckProvider.swift) is the right places to start.
Just add another implementation and have a look at all the [other checks](https://github.com/worldiety/chia/tree/main/Sources/chiaLib/Internal/CheckProviders).

If your favorite programming language is missing, have a look at the [`Language`](https://github.com/worldiety/chia/blob/main/Sources/chiaLib/API/Language.swift).
