# Use RVM.
source ~/.rvm/scripts/rvm
rvm use 1.9.2@rails_documentation_builder

# Check out the Rails repository.
if [[ ! -e rails ]]; then
  git clone git://github.com/rails/rails.git
fi

# Create the output directory.
mkdir output
cd rails

# For each tag...
for tag in `git tag`; do
  directory=output/$tag

  # If documentation hasn't already been generated for this tag...
  if [[ ! -e $directory ]]; then
    # Check out the tag.
    git checkout master
    git checkout $tag

    # Figure out which readme to use as this version's main file.
    if [[ -e README.rdoc ]]; then
      main=README.rdoc
    elif [[ -e railties/README.rdoc ]]; then
      main=railties/README.rdoc
    elif [[ -e railties/README ]]; then
      main=railties/README
    fi

    # Generate the documentation.
    cd ..
    sdoc --output $directory --exclude '.*/test/.*' --exclude '.*/examples/.*' --exclude '.*/guides/.*' --main rails/$main --title "Ruby on Rails $tag Documentation" rails
    cd rails
  fi
done