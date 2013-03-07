# Use RVM.
source ~/.rvm/scripts/rvm

# Check out the Rails repository.
if [[ ! -e rails ]]; then
  git clone git://github.com/rails/rails.git
fi

# Create the output directory.
mkdir -p output

# Fetch new tags.
cd rails

git pull
tags=`git tag`

cd ..

# For each tag...
for tag in $tags; do
  version=${tag:1}
  directory=output/$version

  # If documentation hasn't already been generated for this tag...
  if [[ ! -e $directory ]]; then
    # Check out the tag.
    cd rails

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

    cd ..

    # Generate the documentation.
    sdoc --output $directory --exclude '.*/test/.*' --exclude '.*/examples/.*' --exclude '.*/guides/.*' --main rails/$main --title "Ruby on Rails $version Documentation" rails
  fi
done