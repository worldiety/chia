# chia - Check It All

## Usage

```bash
# detect language and run all available tests
chia

# run docker container with all dependencies and mount the current folder for analysis
docker run -it -v ${PWD}:/project worldiety/chia:latest    

```


## Installation

```bash
git clone https://github.com/worldiety/chia && cd chia
swift build --configuration release
mv `swift build --configuration release --show-bin-path`/chia /usr/local/bin
```
