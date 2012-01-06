source ~/.rvm/scripts/rvm
rvm use 1.9.2@rails_documentation_builder

if [[ ! -e rails ]]; then
  git clone git://github.com/rails/rails.git
fi

mkdir output
cd rails

for tag in `git tag`; do
  directory=output/$tag

  if [[ ! -e $directory ]]; then
    git checkout master
    git checkout $tag

    if [[ -e README.rdoc ]]; then
      main=README.rdoc
    elif [[ -e railties/README.rdoc ]]; then
      main=railties/README.rdoc
    elif [[ -e railties/README ]]; then
      main=railties/README
    fi

    cd ..

    sdoc --output $directory --exclude '.*/test/.*' --exclude '.*/examples/.*' --exclude '.*/guides/.*' --main rails/$main --title "Ruby on Rails $tag Documentation" rails

    cd rails
  fi
done